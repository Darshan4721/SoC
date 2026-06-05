`timescale 1ns/1ps

module dma_descriptor_fetch (
    input  logic clk,
    input  logic rst_n,
    output logic fetch_start,
    output logic [63:0] ring_base_addr,
    output logic arvalid,
    output logic arready,
    output logic [63:0] araddr,
    output logic rvalid,
    input  logic rready,
    output logic [63:0] rdata,
    output logic desc_valid,
    output logic [63:0] desc_src_addr,
    output logic [63:0] desc_dst_addr,
    output logic [31:0] desc_length,
    output logic desc_ready
);

endmodule
