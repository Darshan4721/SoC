`timescale 1ns/1ps

module register_rename_unit (
    input  logic clk,
    input  logic rst_n,
    output logic [0:3] dec_valid,
    output logic [4:0] [0:3] dec_rs1,
    output logic [4:0] [0:3] dec_rs2,
    output logic [4:0] [0:3] dec_rd,
    output logic [0:3] dec_we,
    output logic [4:0] [0:3] rat_rd,
    output logic [6:0] [0:3] rat_alloc_prd,
    output logic [0:3] rat_we,
    output logic [6:0] [0:3] rat_prs1,
    output logic [6:0] [0:3] rat_prs2,
    output logic [6:0] [0:3] rat_prev_prd,
    output logic [2:0] fl_req_count,
    output logic [2:0] fl_grant_count,
    output logic [6:0] [0:3] fl_phys_regs,
    output logic [0:3] ren_valid,
    output logic [6:0] [0:3] ren_phys_rs1,
    output logic [6:0] [0:3] ren_phys_rs2,
    output logic [6:0] [0:3] ren_phys_rd,
    output logic [6:0] [0:3] ren_prev_phys_rd,
    output logic stall_pipeline
);

endmodule
