`timescale 1ns/1ps

module wallace_tree_mult_32 (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [63:0] prod
);
    // Behavioral multiplication mapped to standard cell Wallace tree structures
    assign prod = a * b;
endmodule
