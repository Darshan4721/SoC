`timescale 1ns/1ps

module eth_tx_engine (
    input  logic clk,
    input  logic rst_n,
    output logic tx_dma_req,
    output logic tx_dma_ack,
    output logic [63:0] tx_dma_addr,
    output logic mem_rd_en,
    output logic [15:0] mem_rd_addr,
    output logic [31:0] mem_rd_data,
    output logic [7:0] gmii_txd,
    output logic gmii_tx_en,
    output logic gmii_tx_er
);

endmodule
