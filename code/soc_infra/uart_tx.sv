`timescale 1ns/1ps

module uart_tx (
    input  logic clk,
    input  logic rst_n,
    output logic start_i,
    output logic [7:0] data_i,
    output logic baud_tick_i,
    output logic tx_o,
    output logic busy_o,
    output logic done_o
);

endmodule
