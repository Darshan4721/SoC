`timescale 1ns/1ps

module hardware_page_walker (
    input  logic clk,
    input  logic rst_n,
    output logic walk_req,
    output logic [63:0] walk_vaddr,
    output logic [55:0] root_pt_base,
    output logic mem_req,
    output logic [55:0] mem_addr,
    output logic mem_ack,
    output logic [63:0] mem_data,
    output logic refill_valid,
    output logic [63:0] refill_vaddr,
    output logic [55:0] refill_paddr,
    output logic [9:0] refill_flags,
    output logic page_fault
);

endmodule
