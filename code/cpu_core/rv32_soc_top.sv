`timescale 1ns/1ps

module rv32_soc_top (
    input  logic clk,
    input  logic rst_n,
    output logic uart_rx_i,
    output logic uart_tx_o,
    output logic [7:0] gpio_in_i,
    output logic [7:0] gpio_out_o,
    output logic [7:0] gpio_dir_o,
    output logic halt_o
);

endmodule
