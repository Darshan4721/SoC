`timescale 1ns/1ps

module avg_pool_engine (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [WINDOW_SIZE-1:0][WIDTH-1:0] window_data,
    output logic [3:0] actual_window,
    output logic valid_out,
    output logic [WIDTH-1:0] avg_out
);

endmodule
