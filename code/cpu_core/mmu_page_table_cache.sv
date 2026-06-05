`timescale 1ns/1ps

module mmu_page_table_cache (
    input  logic clk,
    input  logic rst_n,
    output logic flush,
    output logic read_valid,
    output logic [PPN_WIDTH-1:0] read_ppn,
    output logic hit,
    output logic [PTE_WIDTH-1:0] pte_data,
    output logic write_en,
    output logic [PPN_WIDTH-1:0] write_ppn,
    output logic [PTE_WIDTH-1:0] write_pte_data
);

endmodule
