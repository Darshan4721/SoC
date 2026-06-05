`timescale 1ns/1ps

module dispatch_unit_4way (
    input  logic clk,
    input  logic rst_n,
    output logic [0:3] ren_valid,
    output logic [31:0] [0:3] ren_instr,
    output logic [6:0] [0:3] ren_phys_rd,
    output logic [3:0] rs_alu_ready,
    output logic rs_mem_ready,
    output logic rs_br_ready,
    output logic rs_fpu_ready,
    output logic [2:0] rob_free_slots,
    output logic [0:3] disp_valid,
    output logic [2:0] [0:3] disp_dest,
    output logic stall_pipeline
);

endmodule
