`timescale 1ns/1ps

module rv32_if_id_reg (
    input  logic clk,
    input  logic rst_n,
    output logic stall_i,
    output logic flush_i,
    output logic [31:0] pc_i,
    output logic [31:0] instr_i,
    output logic [31:0] pc_o,
    output logic [31:0] instr_o
);

endmodule
