`timescale 1ns/1ps

module av1_motion_compensator (
    input  logic clk,
    input  logic rst_n,
    output logic mc_start,
    output logic [15:0] mv_x,
    output logic [15:0] mv_y,
    output logic [2:0] block_size,
    output logic m_arvalid,
    output logic m_arready,
    output logic [63:0] m_araddr,
    output logic [7:0] m_arlen,
    output logic m_rvalid,
    input  logic m_rready,
    output logic [63:0] m_rdata,
    output logic m_rlast,
    output logic pred_valid,
    output logic [7:0] pred_pixel,
    output logic pred_done,
    output logic pred_ready
);

endmodule
