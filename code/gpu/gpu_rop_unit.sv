`timescale 1ns/1ps

module gpu_rop_unit (
    input  logic clk,
    input  logic rst_n,
    output logic rop_valid,
    output logic [15:0] rop_x,
    output logic [15:0] rop_y,
    output logic [31:0] rop_color,
    output logic [31:0] rop_depth,
    output logic rop_ready,
    input  logic m_awvalid,
    output logic m_awready,
    output logic [63:0] m_awaddr,
    input  logic m_wvalid,
    output logic m_wready,
    output logic [63:0] m_wdata,
    output logic m_wlast,
    output logic m_bvalid,
    input  logic m_bready,
    output logic m_arvalid,
    output logic m_arready,
    output logic [63:0] m_araddr,
    output logic m_rvalid,
    input  logic m_rready,
    output logic [63:0] m_rdata,
    output logic m_rlast
);

endmodule
