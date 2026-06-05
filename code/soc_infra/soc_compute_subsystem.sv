`timescale 1ns/1ps

module soc_compute_subsystem (
    input  logic clk,
    input  logic rst_n,
    output logic m_ext_irq,
    input  logic s_ext_irq,
    output logic timer_irq,
    input  logic m_awvalid,
    output logic m_awready,
    output logic [63:0] m_awaddr,
    output logic [7:0] m_awlen,
    input  logic m_wvalid,
    output logic m_wready,
    output logic [63:0] m_wdata,
    output logic [7:0] m_wstrb,
    output logic m_wlast,
    output logic m_bvalid,
    input  logic m_bready,
    output logic m_arvalid,
    output logic m_arready,
    output logic [63:0] m_araddr,
    output logic [7:0] m_arlen,
    output logic m_rvalid,
    input  logic m_rready,
    output logic [63:0] m_rdata,
    output logic m_rlast
);

endmodule
