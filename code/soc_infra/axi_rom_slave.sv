`timescale 1ns/1ps

module axi_rom_slave (
    input  logic clk,
    input  logic rst_n,
    output logic s_arvalid,
    output logic s_arready,
    input  logic [63:0] s_araddr,
    input  logic [7:0] s_arlen,
    output logic s_rvalid,
    input  logic s_rready,
    input  logic [63:0] s_rdata,
    input  logic s_rlast
);

endmodule
