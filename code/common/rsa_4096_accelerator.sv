`timescale 1ns/1ps

module rsa_4096_accelerator (
    input  logic clk,
    input  logic rst_n,
    output logic start,
    output logic ready,
    output logic done,
    output logic mem_rd_en,
    output logic [7:0] mem_rd_addr,
    output logic [63:0] mem_rd_data,
    output logic mem_wr_en,
    output logic [7:0] mem_wr_addr,
    output logic [63:0] mem_wr_data,
    output logic [7:0] addr_base,
    output logic [7:0] addr_modulus,
    output logic [7:0] addr_exponent,
    output logic [7:0] addr_result
);

endmodule
