`timescale 1ns/1ps

module instr_prefetcher (
    input  logic clk,
    input  logic rst_n,
    output logic [63:0] current_pc,
    output logic icache_miss,
    output logic prefetch_req,
    output logic [63:0] prefetch_addr,
    output logic prefetch_ack
);

endmodule
