`timescale 1ns/1ps

module usb3_xhci_controller (
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
    output logic ep_tx_req,
    output logic [7:0] ep_tx_num,
    output logic [63:0] ep_tx_data,
    output logic ep_tx_ack
);

endmodule
