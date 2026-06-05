`timescale 1ns/1ps

module axi4_async_bridge (
    input  logic s_clk,
    input  logic s_rst_n,
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
    input  logic m_clk,
    input  logic m_rst_n,
    input  logic m_awvalid,
    output logic m_awready,
    output logic [63:0] m_awaddr,
    input  logic m_wvalid,
    output logic m_wready,
    output logic [63:0] m_wdata,
    output logic m_bvalid,
    input  logic m_bready,
    output logic m_arvalid,
    output logic m_arready,
    output logic [63:0] m_araddr,
    output logic m_rvalid,
    input  logic m_rready,
    output logic [63:0] m_rdata
);

endmodule
