`timescale 1ns/1ps
module address_generation_unit #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Interface from LSQ
    input  logic                  agu_req_val,
    input  logic                  agu_is_store,
    input  logic [DATA_WIDTH-1:0] agu_rs1_data, // Base Address
    input  logic [DATA_WIDTH-1:0] agu_rs2_data, // Store Data
    input  logic [11:0]           agu_imm,      // Offset
    input  logic [6:0]            agu_rd,
    output logic                  agu_req_rdy,
    
    // Interface to TLB
    output logic                  tlb_req_val,
    output logic                  tlb_is_store,
    output logic [ADDR_WIDTH-1:0] tlb_virt_addr,
    output logic [DATA_WIDTH-1:0] tlb_store_data,
    output logic [6:0]            tlb_rd,
    input  logic                  tlb_req_rdy
);

    // Simple Combinatorial AGU: Virtual Address = Base + Sign-Extended Immediate
    logic [ADDR_WIDTH-1:0] generated_vaddr;
    logic [ADDR_WIDTH-1:0] sign_ext_imm;
    
    assign sign_ext_imm = {{52{agu_imm[11]}}, agu_imm};
    assign generated_vaddr = agu_rs1_data + sign_ext_imm;
    
    assign tlb_req_val = agu_req_val;
    assign tlb_is_store = agu_is_store;
    assign tlb_virt_addr = generated_vaddr;
    assign tlb_store_data = agu_rs2_data;
    assign tlb_rd = agu_rd;
    
    assign agu_req_rdy = tlb_req_rdy;

endmodule
