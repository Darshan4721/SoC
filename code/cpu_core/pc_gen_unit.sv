`timescale 1ns/1ps

module pc_gen_unit (
    input  logic clk,
    input  logic rst_n,
    output logic stall,
    output logic bp_taken,
    output logic [63:0] bp_target,
    output logic trap_valid,
    output logic [63:0] trap_target,
    output logic branch_resolved,
    output logic branch_mispredicted,
    output logic [63:0] branch_correct_target,
    output logic [63:0] current_pc,
    output logic [63:0] next_pc
);

endmodule
