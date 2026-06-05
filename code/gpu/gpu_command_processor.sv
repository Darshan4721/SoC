`timescale 1ns/1ps

module gpu_command_processor (
    input  logic clk,
    input  logic rst_n,
    output logic arvalid,
    output logic arready,
    output logic [63:0] araddr,
    output logic rvalid,
    input  logic rready,
    output logic [31:0] rdata,
    output logic draw_cmd_valid,
    output logic [31:0] vertex_x0,
    output logic [31:0] vertex_y0,
    output logic [31:0] vertex_x1,
    output logic [31:0] vertex_y1,
    output logic [31:0] vertex_x2,
    output logic [31:0] vertex_y2,
    output logic draw_cmd_ready
);

endmodule
