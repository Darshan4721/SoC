`timescale 1ns/1ps

module tournament_predictor (
    input  logic clk,
    input  logic rst_n,
    output logic [63:0] fetch_pc,
    output logic predict_taken,
    output logic update_valid,
    output logic [63:0] update_pc,
    output logic actual_taken
);

endmodule
