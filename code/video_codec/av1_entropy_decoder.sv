`timescale 1ns/1ps

module av1_entropy_decoder (
    input  logic clk,
    input  logic rst_n,
    output logic bs_valid,
    output logic [31:0] bs_data,
    output logic bs_ready,
    output logic sym_valid,
    output logic [15:0] sym_coeff,
    output logic [7:0] sym_run,
    output logic [1:0] sym_type,
    output logic sym_ready
);

endmodule
