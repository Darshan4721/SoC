`timescale 1ns/1ps

module texture_decompression_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [63:0] compressed_block,
    output logic valid_out,
    output logic [15:0][31:0] decompressed_texels
);

endmodule
