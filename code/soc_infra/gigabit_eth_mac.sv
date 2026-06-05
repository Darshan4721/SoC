`timescale 1ns/1ps

module gigabit_eth_mac (
    input  logic clk,
    input  logic rst_n,
    input  logic s_awvalid,
    output logic s_awready,
    input  logic [63:0] s_awaddr,
    input  logic s_wvalid,
    output logic s_wready,
    input  logic [63:0] s_wdata,
    output logic s_bvalid,
    input  logic s_bready,
    output logic s_arvalid,
    output logic s_arready,
    input  logic [63:0] s_araddr,
    output logic s_rvalid,
    input  logic s_rready,
    input  logic [63:0] s_rdata,
    output logic tx_dma_req,
    output logic tx_dma_ack,
    output logic [63:0] tx_dma_addr,
    output logic [7:0] gmii_txd,
    output logic gmii_tx_en,
    output logic gmii_tx_er,
    output logic [7:0] gmii_rxd,
    output logic gmii_rx_dv,
    output logic gmii_rx_er,
    output logic mdc,
    output wire mdio
);

endmodule
