`timescale 1ns/1ps

module memory_disambiguation_unit (
    input  logic clk,
    input  logic rst_n,
    output logic load_valid,
    output logic [XLEN-1:0] load_addr,
    output logic [2:0] load_size,
    output logic [SQ_ENTRIES-1:0] sq_valid,
    output logic [XLEN-1:0] [0:SQ_ENTRIES-1] sq_addr,
    output logic [XLEN-1:0] [0:SQ_ENTRIES-1] sq_data,
    output logic [7:0] [0:SQ_ENTRIES-1] sq_mask,
    output logic [SQ_ENTRIES-1:0] sq_older_than_load,
    output logic stall_load,
    output logic forward_valid,
    output logic [XLEN-1:0] forward_data
);

endmodule
