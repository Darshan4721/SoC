`timescale 1ns/1ps

module qspi_flash_controller (
    input  logic clk,
    input  logic rst_n,
    output logic s_arvalid,
    output logic s_arready,
    input  logic [31:0] s_araddr,
    input  logic [7:0] s_arlen,
    output logic s_rvalid,
    input  logic s_rready,
    input  logic [31:0] s_rdata,
    input  logic s_rlast,
    output logic qspi_sck,
    output logic qspi_cs_n,
    output wire  [3:0] qspi_dq
);

endmodule
