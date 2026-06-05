`timescale 1ns/1ps

module jtlb_core (
    input  logic clk,
    input  logic rst_n,
    output logic itlb_req,
    output logic [63:0] itlb_vaddr,
    output logic itlb_ack,
    output logic itlb_hit,
    output logic [55:0] itlb_paddr,
    output logic [9:0] itlb_flags,
    output logic dtlb_req,
    output logic [63:0] dtlb_vaddr,
    output logic dtlb_ack,
    output logic dtlb_hit,
    output logic [55:0] dtlb_paddr,
    output logic [9:0] dtlb_flags,
    output logic refill_valid,
    output logic [63:0] refill_vaddr,
    output logic [55:0] refill_paddr,
    output logic [9:0] refill_flags,
    output logic flush_jtlb
);

endmodule
