`timescale 1ns/1ps

module motion_estimation_engine (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [7:0] [0:255] curr_mb,
    output logic [7:0] [0:1023] ref_window,
    output logic valid_out,
    output logic [15:0] best_mv_x,
    output logic [15:0] best_mv_y,
    output logic [31:0] best_sad
);

endmodule
