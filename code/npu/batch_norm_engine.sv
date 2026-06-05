`timescale 1ns/1ps

module batch_norm_engine (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] moving_mean,
    output logic [WIDTH-1:0] moving_var,
    output logic [WIDTH-1:0] gamma,
    output logic [WIDTH-1:0] beta,
    output logic valid_out,
    output logic [WIDTH-1:0] data_out
);

endmodule
