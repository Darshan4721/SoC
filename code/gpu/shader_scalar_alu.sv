`timescale 1ns/1ps

module shader_scalar_alu (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [3:0] op_type,
    output logic [31:0] src_a,
    output logic valid_out,
    output logic [31:0] dest
);

endmodule
