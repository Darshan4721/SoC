`timescale 1ns/1ps

module micro_op_sequencer (
    input  logic clk,
    input  logic rst_n,
    output logic decode_valid,
    output logic [31:0] decode_instr,
    output logic uop_valid,
    output logic [63:0] uop_ctrl,
    output logic uop_is_last
);

endmodule
