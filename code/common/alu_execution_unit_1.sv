`timescale 1ns/1ps

module alu_execution_unit_1 (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [XLEN-1:0] rs1_data,
    output logic [XLEN-1:0] rs2_data,
    output logic [3:0] alu_op,
    output logic is_32bit,
    output logic valid_out,
    output logic [XLEN-1:0] result_out
);

endmodule
