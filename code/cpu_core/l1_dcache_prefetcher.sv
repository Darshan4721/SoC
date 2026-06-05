`timescale 1ns/1ps

module l1_dcache_prefetcher (
    input  logic clk,
    input  logic rst_n,
    output logic miss_valid,
    output logic [55:0] miss_paddr,
    output logic prefetch_req,
    output logic [55:0] prefetch_paddr,
    output logic prefetch_ack
);

endmodule
