`timescale 1ns/1ps

module trilinear_filter_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [31:0] l0_t00,
    output logic l0_t01,
    output logic l0_t10,
    output logic l0_t11,
    output logic [31:0] l1_t00,
    output logic l1_t01,
    output logic l1_t10,
    output logic l1_t11,
    output logic [7:0] frac_u,
    output logic frac_v,
    output logic [7:0] frac_d,
    output logic valid_out,
    output logic [31:0] filtered_texel
);

endmodule
