`timescale 1ns/1ps

module branch_target_buffer (
    input  logic clk,
    input  logic rst_n,
    output logic lookup_valid,
    output logic [PC_WIDTH-1:0] pc_in,
    output logic hit,
    output logic [PC_WIDTH-1:0] predicted_target,
    output logic update_valid,
    output logic [PC_WIDTH-1:0] update_pc,
    output logic [PC_WIDTH-1:0] update_target
);

endmodule
