`timescale 1ns/1ps

module anisotropic_filter_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [31:0] [0:15] samples,
    output logic [7:0] [0:15] weights,
    output logic [4:0] num_samples,
    output logic valid_out,
    output logic [31:0] filtered_texel
);

endmodule
