`timescale 1ns/1ps

module usb3_protocol_layer (
    input  logic clk,
    input  logic rst_n,
    output logic ep_tx_req,
    output logic [7:0] ep_tx_num,
    output logic [63:0] ep_tx_data,
    output logic ep_tx_ack,
    output logic tx_pkt_valid,
    output logic tx_pkt_ready,
    output logic [31:0] tx_pkt_data
);

endmodule
