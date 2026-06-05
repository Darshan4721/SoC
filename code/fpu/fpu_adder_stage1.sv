`timescale 1ns/1ps

module fpu_adder_stage1 (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [63:0] a,
    output logic [63:0] b,
    output logic op_sub,
    output logic valid_out,
    output logic [10:0] exp_out,
    output logic [52:0] frac_l_out,
    output logic [52:0] frac_s_out,
    output logic [11:0] shift_amt_out,
    output logic sign_out,
    output logic eff_sub_out
);

endmodule
