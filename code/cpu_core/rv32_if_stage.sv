`timescale 1ns/1ps

module rv32_if_stage (
    input  logic clk,
    input  logic rst_n,
    output logic stall_i,
    output logic redirect_i,
    output logic [31:0] redirect_pc_i,
    output logic [31:0] imem_rdata_i,
    output logic imem_ready_i,
    output logic imem_req_o,
    output logic [31:0] imem_addr_o,
    output logic [31:0] pc_o,
    output logic [31:0] instr_o
);

endmodule
