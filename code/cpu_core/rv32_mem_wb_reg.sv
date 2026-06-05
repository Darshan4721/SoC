`timescale 1ns/1ps

module rv32_mem_wb_reg (
    input  logic clk,
    input  logic rst_n,
    output logic stall_i,
    output logic flush_i,
    output logic [31:0] alu_result_i,
    output logic [31:0] load_data_i,
    output logic [31:0] pc_plus4_i,
    output logic [4:0] rd_addr_i,
    output logic wb_en_i,
    output logic [1:0] wb_sel_i,
    output logic [31:0] alu_result_o,
    output logic [31:0] load_data_o,
    output logic [31:0] pc_plus4_o,
    output logic [4:0] rd_addr_o,
    output logic wb_en_o,
    output logic [1:0] wb_sel_o
);

endmodule
