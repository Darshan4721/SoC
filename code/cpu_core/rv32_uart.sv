`timescale 1ns/1ps

module rv32_uart (
    input  logic clk,
    input  logic rst_n,
    output logic req_i,
    output logic we_i,
    output logic [3:0] be_i,
    output logic [31:0] addr_i,
    output logic [31:0] wdata_i,
    output logic [31:0] rdata_o,
    output logic ready_o,
    output logic uart_rx_i,
    output logic uart_tx_o
);

endmodule
