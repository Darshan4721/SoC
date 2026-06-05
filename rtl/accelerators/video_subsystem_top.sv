`timescale 1ns/1ps
module video_subsystem_top #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256,
    parameter COEFF_WIDTH = 128
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // AXI-Lite Control (From Core)
    input  logic                  start_decode,
    input  logic [ADDR_WIDTH-1:0] bitstream_base_addr,
    input  logic [31:0]           bitstream_size,
    input  logic [5:0]            qp_value,
    output logic                  decode_done,
    
    // AXI-Full Master (To Memory for Bitstream Fetch)
    output logic                  m_axi_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_araddr,
    output logic [7:0]            m_axi_arlen,
    input  logic                  m_axi_arready,
    input  logic                  m_axi_rvalid,
    input  logic [DATA_WIDTH-1:0] m_axi_rdata,
    input  logic                  m_axi_rlast,
    output logic                  m_axi_rready,
    
    // Reference Frame Input (From NoC / L2 Cache)
    input  logic                  ref_tvalid,
    input  logic [COEFF_WIDTH-1:0]ref_tdata,
    output logic                  ref_tready,
    
    // Final Decoded Pixels Output (To NoC / Display Controller)
    output logic                  out_tvalid,
    output logic [COEFF_WIDTH-1:0]out_tdata,
    input  logic                  out_tready
);

    // =========================================================================
    // INTERNAL WIRING (The Glue Logic)
    // =========================================================================
    
    // 1. DMA -> Entropy Decoder (Compressed Bitstream)
    logic                  stream_tvalid;
    logic [DATA_WIDTH-1:0] stream_tdata;
    logic                  stream_tready;
    
    // 2. Entropy Decoder -> Inverse Quantizer (Frequency Coefficients)
    logic                   coeff_tvalid;
    logic [COEFF_WIDTH-1:0] coeff_tdata;
    logic                   coeff_tready;
    
    // 3. Inverse Quantizer -> Motion Compensator (Spatial Residuals)
    logic                   resid_tvalid;
    logic [COEFF_WIDTH-1:0] resid_tdata;
    logic                   resid_tready;

    // =========================================================================
    // MODULE INSTANTIATIONS
    // =========================================================================

    // 1. Video DMA Controller
    vid_dma_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_dma_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .start_decode(start_decode),
        .bitstream_base_addr(bitstream_base_addr),
        .bitstream_size(bitstream_size),
        .decode_done(decode_done),
        // AXI Memory Interface
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arready(m_axi_arready),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rready(m_axi_rready),
        // Streaming Output
        .stream_tvalid(stream_tvalid),
        .stream_tdata(stream_tdata),
        .stream_tready(stream_tready)
    );

    // 2. Entropy Decoder (CABAC/CAVLC)
    vid_entropy_decoder #(
        .DATA_WIDTH(DATA_WIDTH),
        .COEFF_WIDTH(COEFF_WIDTH)
    ) i_entropy_decoder (
        .clk(clk),
        .rst_n(rst_n),
        // Streaming Input
        .stream_tvalid(stream_tvalid),
        .stream_tdata(stream_tdata),
        .stream_tready(stream_tready),
        // Streaming Output
        .coeff_tvalid(coeff_tvalid),
        .coeff_tdata(coeff_tdata),
        .coeff_tready(coeff_tready)
    );

    // 3. Inverse Quantization and Transform (IDCT)
    vid_inverse_quant #(
        .DATA_WIDTH(COEFF_WIDTH)
    ) i_inverse_quant (
        .clk(clk),
        .rst_n(rst_n),
        .qp_value({2'b00, qp_value}),
        // Streaming Input
        .coeff_tvalid(coeff_tvalid),
        .coeff_tdata(coeff_tdata),
        .coeff_tready(coeff_tready),
        // Streaming Output
        .resid_tvalid(resid_tvalid),
        .resid_tdata(resid_tdata),
        .resid_tready(resid_tready)
    );

    // 4. Motion Compensation
    vid_motion_comp #(
        .DATA_WIDTH(COEFF_WIDTH)
    ) i_motion_comp (
        .clk(clk),
        .rst_n(rst_n),
        // Streaming Inputs
        .resid_tvalid(resid_tvalid),
        .resid_tdata(resid_tdata),
        .resid_tready(resid_tready),
        .ref_tvalid(ref_tvalid),
        .ref_tdata(ref_tdata),
        .ref_tready(ref_tready),
        // Streaming Output
        .out_tvalid(out_tvalid),
        .out_tdata(out_tdata),
        .out_tready(out_tready)
    );

endmodule
