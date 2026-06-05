`timescale 1ns/1ps

module pre_decode_unit (
    input  logic clk,
    input  logic rst_n,
    output logic fetch_valid,
    output logic [127:0] fetch_data,
    output logic [63:0] fetch_pc,
    output logic pre_decode_valid,
    output logic [31:0] instr_0,
    output logic [31:0] instr_1,
    output logic [31:0] instr_2,
    output logic [31:0] instr_3,
    output logic [3:0] is_compressed
);

endmodule
