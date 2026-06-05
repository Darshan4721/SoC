`timescale 1ns/1ps

module gpu_rasterizer_core (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [31:0] v0_x,
    output logic v0_y,
    output logic [31:0] v1_x,
    output logic v1_y,
    output logic [31:0] v2_x,
    output logic v2_y,
    output logic [31:0] bounding_box_min_x,
    output logic [31:0] bounding_box_min_y,
    output logic [31:0] bounding_box_max_x,
    output logic [31:0] bounding_box_max_y,
    output logic ready_out,
    output logic pixel_valid,
    output logic [31:0] pixel_x,
    output logic [31:0] pixel_y,
    output logic [31:0] bary_alpha,
    output logic [31:0] bary_beta,
    output logic [31:0] bary_gamma,
    output logic pixel_ready
);

endmodule
