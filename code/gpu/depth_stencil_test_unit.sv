`timescale 1ns/1ps

module depth_stencil_test_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [31:0] pixel_z,
    output logic [7:0] pixel_stencil,
    output logic [31:0] fb_z,
    output logic [7:0] fb_stencil,
    output logic [2:0] depth_func,
    output logic depth_write_en,
    output logic valid_out,
    output logic test_passed,
    output logic [31:0] new_fb_z
);

endmodule
