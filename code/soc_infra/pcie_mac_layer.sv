`timescale 1ns/1ps

module pcie_mac_layer (
    input  logic clk,
    input  logic rst_n,
    output logic mac_tx_valid,
    output logic mac_tx_ready,
    output logic [255:0] mac_tx_data,
    output logic mac_rx_valid,
    output logic mac_rx_ready,
    output logic [255:0] mac_rx_data,
    output logic [31:0] [0:15] pipe_tx_data,
    output logic [3:0] [0:15] pipe_tx_datak,
    output logic [31:0] [0:15] pipe_rx_data,
    output logic [3:0] [0:15] pipe_rx_datak,
    output logic link_up
);

endmodule
