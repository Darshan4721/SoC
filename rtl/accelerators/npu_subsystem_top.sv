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
    
    // AXI-Lite Control (From Core)
    input  logic                  ctrl_start,
    input  logic [ADDR_WIDTH-1:0] ctrl_src_addr,
    input  logic [ADDR_WIDTH-1:0] ctrl_dst_addr,
    input  logic [31:0]           ctrl_transfer_len,
    input  logic                  relu_en,
    output logic                  ctrl_done,
    
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
    // INTERNAL WIRING (The Glue Logic)
    // =========================================================================
    
    // 1. DMA -> Weight Buffer
    logic                  dma_to_wb_valid;
    logic [DATA_WIDTH-1:0] dma_to_wb_data;
    logic                  dma_to_wb_ready;
    
    // 2. Weight Buffer -> Systolic Array
    // Simplified tie-off for reading weight buffer continuously during array load
    logic                  wb_read_req;
    logic [$clog2(WEIGHT_DEPTH)-1:0] wb_read_addr;
    logic [DATA_WIDTH-1:0] wb_read_data;
    
    // 3. Systolic Array -> Activation Unit
    logic                               psum_valid;
    logic [ARRAY_DIM-1:0][MAC_WIDTH-1:0] psum_data;
    logic                               psum_ready;
    
    // =========================================================================
    // SIMPLE GLUE PROTOCOL LOGIC
    // =========================================================================
    // Manage weight pre-loading from the buffer to the array
    logic weight_load_en;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_read_addr <= '0;
            wb_read_req <= 1'b0;
            weight_load_en <= 1'b0;
        end else begin
            // Simplified logic: When DMA is done loading weights, trigger array load
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

    // 1. NPU DMA Controller
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
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arready(m_axi_arready),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rready(m_axi_rready),
        .m_axis_tvalid(dma_to_wb_valid),
        .m_axis_tdata(dma_to_wb_data),
        .m_axis_tready(dma_to_wb_ready)
    );

    // 2. NPU Weight Buffer
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

    // 3. NPU Systolic Array (16x16 or 128x128 grid)
    npu_systolic_array #(
        .ARRAY_DIM(ARRAY_DIM),
        .DATA_WIDTH(MAC_WIDTH)
    ) i_systolic_array (
        .clk(clk),
        .rst_n(rst_n),
        .weight_load_en(weight_load_en),
        // Pass the massive 256-bit read data into the broadcast array
        .weight_in(wb_read_data), 
        .act_in_valid(act_in_valid),
        .act_in(act_in_data),
        .act_in_ready(act_in_ready),
        .psum_out_valid(psum_valid),
        .psum_out(psum_data),
        .psum_out_ready(psum_ready)
    );

    // 4. NPU Activation Unit (ReLU)
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
