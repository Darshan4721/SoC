`timescale 1ns/1ps

module dma_descriptor_fifo (
    input  logic clk,
    input  logic rst_n,
    output logic enqueue_valid,
    output logic [DESC_WIDTH-1:0] enqueue_data,
    output logic enqueue_ready,
    output logic dequeue_ready,
    output logic dequeue_valid,
    output logic [DESC_WIDTH-1:0] dequeue_data,
    output logic empty,
    output logic full
);

endmodule
