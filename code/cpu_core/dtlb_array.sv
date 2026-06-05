`timescale 1ns/1ps

module dtlb_array (
    input  logic clk,
    input  logic rst_n,
    output logic req_valid,
    output logic is_store,
    output logic [63:0] vaddr,
    output logic hit,
    output logic [55:0] paddr,
    output logic fault,
    output logic refill_valid,
    output logic [63:0] refill_vaddr,
    output logic [55:0] refill_paddr,
    output logic [9:0] refill_pte_flags,
    output logic flush_tlb
);

endmodule
