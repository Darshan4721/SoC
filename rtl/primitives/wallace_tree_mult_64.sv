`timescale 1ns/1ps

module wallace_tree_mult_64 (
    input  logic [63:0] a,
    input  logic [63:0] b,
    output logic [127:0] prod
);
    assign prod = a * b;
endmodule
