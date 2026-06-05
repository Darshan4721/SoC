`timescale 1ns/1ps

module int8_multiplier (
    input  logic signed [7:0] a,
    input  logic signed [7:0] b,
    output logic signed [15:0] prod
);
    assign prod = a * b;
endmodule
