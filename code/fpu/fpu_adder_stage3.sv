`timescale 1ns/1ps

module fpu_adder_stage3 (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [10:0] exp_in,
    output logic [54:0] sum_in,
    output logic sign_in,
    output logic eff_sub_in,
    output logic valid_out,
    output logic [63:0] result_out
);

endmodule
