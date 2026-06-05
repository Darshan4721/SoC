`timescale 1ns/1ps

module load_queue (
    input  logic clk,
    input  logic rst_n,
    output logic alloc_valid,
    output logic [$clog2(LQ_ENTRIES)-1:0] alloc_idx,
    output logic lq_full,
    output logic addr_valid,
    output logic [$clog2(LQ_ENTRIES)-1:0] addr_idx,
    output logic [63:0] addr_val,
    output logic [1:0] size,
    output logic load_rsp_valid,
    output logic [$clog2(LQ_ENTRIES)-1:0] load_rsp_idx,
    output logic [63:0] load_rsp_data,
    output logic commit_valid,
    output logic [$clog2(LQ_ENTRIES)-1:0] commit_idx
);

endmodule
