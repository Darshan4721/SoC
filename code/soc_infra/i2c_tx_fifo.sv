`timescale 1ns/1ps

module i2c_tx_fifo (
    input  logic clk,
    input  logic rst_n,
    output logic write_en,
    output logic [7:0] write_data,
    output logic full,
    output logic read_en,
    output logic [7:0] read_data,
    output logic empty
);

endmodule
