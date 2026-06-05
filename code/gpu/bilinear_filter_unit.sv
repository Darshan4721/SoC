`timescale 1ns/1ps

module bilinear_filter_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [31:0] t00,
    output logic t01,
    output logic t10,
    output logic t11,
    output logic [7:0] frac_u,
    output logic frac_v,
    output logic valid_out,
    output logic [31:0] filtered_texel
);

endmodule
