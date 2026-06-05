`timescale 1ns/1ps

module npu_systolic_array_128x128 (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [ARRAY_SIZE-1:0][ACT_WIDTH-1:0] act_in_left,
    output logic [ARRAY_SIZE-1:0][WGT_WIDTH-1:0] wgt_in_top,
    output logic valid_out,
    output logic [ARRAY_SIZE-1:0][P_SUM_WID-1:0] psum_out_bottom
);

endmodule
