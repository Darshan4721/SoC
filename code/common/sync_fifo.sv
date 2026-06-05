`timescale 1ns/1ps

module sync_fifo (
    input  logic clk,
    input  logic rst_n,
    output logic push,
    output logic [DATA_WIDTH-1:0] data_in,
    output logic full,
    output logic almost_full,
    output logic pop,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic empty,
    output logic almost_empty
);

endmodule
