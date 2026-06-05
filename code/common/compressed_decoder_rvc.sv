`timescale 1ns/1ps

module compressed_decoder_rvc (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [15:0] instr_c,
    output logic valid_out,
    output logic [31:0] instr_32,
    output logic illegal_c_instr
);

endmodule
