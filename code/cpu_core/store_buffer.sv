`timescale 1ns/1ps

module store_buffer (
    input  logic clk,
    input  logic rst_n,
    output logic commit_req,
    output logic [63:0] commit_addr,
    output logic [63:0] commit_data,
    output logic [1:0] commit_size,
    output logic sb_ready,
    output logic dcache_wr_req,
    output logic [63:0] dcache_wr_addr,
    output logic [63:0] dcache_wr_data,
    output logic [7:0] dcache_wr_be,
    output logic dcache_wr_ack
);

endmodule
