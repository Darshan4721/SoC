`timescale 1ns/1ps

module rv32_regfile (
    input  logic clk,
    input  logic rst_n,
    output logic we_i,
    output logic [4:0] waddr_i,
    output logic [31:0] wdata_i,
    output logic [4:0] raddr1_i,
    output logic [31:0] rdata1_o,
    output logic [4:0] raddr2_i,
    output logic [31:0] rdata2_o
);

endmodule
