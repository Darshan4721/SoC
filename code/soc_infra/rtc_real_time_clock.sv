`timescale 1ns/1ps

module rtc_real_time_clock (
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
    output logic rtc_alarm_irq
);

endmodule
