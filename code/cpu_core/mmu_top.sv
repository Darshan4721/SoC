`timescale 1ns/1ps

module mmu_top (
    input  logic clk,
    input  logic rst_n,
    output logic if_req,
    output logic [63:0] if_vaddr,
    output logic if_ack,
    output logic [55:0] if_paddr,
    output logic if_fault,
    output logic ls_req,
    output logic ls_is_store,
    output logic [63:0] ls_vaddr,
    output logic ls_ack,
    output logic [55:0] ls_paddr,
    output logic ls_fault,
    output logic [63:0] satp,
    output logic [63:0] mstatus,
    output logic [1:0] priv_mode,
    output logic ptw_req,
    output logic [55:0] ptw_addr,
    output logic ptw_ack,
    output logic [63:0] ptw_data
);

endmodule
