`timescale 1ns/1ps

module fetch_buffer (
    input  logic clk,
    input  logic rst_n,
    output logic flush,
    output logic push,
    output logic [FETCH_WIDTH-1:0] fetch_data_in,
    output logic [63:0] pc_in,
    output logic full,
    output logic pop,
    output logic [FETCH_WIDTH-1:0] fetch_data_out,
    output logic [63:0] pc_out,
    output logic empty
);

endmodule
