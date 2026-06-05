`timescale 1ns/1ps

module deblocking_filter (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [7:0] [0:7] pixels_in,
    output logic [7:0] alpha,
    output logic [7:0] beta,
    output logic [7:0] tc,
    output logic valid_out,
    output logic [7:0] [0:7] pixels_out
);

endmodule
