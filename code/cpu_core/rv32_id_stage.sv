`timescale 1ns/1ps

module rv32_id_stage (
    input  logic clk,
    input  logic rst_n,
    output logic [31:0] pc_i,
    output logic [31:0] instr_i,
    output logic wb_we_i,
    output logic [4:0] wb_rd_i,
    output logic [31:0] wb_data_i,
    output logic [4:0] rs1_addr_o,
    output logic [4:0] rs2_addr_o,
    output logic [4:0] rd_addr_o,
    output logic [31:0] rs1_data_o,
    output logic [31:0] rs2_data_o,
    output logic [31:0] imm_o,
    output logic [1:0] op_a_sel_o,
    output logic [1:0] op_b_sel_o,
    output logic [3:0] alu_op_o,
    output logic [2:0] branch_type_o,
    output logic [1:0] jump_type_o,
    output logic mem_req_o,
    output logic mem_we_o,
    output logic [1:0] mem_size_o,
    output logic mem_unsigned_o,
    output logic wb_en_o,
    output logic [1:0] wb_sel_o,
    output logic rs1_used_o,
    output logic rs2_used_o,
    output logic illegal_instr_o
);

endmodule
