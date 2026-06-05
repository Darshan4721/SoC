`timescale 1ns/1ps

module av1_intra_predictor (
    input  logic clk,
    input  logic rst_n,
    output logic pred_start,
    output logic [3:0] pred_mode,
    output logic [2:0] block_size,
    output logic [7:0] [0:31] top_pixels,
    output logic [7:0] [0:31] left_pixels,
    output logic [7:0] top_left_pixel,
    output logic pred_valid,
    output logic [7:0] pred_pixel,
    output logic pred_done,
    output logic pred_ready
);

endmodule
