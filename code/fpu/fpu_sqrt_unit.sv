`timescale 1ns/1ps

module fpu_sqrt_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic ready,
    output logic [63:0] a,
    output logic valid_out,
    output logic [63:0] result_out
);

endmodule
