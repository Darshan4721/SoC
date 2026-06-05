`timescale 1ns/1ps

module mul_div_execution_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic ready,
    output logic [XLEN-1:0] rs1_data,
    output logic [XLEN-1:0] rs2_data,
    output logic [2:0] op_type,
    output logic is_32bit,
    output logic valid_out,
    output logic [XLEN-1:0] result_out
);

endmodule
