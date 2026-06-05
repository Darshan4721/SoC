`timescale 1ns/1ps
module gpu_subsystem_top #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256,
    parameter FRAG_WIDTH = 128,
    parameter PIX_WIDTH = 64
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // AXI-Lite Control Interface (From CPU)
    input  logic                  start_render,
    input  logic [ADDR_WIDTH-1:0] cmd_list_base_addr,
    input  logic [31:0]           cmd_list_size,
    input  logic [511:0]          mvp_matrix, // 4x4 matrix config
    input  logic [15:0]           screen_width,
    input  logic [15:0]           screen_height,
    input  logic [ADDR_WIDTH-1:0] fb_base_addr,
    output logic                  render_done,
    
    // AXI-Full Master 1: Command Fetcher
    output logic                  m_axi_cmd_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_cmd_araddr,
    output logic [7:0]            m_axi_cmd_arlen,
    input  logic                  m_axi_cmd_arready,
    input  logic                  m_axi_cmd_rvalid,
    input  logic [DATA_WIDTH-1:0] m_axi_cmd_rdata,
    input  logic                  m_axi_cmd_rlast,
    output logic                  m_axi_cmd_rready,
    
    // AXI-Full Master 2: Texture L1 Cache Misses
    output logic                  m_axi_tex_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_tex_araddr,
    input  logic                  m_axi_tex_arready,
    input  logic                  m_axi_tex_rvalid,
    input  logic [DATA_WIDTH-1:0] m_axi_tex_rdata,
    output logic                  m_axi_tex_rready,
    
    // AXI-Full Master 3: Frame Buffer Writeback
    output logic                  m_axi_fb_awvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_fb_awaddr,
    input  logic                  m_axi_fb_awready,
    output logic                  m_axi_fb_wvalid,
    output logic [DATA_WIDTH-1:0] m_axi_fb_wdata,
    input  logic                  m_axi_fb_wready
);

    // =========================================================================
    // INTERNAL WIRING (The Glue Logic)
    // =========================================================================
    
    // 1. CMD Processor -> Geometry Engine
    logic                  geom_tvalid;
    logic [DATA_WIDTH-1:0] geom_tdata;
    logic                  geom_tready;
    
    // 2. Geometry Engine -> Rasterizer
    logic                  rast_tvalid;
    logic [DATA_WIDTH-1:0] rast_tdata;
    logic                  rast_tready;
    
    // 3. Rasterizer -> Shader Core
    logic                  frag_tvalid;
    logic [FRAG_WIDTH-1:0] frag_tdata;
    logic                  frag_tready;
    
    // 4. Shader Core <-> Texture L1
    logic                  tex_req_val;
    logic [31:0]           tex_req_uv;
    logic                  tex_req_rdy;
    logic                  tex_rsp_val;
    logic [31:0]           tex_rsp_color;
    
    // 5. Shader Core -> ROP Pipeline
    logic                  pixel_tvalid;
    logic [PIX_WIDTH-1:0]  pixel_tdata;
    logic                  pixel_tready;
    
    // =========================================================================
    // MODULE INSTANTIATIONS
    // =========================================================================

    gpu_cmd_processor #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_cmd_processor (
        .clk(clk),
        .rst_n(rst_n),
        .start_render(start_render),
        .cmd_list_base_addr(cmd_list_base_addr),
        .cmd_list_size(cmd_list_size),
        .render_done(render_done),
        .m_axi_arvalid(m_axi_cmd_arvalid),
        .m_axi_araddr(m_axi_cmd_araddr),
        .m_axi_arlen(m_axi_cmd_arlen),
        .m_axi_arready(m_axi_cmd_arready),
        .m_axi_rvalid(m_axi_cmd_rvalid),
        .m_axi_rdata(m_axi_cmd_rdata),
        .m_axi_rlast(m_axi_cmd_rlast),
        .m_axi_rready(m_axi_cmd_rready),
        .geom_tvalid(geom_tvalid),
        .geom_tdata(geom_tdata),
        .geom_tready(geom_tready)
    );

    gpu_geometry_engine #(
        .DATA_WIDTH(DATA_WIDTH)
    ) i_geometry_engine (
        .clk(clk),
        .rst_n(rst_n),
        .geom_tvalid(geom_tvalid),
        .geom_tdata(geom_tdata),
        .geom_tready(geom_tready),
        .mvp_matrix(mvp_matrix),
        .rast_tvalid(rast_tvalid),
        .rast_tdata(rast_tdata),
        .rast_tready(rast_tready)
    );

    gpu_rasterizer #(
        .DATA_WIDTH(DATA_WIDTH)
    ) i_rasterizer (
        .clk(clk),
        .rst_n(rst_n),
        .rast_tvalid(rast_tvalid),
        .rast_tdata(rast_tdata),
        .rast_tready(rast_tready),
        .screen_width(screen_width),
        .screen_height(screen_height),
        .frag_tvalid(frag_tvalid),
        .frag_tdata(frag_tdata),
        .frag_tready(frag_tready)
    );

    gpu_shader_core #(
        .FRAG_WIDTH(FRAG_WIDTH),
        .PIX_WIDTH(PIX_WIDTH)
    ) i_shader_core (
        .clk(clk),
        .rst_n(rst_n),
        .frag_tvalid(frag_tvalid),
        .frag_tdata(frag_tdata),
        .frag_tready(frag_tready),
        .tex_req_val(tex_req_val),
        .tex_req_uv(tex_req_uv),
        .tex_req_rdy(tex_req_rdy),
        .tex_rsp_val(tex_rsp_val),
        .tex_rsp_color(tex_rsp_color),
        .pixel_tvalid(pixel_tvalid),
        .pixel_tdata(pixel_tdata),
        .pixel_tready(pixel_tready)
    );

    gpu_texture_l1 #(
        .CACHE_SIZE(4096),
        .LINE_SIZE(DATA_WIDTH)
    ) i_texture_l1 (
        .clk(clk),
        .rst_n(rst_n),
        .tex_req_val(tex_req_val),
        .tex_req_uv(tex_req_uv),
        .tex_req_rdy(tex_req_rdy),
        .tex_rsp_val(tex_rsp_val),
        .tex_rsp_color(tex_rsp_color),
        .m_axi_arvalid(m_axi_tex_arvalid),
        .m_axi_araddr(m_axi_tex_araddr),
        .m_axi_arready(m_axi_tex_arready),
        .m_axi_rvalid(m_axi_tex_rvalid),
        .m_axi_rdata(m_axi_tex_rdata),
        .m_axi_rready(m_axi_tex_rready)
    );

    gpu_rop_pipeline #(
        .PIX_WIDTH(PIX_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_rop_pipeline (
        .clk(clk),
        .rst_n(rst_n),
        .pixel_tvalid(pixel_tvalid),
        .pixel_tdata(pixel_tdata),
        .pixel_tready(pixel_tready),
        .fb_base_addr(fb_base_addr),
        .m_axi_awvalid(m_axi_fb_awvalid),
        .m_axi_awaddr(m_axi_fb_awaddr),
        .m_axi_awready(m_axi_fb_awready),
        .m_axi_wvalid(m_axi_fb_wvalid),
        .m_axi_wdata(m_axi_fb_wdata),
        .m_axi_wready(m_axi_fb_wready)
    );

endmodule
