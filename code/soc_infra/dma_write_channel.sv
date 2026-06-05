`timescale 1ns/1ps

module dma_write_channel (
    input  logic clk,
    input  logic rst_n,
    output logic start_req,
    output logic [63:0] dst_addr,
    output logic [31:0] xfer_length,
    output logic done,
    input  logic awvalid,
    output logic awready,
    output logic [63:0] awaddr,
    output logic [7:0] awlen,
    input  logic wvalid,
    output logic wready,
    output logic [63:0] wdata,
    output logic wlast,
    output logic bvalid,
    input  logic bready,
    output logic fifo_rd_en,
    output logic [63:0] fifo_rd_data,
    output logic fifo_empty
);

endmodule
