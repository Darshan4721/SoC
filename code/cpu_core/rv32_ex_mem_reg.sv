`timescale 1ns/1ps

module rv32_ex_mem_reg (
    input  logic clk,
    input  logic rst_n,
    output logic stall_i,
    output logic flush_i,
    output logic [31:0] alu_result_i,
    output logic [31:0] store_data_i,
    output logic [31:0] pc_plus4_i,
    output logic [4:0] rd_addr_i,
    output logic mem_req_i,
    output logic mem_we_i,
    output logic [1:0] mem_size_i,
    output logic mem_unsigned_i,
    output logic wb_en_i,
    output logic [1:0] wb_sel_i,
    output logic [31:0] alu_result_o,
    output logic [31:0] store_data_o,
    output logic [31:0] pc_plus4_o,
    output logic [4:0] rd_addr_o,
    output logic mem_req_o,
    output logic mem_we_o,
    output logic [1:0] mem_size_o,
    output logic mem_unsigned_o,
    output logic wb_en_o,
    output logic [1:0] wb_sel_o
);

endmodule
