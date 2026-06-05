`timescale 1ns/1ps

module rob_memory_array (
    input  logic clk,
    input  logic rst_n,
    output logic [0:3] alloc_valid,
    output logic [$clog2(ROB_ENTRIES)-1:0] [0:3] alloc_idx,
    output logic [6:0] [0:3] alloc_prd,
    output logic [6:0] [0:3] alloc_prev_prd,
    output logic [3:0] cdb_valid,
    output logic [$clog2(ROB_ENTRIES)-1:0] [0:3] cdb_rob_idx,
    output logic [0:3] cdb_exception,
    output logic [$clog2(ROB_ENTRIES)-1:0] [0:3] commit_idx,
    output logic [0:3] commit_ready,
    output logic [6:0] [0:3] commit_prd,
    output logic [6:0] [0:3] commit_prev_prd,
    output logic [0:3] commit_exception
);

endmodule
