`timescale 1ns/1ps

module carry_lookahead_adder_64 (
    input  logic [63:0] a,
    input  logic [63:0] b,
    input  logic        c_in,
    output logic [63:0] sum,
    output logic        c_out
);
    // Modern synthesis targets optimized prefix adders automatically
    assign {c_out, sum} = a + b + c_in;
endmodule
