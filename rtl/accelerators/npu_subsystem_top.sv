`timescale 1ns/1ps
module npu_subsystem_top #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256,
    parameter ARRAY_DIM = 16,
    parameter MAC_WIDTH = 16,
    parameter WEIGHT_DEPTH = 1024
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
    
    // AXI-Full Master (To Memory for DMA Fetch)
    output logic                  m_axi_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_araddr,
    output logic [7:0]            m_axi_arlen,
    input  logic                  m_axi_arready,
    input  logic                  m_axi_rvalid,
    input  logic [DATA_WIDTH-1:0] m_axi_rdata,
    input  logic                  m_axi_rlast,
    output logic                  m_axi_rready,
    
    // NPU Activation Stream In (From Core or NoC)
    input  logic                               act_in_valid,
    input  logic [ARRAY_DIM-1:0][MAC_WIDTH-1:0] act_in_data,
    output logic                               act_in_ready,
    
    // NPU Activation Stream Out (To Core or Writeback DMA)
    output logic                               act_out_valid,
    output logic [ARRAY_DIM-1:0][MAC_WIDTH-1:0] act_out_data,
    input  logic                               act_out_ready
);

    // =========================================================================
    // INTERNAL WIRING (Crossbar logic to FSM & DMA)
    // =========================================================================
    
    // AXI-Lite (Crossbar -> FSM)
    logic        fsm_awvalid, fsm_awready, fsm_wvalid, fsm_wready, fsm_bvalid, fsm_bready;
    logic [31:0] fsm_awaddr, fsm_wdata;
    logic [3:0]  fsm_wstrb;
    logic [1:0]  fsm_bresp, fsm_rresp;
    logic        fsm_arvalid, fsm_arready, fsm_rvalid, fsm_rready;
    logic [31:0] fsm_araddr, fsm_rdata;
    
    // AXI-Full (DMA -> Crossbar)
    logic                  dma_arvalid, dma_arready, dma_rvalid, dma_rlast, dma_rready;
    logic [ADDR_WIDTH-1:0] dma_araddr;
    logic [7:0]            dma_arlen;
    logic [DATA_WIDTH-1:0] dma_rdata;

    // =========================================================================
    // 1. NPU INTERNAL AXI CROSSBAR
    // =========================================================================
    npu_internal_axi_crossbar #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_npu_crossbar (
        .clk(clk),
        .rst_n(rst_n),
        
        // AXI-Full (DMA -> Crossbar -> NoC)
        .s_axi_full_arvalid(dma_arvalid),
        .s_axi_full_araddr(dma_araddr),
        .s_axi_full_arlen(dma_arlen),
        .s_axi_full_arready(dma_arready),
        .s_axi_full_rvalid(dma_rvalid),
        .s_axi_full_rdata(dma_rdata),
        .s_axi_full_rlast(dma_rlast),
        .s_axi_full_rready(dma_rready),
        
        .m_axi_full_arvalid(m_axi_arvalid),
        .m_axi_full_araddr(m_axi_araddr),
        .m_axi_full_arlen(m_axi_arlen),
        .m_axi_full_arready(m_axi_arready),
        .m_axi_full_rvalid(m_axi_rvalid),
        .m_axi_full_rdata(m_axi_rdata),
        .m_axi_full_rlast(m_axi_rlast),
        .m_axi_full_rready(m_axi_rready),
        
        // AXI-Lite (NoC -> Crossbar -> FSM)
        .s_axi_lite_awvalid(s_axi_awvalid),
        .s_axi_lite_awaddr(s_axi_awaddr),
        .s_axi_lite_awready(s_axi_awready),
        .s_axi_lite_wvalid(s_axi_wvalid),
        .s_axi_lite_wdata(s_axi_wdata),
        .s_axi_lite_wstrb(s_axi_wstrb),
        .s_axi_lite_wready(s_axi_wready),
        .s_axi_lite_bvalid(s_axi_bvalid),
        .s_axi_lite_bresp(s_axi_bresp),
        .s_axi_lite_bready(s_axi_bready),
        .s_axi_lite_arvalid(s_axi_arvalid),
        .s_axi_lite_araddr(s_axi_araddr),
        .s_axi_lite_arready(s_axi_arready),
        .s_axi_lite_rvalid(s_axi_rvalid),
        .s_axi_lite_rdata(s_axi_rdata),
        .s_axi_lite_rresp(s_axi_rresp),
        .s_axi_lite_rready(s_axi_rready),
        
        .m_axi_lite_awvalid(fsm_awvalid),
        .m_axi_lite_awaddr(fsm_awaddr),
        .m_axi_lite_awready(fsm_awready),
        .m_axi_lite_wvalid(fsm_wvalid),
        .m_axi_lite_wdata(fsm_wdata),
        .m_axi_lite_wstrb(fsm_wstrb),
        .m_axi_lite_wready(fsm_wready),
        .m_axi_lite_bvalid(fsm_bvalid),
        .m_axi_lite_bresp(fsm_bresp),
        .m_axi_lite_bready(fsm_bready),
        .m_axi_lite_arvalid(fsm_arvalid),
        .m_axi_lite_araddr(fsm_araddr),
        .m_axi_lite_arready(fsm_arready),
        .m_axi_lite_rvalid(fsm_rvalid),
        .m_axi_lite_rdata(fsm_rdata),
        .m_axi_lite_rresp(fsm_rresp),
        .m_axi_lite_rready(fsm_rready)
    );

    // =========================================================================
    // NPU CONTROLLER FSM (AXI-Lite Control Register Decoder)
    // =========================================================================
    logic                  ctrl_start;
    logic [ADDR_WIDTH-1:0] ctrl_src_addr;
    logic [ADDR_WIDTH-1:0] ctrl_dst_addr;
    logic [31:0]           ctrl_transfer_len;
    logic                  relu_en;
    logic                  ctrl_done;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ctrl_start <= 1'b0;
            ctrl_src_addr <= '0;
            ctrl_dst_addr <= '0;
            ctrl_transfer_len <= '0;
            relu_en <= 1'b0;
            fsm_awready <= 1'b0;
            fsm_wready <= 1'b0;
            fsm_bvalid <= 1'b0;
        end else begin
            ctrl_start <= 1'b0;
            fsm_awready <= 1'b1;
            fsm_wready <= 1'b1;
            fsm_bresp <= 2'b00;
            
            if (fsm_awvalid && fsm_wvalid) begin
                fsm_bvalid <= 1'b1;
                case (fsm_awaddr[7:0])
                    8'h00: ctrl_start <= fsm_wdata[0];
                    8'h08: ctrl_src_addr <= {32'd0, fsm_wdata};
                    8'h10: ctrl_dst_addr <= {32'd0, fsm_wdata};
                    8'h18: ctrl_transfer_len <= fsm_wdata;
                    8'h20: relu_en <= fsm_wdata[0];
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
                    8'h00: fsm_rdata <= {31'd0, ctrl_done};
                    default: fsm_rdata <= '0;
                endcase
            end else if (fsm_rready) begin
                fsm_rvalid <= 1'b0;
            end
        end
    end

    // =========================================================================
    // DATA PATH GLUE LOGIC
    // =========================================================================
    logic                  dma_to_wb_valid;
    logic [DATA_WIDTH-1:0] dma_to_wb_data;
    logic                  dma_to_wb_ready;
    
    logic                  wb_read_req;
    logic [$clog2(WEIGHT_DEPTH)-1:0] wb_read_addr;
    logic [DATA_WIDTH-1:0] wb_read_data;
    
    logic                               psum_valid;
    logic [ARRAY_DIM-1:0][MAC_WIDTH-1:0] psum_data;
    logic                               psum_ready;
    
    logic weight_load_en;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_read_addr <= '0;
            wb_read_req <= 1'b0;
            weight_load_en <= 1'b0;
        end else begin
            if (ctrl_done && wb_read_addr < WEIGHT_DEPTH) begin
                wb_read_req <= 1'b1;
                weight_load_en <= 1'b1;
                wb_read_addr <= wb_read_addr + 1'b1;
            end else begin
                weight_load_en <= 1'b0;
                wb_read_req <= 1'b0;
            end
        end
    end

    // =========================================================================
    // MODULE INSTANTIATIONS
    // =========================================================================

    // 2. NPU DMA Controller
    npu_dma_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_dma_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .ctrl_start(ctrl_start),
        .ctrl_src_addr(ctrl_src_addr),
        .ctrl_dst_addr(ctrl_dst_addr),
        .ctrl_transfer_len(ctrl_transfer_len),
        .ctrl_done(ctrl_done),
        // Connect to internal crossbar, NOT external
        .m_axi_arvalid(dma_arvalid),
        .m_axi_araddr(dma_araddr),
        .m_axi_arlen(dma_arlen),
        .m_axi_arready(dma_arready),
        .m_axi_rvalid(dma_rvalid),
        .m_axi_rdata(dma_rdata),
        .m_axi_rlast(dma_rlast),
        .m_axi_rready(dma_rready),
        .m_axis_tvalid(dma_to_wb_valid),
        .m_axis_tdata(dma_to_wb_data),
        .m_axis_tready(dma_to_wb_ready)
    );

    // 3. NPU Weight Buffer
    npu_weight_buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(WEIGHT_DEPTH)
    ) i_weight_buffer (
        .clk(clk),
        .rst_n(rst_n),
        .s_axis_tvalid(dma_to_wb_valid),
        .s_axis_tdata(dma_to_wb_data),
        .s_axis_tready(dma_to_wb_ready),
        .read_req(wb_read_req),
        .read_addr(wb_read_addr),
        .read_data(wb_read_data)
    );

    // 4. NPU Systolic Array (16x16 or 128x128 grid)
    npu_systolic_array #(
        .ARRAY_DIM(ARRAY_DIM),
        .DATA_WIDTH(MAC_WIDTH)
    ) i_systolic_array (
        .clk(clk),
        .rst_n(rst_n),
        .weight_load_en(weight_load_en),
        .weight_in(wb_read_data), 
        .act_in_valid(act_in_valid),
        .act_in(act_in_data),
        .act_in_ready(act_in_ready),
        .psum_out_valid(psum_valid),
        .psum_out(psum_data),
        .psum_out_ready(psum_ready)
    );

    // 5. NPU Activation Unit (ReLU)
    npu_activation_unit #(
        .ARRAY_DIM(ARRAY_DIM),
        .DATA_WIDTH(MAC_WIDTH)
    ) i_activation_unit (
        .clk(clk),
        .rst_n(rst_n),
        .psum_valid(psum_valid),
        .psum_in(psum_data),
        .psum_ready(psum_ready),
        .relu_en(relu_en),
        .act_out_valid(act_out_valid),
        .act_out(act_out_data),
        .act_out_ready(act_out_ready)
    );

endmodule
