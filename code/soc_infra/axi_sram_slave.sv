`timescale 1ns/1ps

module axi_sram_slave (
    input  logic clk,
    input  logic rst_n,
    input  logic s_awvalid,
    output logic s_awready,
    input  logic [63:0] s_awaddr,
    input  logic [7:0] s_awlen,
    input  logic s_wvalid,
    output logic s_wready,
    input  logic [63:0] s_wdata,
    input  logic [7:0] s_wstrb,
    input  logic s_wlast,
    output logic s_bvalid,
    input  logic s_bready,
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
