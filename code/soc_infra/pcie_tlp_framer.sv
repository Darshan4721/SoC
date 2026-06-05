`timescale 1ns/1ps

module pcie_tlp_framer (
    input  logic clk,
    input  logic rst_n,
    output logic tx_tlp_valid,
    output logic tx_tlp_ready,
    output logic [255:0] tx_tlp_data,
    output logic dll_tx_valid,
    output logic dll_tx_ready,
    output logic [255:0] dll_tx_data,
    output logic [3:0] dll_tx_keep,
    output logic dll_tx_last
);

endmodule
