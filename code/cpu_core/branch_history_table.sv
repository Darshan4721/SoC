`timescale 1ns/1ps

module branch_history_table (
    input  logic clk,
    input  logic rst_n,
    output logic lookup_valid,
    output logic [PC_WIDTH-1:0] pc_in,
    output logic prediction,
    output logic update_valid,
    output logic [PC_WIDTH-1:0] update_pc,
    output logic update_taken
);

endmodule
