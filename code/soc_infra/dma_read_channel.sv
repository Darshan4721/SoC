`timescale 1ns/1ps

module dma_read_channel (
    input  logic clk,
    input  logic rst_n,
    output logic start_req,
    output logic [63:0] src_addr,
    output logic [31:0] xfer_length,
    output logic done,
    output logic arvalid,
    output logic arready,
    output logic [63:0] araddr,
    output logic [7:0] arlen,
    output logic rvalid,
    input  logic rready,
    output logic [63:0] rdata,
    output logic rlast,
    output logic fifo_wr_en,
    output logic [63:0] fifo_wr_data,
    output logic fifo_full
);

endmodule
