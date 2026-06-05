`timescale 1ns/1ps

module gpu_rasterizer (
    input  logic clk,
    input  logic rst_n,
    output logic draw_cmd_valid,
    output logic [31:0] vertex_x0,
    output logic [31:0] vertex_y0,
    output logic [31:0] vertex_x1,
    output logic [31:0] vertex_y1,
    output logic [31:0] vertex_x2,
    output logic [31:0] vertex_y2,
    output logic draw_cmd_ready,
    output logic frag_valid,
    output logic [15:0] frag_x,
    output logic [15:0] frag_y,
    output logic [31:0] frag_bary_a,
    output logic [31:0] frag_bary_b,
    output logic [31:0] frag_bary_c,
    output logic frag_ready
);

endmodule
