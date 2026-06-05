`timescale 1ns/1ps

module uart_rx (
    input  logic clk,
    input  logic rst_n,
    output logic rx_i,
    output logic baud_tick_i,
    output logic [7:0] data_o,
    output logic valid_o
);

endmodule
