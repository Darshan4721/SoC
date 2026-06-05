`timescale 1ns/1ps

module av1_idct_2d (
    input  logic clk,
    input  logic rst_n,
    output logic coeff_valid,
    output logic [15:0] coeff_data,
    output logic coeff_start,
    output logic coeff_ready,
    output logic res_valid,
    output logic [15:0] res_data,
    output logic res_start,
    output logic res_ready
);

endmodule
