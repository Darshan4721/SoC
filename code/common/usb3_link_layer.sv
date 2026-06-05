`timescale 1ns/1ps

module usb3_link_layer (
    input  logic clk,
    input  logic rst_n,
    output logic tx_pkt_valid,
    output logic tx_pkt_ready,
    output logic [31:0] tx_pkt_data,
    output logic [31:0] pipe_tx_data,
    output logic [3:0] pipe_tx_datak,
    output logic [31:0] pipe_rx_data,
    output logic [3:0] pipe_rx_datak,
    output logic link_active
);

endmodule
