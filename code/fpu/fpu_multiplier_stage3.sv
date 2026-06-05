`timescale 1ns/1ps

module fpu_multiplier_stage3 (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [105:0] prod_in,
    output logic [11:0] exp_in,
    output logic sign_in,
    output logic valid_out,
    output logic [63:0] result_out
);

endmodule
