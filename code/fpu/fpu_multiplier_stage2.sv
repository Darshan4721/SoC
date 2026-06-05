`timescale 1ns/1ps

module fpu_multiplier_stage2 (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [105:0] prod_in,
    output logic [11:0] exp_in,
    output logic sign_in,
    output logic valid_out,
    output logic [105:0] prod_out,
    output logic [11:0] exp_out,
    output logic sign_out
);

endmodule
