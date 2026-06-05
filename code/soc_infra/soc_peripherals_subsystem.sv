`timescale 1ns/1ps

module soc_peripherals_subsystem (
    input  logic sys_clk,
    input  logic sys_rst_n,
    input  logic rtc_clk,
    input  logic rtc_rst_n,
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
    output logic [31:0] periph_irqs,
    output logic [31:0] gpio_out,
    output logic [31:0] gpio_in,
    output logic uart_tx,
    output logic uart_rx
);

endmodule
