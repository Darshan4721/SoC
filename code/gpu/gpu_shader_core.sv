`timescale 1ns/1ps

module gpu_shader_core (
    input  logic clk,
    input  logic rst_n,
    output logic frag_valid,
    output logic [15:0] frag_x,
    output logic [15:0] frag_y,
    output logic [31:0] frag_bary_a,
    output logic [31:0] frag_bary_b,
    output logic [31:0] frag_bary_c,
    output logic frag_ready,
    output logic tex_req_valid,
    output logic [31:0] tex_u,
    output logic [31:0] tex_v,
    output logic tex_req_ready,
    output logic tex_resp_valid,
    output logic [31:0] tex_color,
    output logic rop_valid,
    output logic [15:0] rop_x,
    output logic [15:0] rop_y,
    output logic [31:0] rop_color,
    output logic [31:0] rop_depth,
    output logic rop_ready
);

endmodule
