`timescale 1ns/1ps

module pad_ring_mux (
    input  logic clk,
    input  logic rst_n,
    input  logic s_awvalid,
    output logic s_awready,
    input  logic [31:0] s_awaddr,
    input  logic s_wvalid,
    output logic s_wready,
    input  logic [31:0] s_wdata,
    output logic s_bvalid,
    input  logic s_bready,
    output logic s_arvalid,
    output logic s_arready,
    input  logic [31:0] s_araddr,
    output logic s_rvalid,
    input  logic s_rready,
    input  logic [31:0] s_rdata,
    output logic [31:0] gpio_out,
    output logic [31:0] gpio_in,
    output logic uart_tx,
    output logic uart_rx,
    output logic spi_sck,
    output logic spi_mosi,
    output logic spi_miso,
    output logic [3:0] spi_ss_n,
    output wire  [NUM_PADS-1:0] pads
);

endmodule
