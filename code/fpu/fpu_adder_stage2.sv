`timescale 1ns/1ps

module fpu_adder_stage2 (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [10:0] exp_in,
    output logic [52:0] frac_l_in,
    output logic [52:0] frac_s_in,
    output logic [11:0] shift_amt_in,
    output logic sign_in,
    output logic eff_sub_in,
    output logic valid_out,
    output logic [10:0] exp_out,
    output logic [54:0] sum_out,
    output logic sign_out,
    output logic eff_sub_out
);

endmodule
