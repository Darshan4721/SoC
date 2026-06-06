`timescale 1ns/1ps
module rv64_fetch_unit #(
    parameter PC_WIDTH = 64,
    parameter INSTR_WIDTH = 32
) (
    input  logic clk,
    input  logic rst_n,
    
    // Pipeline Flush / Redirect (from Execute/Commit)
    input  logic                  flush,
    input  logic [PC_WIDTH-1:0]   flush_target_pc,
    input  logic                  stall,
    
    // BPU Update Interface (from Execute)
    input  logic                  bpu_update_en,
    input  logic [PC_WIDTH-1:0]   bpu_update_pc,
    input  logic                  bpu_update_taken,
    input  logic [PC_WIDTH-1:0]   bpu_update_target,
    
    // Interface to Decode Unit (4-wide)
    input  logic                  decode_ready,
    output logic [3:0]            fetch_valid,
    output logic [3:0][INSTR_WIDTH-1:0] fetch_instr,
    output logic [3:0][PC_WIDTH-1:0]    fetch_pc,
    
    // AXI Master Interface to NoC/L2
    output logic                  m_axi_arvalid,
    output logic [PC_WIDTH-1:0]   m_axi_araddr,
    output logic [7:0]            m_axi_arlen,
    input  logic                  m_axi_arready,
    input  logic                  m_axi_rvalid,
    input  logic [255:0]          m_axi_rdata,
    input  logic                  m_axi_rlast,
    output logic                  m_axi_rready
);

    // =========================================================================
    // INTERNAL WIRING
    // =========================================================================

    // PC Gen Output
    logic [PC_WIDTH-1:0] current_pc;
    logic                valid_pc;
    
    // PC Gen to I-Cache
    logic                icache_req_val;
    logic [PC_WIDTH-1:0] icache_req_addr;
    logic                icache_req_rdy;
    
    // I-Cache to Fetch Buffer
    logic                icache_rsp_val;
    logic [127:0]        icache_rsp_data;
    
    // Branch Prediction
    logic                predicted_taken;
    logic [PC_WIDTH-1:0] predicted_target;

    // Track the PC requested from the Cache to align with the response
    logic [PC_WIDTH-1:0] req_pc_q;
    always_ff @(posedge clk) begin
        if (icache_req_val && icache_req_rdy) req_pc_q <= icache_req_addr;
    end

    // =========================================================================
    // MODULE INSTANTIATIONS
    // =========================================================================

    // 1. PC Generation Unit
    pc_gen_unit #(
        .ADDR_WIDTH(PC_WIDTH)
    ) i_pc_gen (
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .flush(flush),
        .branch_taken(predicted_taken),
        .branch_target(predicted_target),
        .icache_req_val(icache_req_val),
        .icache_req_addr(icache_req_addr),
        .icache_req_rdy(icache_req_rdy),
        .current_pc(current_pc),
        .valid_pc(valid_pc)
    );

    // 2. Branch Prediction Unit
    branch_prediction_unit #(
        .ADDR_WIDTH(PC_WIDTH),
        .BTB_ENTRIES(256)
    ) i_bpu (
        .clk(clk),
        .rst_n(rst_n),
        .current_pc(current_pc),
        .predicted_taken(predicted_taken),
        .predicted_target(predicted_target),
        .update_en(bpu_update_en),
        .update_pc(bpu_update_pc),
        .update_taken(bpu_update_taken),
        .update_target(bpu_update_target)
    );

    // 3. L1 Instruction Cache Controller
    l1_icache_ctrl #(
        .ADDR_WIDTH(PC_WIDTH),
        .DATA_WIDTH(128)
    ) i_icache (
        .clk(clk),
        .rst_n(rst_n),
        .core_req_val(icache_req_val),
        .core_req_addr(icache_req_addr),
        .core_rsp_val(icache_rsp_val),
        .core_rsp_data(icache_rsp_data),
        .core_req_rdy(icache_req_rdy),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arready(m_axi_arready),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rready(m_axi_rready)
    );

    // 4. Fetch Buffer (4-way Superscalar Interface)
    // Buffers cache lines and feeds them to the decoders
    logic fetch_buffer_full;
    fetch_buffer #(
        .INSTR_WIDTH(INSTR_WIDTH),
        .PC_WIDTH(PC_WIDTH),
        .DEPTH(8)
    ) i_fetch_buffer (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush),
        .icache_rsp_val(icache_rsp_val),
        .icache_rsp_data(icache_rsp_data),
        .icache_rsp_pc(req_pc_q),
        .decode_ready(decode_ready),
        .fetch_valid(fetch_valid),
        .fetch_instr(fetch_instr),
        .fetch_pc(fetch_pc),
        .fetch_full(fetch_buffer_full)
    );

endmodule
