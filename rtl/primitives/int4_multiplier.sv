`timescale 1ns/1ps

module int4_multiplier (
    input  logic signed [3:0] a,
    input  logic signed [3:0] b,
    output logic signed [7:0] prod
);
    assign prod = a * b;
endmodule
