`timescale 1ns/1ps

module branch_execution_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [XLEN-1:0] pc,
    output logic [XLEN-1:0] rs1_data,
    output logic [XLEN-1:0] rs2_data,
    output logic [XLEN-1:0] imm,
    output logic [2:0] br_type,
    output logic is_jal,
    output logic is_jalr,
    output logic is_branch,
    output logic is_compressed,
    output logic valid_out,
    output logic branch_taken,
    output logic [XLEN-1:0] target_addr,
    output logic [XLEN-1:0] link_addr
);

endmodule
