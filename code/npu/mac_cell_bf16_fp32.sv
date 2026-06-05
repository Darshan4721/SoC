`timescale 1ns/1ps

module mac_cell_bf16_fp32 (
    input  logic clk,
    input  logic rst_n,
    output logic mode,
    output logic [31:0] act_in,
    output logic [31:0] wgt_in,
    output logic [31:0] psum_in,
    input  logic valid_in,
    output logic [31:0] psum_out,
    output logic valid_out
);

endmodule
