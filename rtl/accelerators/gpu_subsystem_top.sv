`timescale 1ns/1ps
module gpu_subsystem_top #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256,
    parameter FRAG_WIDTH = 128,
    parameter PIX_WIDTH = 64,
    parameter NUM_SHADER_CORES = 4 // Scalable GPU cores
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // AXI-Lite Slave (Control Interface from Core/NoC)
    input  logic                  s_axi_awvalid,
    input  logic [31:0]           s_axi_awaddr,
    output logic                  s_axi_awready,
    input  logic                  s_axi_wvalid,
    input  logic [31:0]           s_axi_wdata,
    input  logic [3:0]            s_axi_wstrb,
    output logic                  s_axi_wready,
    output logic                  s_axi_bvalid,
    output logic [1:0]            s_axi_bresp,
    input  logic                  s_axi_bready,
    input  logic                  s_axi_arvalid,
    input  logic [31:0]           s_axi_araddr,
    output logic                  s_axi_arready,
    output logic                  s_axi_rvalid,
    output logic [31:0]           s_axi_rdata,
    output logic [1:0]            s_axi_rresp,
    input  logic                  s_axi_rready,
    
    // AXI-Full Master (To Global NoC for Memory access)
    output logic                  m_axi_awvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_awaddr,
    input  logic                  m_axi_awready,
    output logic                  m_axi_wvalid,
    output logic [DATA_WIDTH-1:0] m_axi_wdata,
    input  logic                  m_axi_wready,
    
    output logic                  m_axi_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_araddr,
    output logic [7:0]            m_axi_arlen,
    input  logic                  m_axi_arready,
    input  logic                  m_axi_rvalid,
    input  logic [DATA_WIDTH-1:0] m_axi_rdata,
    input  logic                  m_axi_rlast,
    output logic                  m_axi_rready
);

    // =========================================================================
    // GPU CONTROLLER FSM (AXI-Lite Control Register Decoder)
    // =========================================================================
    logic                  start_render;
    logic [ADDR_WIDTH-1:0] cmd_list_base_addr;
    logic [31:0]           cmd_list_size;
    logic [511:0]          mvp_matrix;
    logic [15:0]           screen_width;
    logic [15:0]           screen_height;
    logic [ADDR_WIDTH-1:0] fb_base_addr;
    logic                  render_done;
    
    // Crossbar to FSM connections
    logic        fsm_awvalid, fsm_awready, fsm_wvalid, fsm_wready, fsm_bvalid, fsm_bready;
    logic [31:0] fsm_awaddr, fsm_wdata;
    logic [3:0]  fsm_wstrb;
    logic [1:0]  fsm_bresp, fsm_rresp;
    logic        fsm_arvalid, fsm_arready, fsm_rvalid, fsm_rready;
    logic [31:0] fsm_araddr, fsm_rdata;

    // Memory Mapped Registers
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start_render <= 1'b0;
            cmd_list_base_addr <= '0;
            cmd_list_size <= '0;
            mvp_matrix <= '0;
            screen_width <= 16'd1920;
            screen_height <= 16'd1080;
            fb_base_addr <= '0;
            fsm_awready <= 1'b0;
            fsm_wready <= 1'b0;
            fsm_bvalid <= 1'b0;
        end else begin
            start_render <= 1'b0;
            fsm_awready <= 1'b1;
            fsm_wready <= 1'b1;
            fsm_bresp <= 2'b00;
            
            if (fsm_awvalid && fsm_wvalid) begin
                fsm_bvalid <= 1'b1;
                case (fsm_awaddr[7:0])
                    8'h00: start_render <= fsm_wdata[0];
                    8'h08: cmd_list_base_addr <= {32'd0, fsm_wdata};
                    8'h10: cmd_list_size <= fsm_wdata;
                    8'h18: screen_width <= fsm_wdata[15:0];
                    8'h1C: screen_height <= fsm_wdata[15:0];
                    8'h20: fb_base_addr <= {32'd0, fsm_wdata};
                    // Simplified MVP Matrix loading
                    8'h40: mvp_matrix[31:0] <= fsm_wdata;
                endcase
            end else if (fsm_bready) begin
                fsm_bvalid <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fsm_arready <= 1'b0;
            fsm_rvalid <= 1'b0;
            fsm_rdata <= '0;
        end else begin
            fsm_arready <= 1'b1;
            fsm_rresp <= 2'b00;
            if (fsm_arvalid) begin
                fsm_rvalid <= 1'b1;
                case (fsm_araddr[7:0])
                    8'h00: fsm_rdata <= {31'd0, render_done};
                    default: fsm_rdata <= '0;
                endcase
            end else if (fsm_rready) begin
                fsm_rvalid <= 1'b0;
            end
        end
    end

    // =========================================================================
    // INTERNAL WIRING (The Glue Logic)
    // =========================================================================
    
    // CMD Fetcher AXI
    logic cmd_arvalid, cmd_arready, cmd_rvalid, cmd_rlast, cmd_rready;
    logic [ADDR_WIDTH-1:0] cmd_araddr; logic [7:0] cmd_arlen; logic [DATA_WIDTH-1:0] cmd_rdata;
    
    // Texture L1 AXI
    logic tex_arvalid, tex_arready, tex_rvalid, tex_rlast, tex_rready;
    logic [ADDR_WIDTH-1:0] tex_araddr; logic [7:0] tex_arlen; logic [DATA_WIDTH-1:0] tex_rdata;
    
    // ROP AXI
    logic rop_awvalid, rop_awready, rop_wvalid, rop_wready;
    logic [ADDR_WIDTH-1:0] rop_awaddr; logic [DATA_WIDTH-1:0] rop_wdata;
    
    // Graphics Pipeline Data
    logic                  geom_tvalid, geom_tready;
    logic [DATA_WIDTH-1:0] geom_tdata;
    
    logic                  rast_tvalid, rast_tready;
    logic [DATA_WIDTH-1:0] rast_tdata;
    
    // Multi-Core Shader Dispatches
    logic [NUM_SHADER_CORES-1:0]                  core_frag_tvalid, core_frag_tready;
    logic [NUM_SHADER_CORES-1:0][FRAG_WIDTH-1:0]  core_frag_tdata;
    
    logic [NUM_SHADER_CORES-1:0]                  core_tex_req_val, core_tex_req_rdy;
    logic [NUM_SHADER_CORES-1:0][31:0]            core_tex_req_uv;
    
    logic [NUM_SHADER_CORES-1:0]                  core_tex_rsp_val;
    logic [NUM_SHADER_CORES-1:0][31:0]            core_tex_rsp_color;
    
    logic [NUM_SHADER_CORES-1:0]                  core_pix_tvalid, core_pix_tready;
    logic [NUM_SHADER_CORES-1:0][PIX_WIDTH-1:0]   core_pix_tdata;

    // Rasterizer to Multi-core Dispatch
    logic                  frag_tvalid, frag_tready;
    logic [FRAG_WIDTH-1:0] frag_tdata;
    
    // Simple round-robin dispatcher for fragments
    logic [1:0] rr_ptr;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) rr_ptr <= '0;
        else if (frag_tvalid && frag_tready) rr_ptr <= rr_ptr + 1'b1;
    end
    
    assign frag_tready = core_frag_tready[rr_ptr];
    always_comb begin
        core_frag_tvalid = '0;
        core_frag_tdata = '0;
        core_frag_tvalid[rr_ptr] = frag_tvalid;
        core_frag_tdata[rr_ptr] = frag_tdata;
    end

    // =========================================================================
    // MODULE INSTANTIATIONS
    // =========================================================================

    // 1. Internal AXI Crossbar
    gpu_internal_axi_crossbar #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_gpu_crossbar (
        .clk(clk), .rst_n(rst_n),
        // Master 0 (CMD)
        .s0_axi_arvalid(cmd_arvalid), .s0_axi_araddr(cmd_araddr), .s0_axi_arlen(cmd_arlen),
        .s0_axi_arready(cmd_arready), .s0_axi_rvalid(cmd_rvalid), .s0_axi_rdata(cmd_rdata),
        .s0_axi_rlast(cmd_rlast), .s0_axi_rready(cmd_rready),
        // Master 1 (TEX)
        .s1_axi_arvalid(tex_arvalid), .s1_axi_araddr(tex_araddr), .s1_axi_arlen(tex_arlen),
        .s1_axi_arready(tex_arready), .s1_axi_rvalid(tex_rvalid), .s1_axi_rdata(tex_rdata),
        .s1_axi_rlast(tex_rlast), .s1_axi_rready(tex_rready),
        // Master 2 (ROP)
        .s2_axi_awvalid(rop_awvalid), .s2_axi_awaddr(rop_awaddr), .s2_axi_awready(rop_awready),
        .s2_axi_wvalid(rop_wvalid), .s2_axi_wdata(rop_wdata), .s2_axi_wready(rop_wready),
        // To NoC
        .m_axi_awvalid(m_axi_awvalid), .m_axi_awaddr(m_axi_awaddr), .m_axi_awready(m_axi_awready),
        .m_axi_wvalid(m_axi_wvalid), .m_axi_wdata(m_axi_wdata), .m_axi_wready(m_axi_wready),
        .m_axi_arvalid(m_axi_arvalid), .m_axi_araddr(m_axi_araddr), .m_axi_arlen(m_axi_arlen),
        .m_axi_arready(m_axi_arready), .m_axi_rvalid(m_axi_rvalid), .m_axi_rdata(m_axi_rdata),
        .m_axi_rlast(m_axi_rlast), .m_axi_rready(m_axi_rready),
        // AXI-Lite
        .s_axi_lite_awvalid(s_axi_awvalid), .s_axi_lite_awaddr(s_axi_awaddr), .s_axi_lite_awready(s_axi_awready),
        .s_axi_lite_wvalid(s_axi_wvalid), .s_axi_lite_wdata(s_axi_wdata), .s_axi_lite_wstrb(s_axi_wstrb),
        .s_axi_lite_wready(s_axi_wready), .s_axi_lite_bvalid(s_axi_bvalid), .s_axi_lite_bresp(s_axi_bresp),
        .s_axi_lite_bready(s_axi_bready), .s_axi_lite_arvalid(s_axi_arvalid), .s_axi_lite_araddr(s_axi_araddr),
        .s_axi_lite_arready(s_axi_arready), .s_axi_lite_rvalid(s_axi_rvalid), .s_axi_lite_rdata(s_axi_rdata),
        .s_axi_lite_rresp(s_axi_rresp), .s_axi_lite_rready(s_axi_rready),
        
        .m_axi_lite_awvalid(fsm_awvalid), .m_axi_lite_awaddr(fsm_awaddr), .m_axi_lite_awready(fsm_awready),
        .m_axi_lite_wvalid(fsm_wvalid), .m_axi_lite_wdata(fsm_wdata), .m_axi_lite_wstrb(fsm_wstrb),
        .m_axi_lite_wready(fsm_wready), .m_axi_lite_bvalid(fsm_bvalid), .m_axi_lite_bresp(fsm_bresp),
        .m_axi_lite_bready(fsm_bready), .m_axi_lite_arvalid(fsm_arvalid), .m_axi_lite_araddr(fsm_araddr),
        .m_axi_lite_arready(fsm_arready), .m_axi_lite_rvalid(fsm_rvalid), .m_axi_lite_rdata(fsm_rdata),
        .m_axi_lite_rresp(fsm_rresp), .m_axi_lite_rready(fsm_rready)
    );

    // 2. CMD Processor
    gpu_cmd_processor #(
        .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)
    ) i_cmd_processor (
        .clk(clk), .rst_n(rst_n),
        .start_render(start_render), .cmd_list_base_addr(cmd_list_base_addr),
        .cmd_list_size(cmd_list_size), .render_done(render_done),
        .m_axi_arvalid(cmd_arvalid), .m_axi_araddr(cmd_araddr), .m_axi_arlen(cmd_arlen),
        .m_axi_arready(cmd_arready), .m_axi_rvalid(cmd_rvalid), .m_axi_rdata(cmd_rdata),
        .m_axi_rlast(cmd_rlast), .m_axi_rready(cmd_rready),
        .geom_tvalid(geom_tvalid), .geom_tdata(geom_tdata), .geom_tready(geom_tready)
    );

    // 3. Geometry Engine
    gpu_geometry_engine #(
        .DATA_WIDTH(DATA_WIDTH)
    ) i_geometry_engine (
        .clk(clk), .rst_n(rst_n),
        .geom_tvalid(geom_tvalid), .geom_tdata(geom_tdata), .geom_tready(geom_tready),
        .mvp_matrix(mvp_matrix),
        .rast_tvalid(rast_tvalid), .rast_tdata(rast_tdata), .rast_tready(rast_tready)
    );

    // 4. Rasterizer
    gpu_rasterizer #(
        .DATA_WIDTH(DATA_WIDTH)
    ) i_rasterizer (
        .clk(clk), .rst_n(rst_n),
        .rast_tvalid(rast_tvalid), .rast_tdata(rast_tdata), .rast_tready(rast_tready),
        .screen_width(screen_width), .screen_height(screen_height),
        .frag_tvalid(frag_tvalid), .frag_tdata(frag_tdata), .frag_tready(frag_tready)
    );

    // 5. Shader Cores (x4 Instances unrolled via generate)
    genvar i;
    generate
        for (i = 0; i < NUM_SHADER_CORES; i++) begin : shader_cores
            gpu_shader_core #(
                .FRAG_WIDTH(FRAG_WIDTH), .PIX_WIDTH(PIX_WIDTH)
            ) i_shader_core (
                .clk(clk), .rst_n(rst_n),
                .frag_tvalid(core_frag_tvalid[i]), .frag_tdata(core_frag_tdata[i]), .frag_tready(core_frag_tready[i]),
                .tex_req_val(core_tex_req_val[i]), .tex_req_uv(core_tex_req_uv[i]), .tex_req_rdy(core_tex_req_rdy[i]),
                .tex_rsp_val(core_tex_rsp_val[i]), .tex_rsp_color(core_tex_rsp_color[i]),
                .pixel_tvalid(core_pix_tvalid[i]), .pixel_tdata(core_pix_tdata[i]), .pixel_tready(core_pix_tready[i])
            );
        end
    endgenerate

    // 6. Texture L1 (Shared across all 4 cores via simple OR/muxing for demo)
    assign tex_arlen = 8'd7; // 8-beat burst
    assign core_tex_req_rdy = {NUM_SHADER_CORES{1'b1}}; // simplified acceptance
    
    gpu_texture_l1 #(
        .CACHE_SIZE(4096), .LINE_SIZE(DATA_WIDTH)
    ) i_texture_l1 (
        .clk(clk), .rst_n(rst_n),
        .tex_req_val(core_tex_req_val[0]), // Simplified to take core 0
        .tex_req_uv(core_tex_req_uv[0]),
        .tex_req_rdy(),
        .tex_rsp_val(core_tex_rsp_val[0]),
        .tex_rsp_color(core_tex_rsp_color[0]),
        .m_axi_arvalid(tex_arvalid), .m_axi_araddr(tex_araddr), .m_axi_arready(tex_arready),
        .m_axi_rvalid(tex_rvalid), .m_axi_rdata(tex_rdata), .m_axi_rready(tex_rready)
    );

    // 7. ROP Pipeline (Merge pixels from 4 cores)
    logic                  pix_merge_valid;
    logic [PIX_WIDTH-1:0]  pix_merge_data;
    assign pix_merge_valid = core_pix_tvalid[0] | core_pix_tvalid[1] | core_pix_tvalid[2] | core_pix_tvalid[3];
    assign pix_merge_data = core_pix_tvalid[0] ? core_pix_tdata[0] : 
                            core_pix_tvalid[1] ? core_pix_tdata[1] : 
                            core_pix_tvalid[2] ? core_pix_tdata[2] : core_pix_tdata[3];
    assign core_pix_tready = {NUM_SHADER_CORES{1'b1}};

    gpu_rop_pipeline #(
        .PIX_WIDTH(PIX_WIDTH), .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)
    ) i_rop_pipeline (
        .clk(clk), .rst_n(rst_n),
        .pixel_tvalid(pix_merge_valid), .pixel_tdata(pix_merge_data), .pixel_tready(),
        .fb_base_addr(fb_base_addr),
        .m_axi_awvalid(rop_awvalid), .m_axi_awaddr(rop_awaddr), .m_axi_awready(rop_awready),
        .m_axi_wvalid(rop_wvalid), .m_axi_wdata(rop_wdata), .m_axi_wready(rop_wready)
    );

endmodule
