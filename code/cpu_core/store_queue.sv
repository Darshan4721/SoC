`timescale 1ns/1ps

module store_queue (
    input  logic clk,
    input  logic rst_n,
    output logic alloc_valid,
    output logic [$clog2(SQ_ENTRIES)-1:0] alloc_idx,
    output logic sq_full,
    output logic addr_valid,
    output logic [$clog2(SQ_ENTRIES)-1:0] addr_idx,
    output logic [63:0] addr_val,
    output logic [1:0] size,
    output logic data_valid,
    output logic [$clog2(SQ_ENTRIES)-1:0] data_idx,
    output logic [63:0] data_val,
    output logic commit_valid,
    output logic [$clog2(SQ_ENTRIES)-1:0] commit_idx,
    output logic commit_req,
    output logic [63:0] commit_addr,
    output logic [63:0] commit_data,
    output logic [1:0] commit_size,
    output logic sb_ready
);

endmodule
