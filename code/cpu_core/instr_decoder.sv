`timescale 1ns/1ps

module instr_decoder (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [31:0] instr,
    output logic valid_out,
    output logic [6:0] opcode,
    output logic [2:0] funct3,
    output logic [6:0] funct7,
    output logic [4:0] rd,
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [63:0] imm,
    output logic is_branch,
    output logic is_mem_load,
    output logic is_mem_store,
    output logic is_alu,
    output logic illegal_instr
);

endmodule
