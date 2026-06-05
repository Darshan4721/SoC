`timescale 1ns/1ps

module address_gen_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [XLEN-1:0] rs1_data,
    output logic [XLEN-1:0] imm,
    output logic valid_out,
    output logic [XLEN-1:0] vaddr_out
);

endmodule
