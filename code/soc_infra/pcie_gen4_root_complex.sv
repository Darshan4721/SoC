`timescale 1ns/1ps

module pcie_gen4_root_complex (
    input  logic clk,
    input  logic rst_n,
    input  logic s_awvalid,
    output logic s_awready,
    input  logic [63:0] s_awaddr,
    input  logic s_wvalid,
    output logic s_wready,
    input  logic [63:0] s_wdata,
    output logic s_bvalid,
    input  logic s_bready,
    output logic s_arvalid,
    output logic s_arready,
    input  logic [63:0] s_araddr,
    output logic s_rvalid,
    input  logic s_rready,
    input  logic [63:0] s_rdata,
    output logic tx_tlp_valid,
    output logic tx_tlp_ready,
    output logic [255:0] tx_tlp_data,
    output logic rx_tlp_valid,
    output logic rx_tlp_ready,
    output logic [255:0] rx_tlp_data
);

endmodule
