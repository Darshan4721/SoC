`timescale 1ns/1ps

module pll_clock_generator (
    input  logic ref_clk,
    input  logic rst_n,
    output logic [7:0] mult_ratio,
    output logic [7:0] div_ratio,
    output logic pll_locked,
    input  logic clk_out
);

endmodule
