`timescale 1ns/1ps

module fpu_mac_pipeline (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [63:0] a,
    output logic [63:0] b,
    output logic [63:0] c,
    output logic [2:0] rm,
    output logic op_sub,
    output logic valid_out,
    output logic [63:0] result_out
);

endmodule
