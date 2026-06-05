`timescale 1ns/1ps

module gpu_rop_pipeline (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [31:0] src_color,
    output logic [31:0] dst_color,
    output logic blend_enable,
    output logic [3:0] blend_func_src,
    output logic [3:0] blend_func_dst,
    output logic depth_stencil_pass,
    output logic wr_valid,
    output logic [31:0] final_color
);

endmodule
