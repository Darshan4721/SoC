`timescale 1ns/1ps

module shader_vector_alu (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [3:0] op_type,
    output logic [127:0] src_a,
    output logic [127:0] src_b,
    output logic [127:0] src_c,
    output logic valid_out,
    output logic [127:0] dest
);

endmodule
