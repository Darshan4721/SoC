`timescale 1ns/1ps

module layer_norm_engine (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [VEC_SIZE-1:0][WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] gamma,
    output logic [WIDTH-1:0] beta,
    output logic valid_out,
    output logic [VEC_SIZE-1:0][WIDTH-1:0] data_out
);

endmodule
