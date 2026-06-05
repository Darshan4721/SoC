`timescale 1ns/1ps

module reorder_buffer_ctrl (
    input  logic clk,
    input  logic rst_n,
    output logic [2:0] disp_count,
    output logic [2:0] rob_free_slots,
    output logic [$clog2(ROB_ENTRIES)-1:0] [0:3] alloc_idx,
    output logic [2:0] commit_count,
    output logic [$clog2(ROB_ENTRIES)-1:0] [0:3] commit_idx,
    output logic flush_valid
);

endmodule
