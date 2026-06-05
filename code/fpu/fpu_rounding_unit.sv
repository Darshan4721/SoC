`timescale 1ns/1ps

module fpu_rounding_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic sign,
    output logic [12:0] exp,
    output logic [54:0] mant_with_grs,
    output logic [2:0] rm,
    output logic valid_out,
    output logic [63:0] result_out,
    output logic [4:0] fflags
);

endmodule
