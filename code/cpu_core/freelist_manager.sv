`timescale 1ns/1ps

module freelist_manager (
    input  logic clk,
    input  logic rst_n,
    output logic [2:0] alloc_req_count,
    output logic [2:0] alloc_grant_count,
    output logic [6:0] [0:ALLOC_WIDTH-1] alloc_phys_regs,
    output logic [2:0] free_req_count,
    output logic [6:0] [0:FREE_WIDTH-1] free_phys_regs,
    output logic recover_valid,
    output logic [PHYS_REGS-1:0] recovery_freelist_state
);

endmodule
