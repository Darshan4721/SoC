`timescale 1ns/1ps

module pcie_data_link_layer (
    input  logic clk,
    input  logic rst_n,
    output logic tx_tlp_valid,
    output logic tx_tlp_ready,
    output logic [255:0] tx_tlp_data,
    output logic [3:0] tx_tlp_keep,
    output logic tx_tlp_last,
    output logic mac_tx_valid,
    output logic mac_tx_ready,
    output logic [255:0] mac_tx_data,
    output logic mac_rx_valid,
    output logic mac_rx_ready,
    output logic [255:0] mac_rx_data
);

endmodule
