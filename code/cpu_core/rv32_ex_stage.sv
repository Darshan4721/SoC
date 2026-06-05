`timescale 1ns/1ps

module rv32_ex_stage (
    output logic [31:0] pc_i,
    output logic [4:0] rs1_addr_i,
    output logic [4:0] rs2_addr_i,
    output logic [31:0] rs1_data_i,
    output logic [31:0] rs2_data_i,
    output logic [31:0] imm_i,
    output logic [1:0] op_a_sel_i,
    output logic [1:0] op_b_sel_i,
    output logic [3:0] alu_op_i,
    output logic [2:0] branch_type_i,
    output logic [1:0] jump_type_i,
    output logic ex_mem_can_forward_i,
    output logic [4:0] ex_mem_rd_i,
    output logic [31:0] ex_mem_fwd_data_i,
    output logic mem_wb_regwrite_i,
    output logic [4:0] mem_wb_rd_i,
    output logic [31:0] mem_wb_fwd_data_i,
    output logic [31:0] alu_result_o,
    output logic [31:0] store_data_o,
    output logic [31:0] pc_plus4_o,
    output logic redirect_o,
    output logic [31:0] redirect_pc_o
);

endmodule
