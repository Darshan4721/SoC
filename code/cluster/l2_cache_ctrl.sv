`timescale 1ns/1ps

module l2_cache_ctrl (
    input  logic clk,
    input  logic rst_n,
    output logic [0:3] core_req,
    output logic [2:0] [0:3] core_cmd,
    output logic [55:0] [0:3] core_addr,
    output logic [511:0] [0:3] core_tx_data,
    output logic [0:3] core_ack,
    output logic [511:0] [0:3] core_rx_data,
    output logic [0:3] snoop_req,
    output logic [2:0] [0:3] snoop_cmd,
    output logic [55:0] [0:3] snoop_addr,
    output logic [0:3] snoop_ack,
    output logic [511:0] [0:3] snoop_rx_data,
    output logic mem_req,
    output logic [2:0] mem_cmd,
    output logic [55:0] mem_addr,
    output logic [511:0] mem_tx_data,
    output logic mem_ack,
    output logic [511:0] mem_rx_data
);

endmodule
