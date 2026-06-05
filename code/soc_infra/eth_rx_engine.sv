`timescale 1ns/1ps

module eth_rx_engine (
    input  logic clk,
    input  logic rst_n,
    output logic [7:0] gmii_rxd,
    output logic gmii_rx_dv,
    output logic gmii_rx_er,
    output logic mem_wr_en,
    output logic [15:0] mem_wr_addr,
    output logic [31:0] mem_wr_data,
    output logic rx_frame_done,
    output logic rx_fcs_error
);

endmodule
