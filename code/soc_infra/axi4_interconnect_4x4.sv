`timescale 1ns/1ps

module axi4_interconnect_4x4 (
    input  logic clk,
    input  logic rst_n,
    input  logic [3:0] s_awvalid,
    output logic [3:0] s_awready,
    input  logic [63:0] [0:3] s_awaddr,
    input  logic [3:0] s_wvalid,
    output logic [3:0] s_wready,
    input  logic [63:0] [0:3] s_wdata,
    output logic [3:0] s_bvalid,
    input  logic [3:0] s_bready,
    output logic [3:0] s_arvalid,
    output logic [3:0] s_arready,
    input  logic [63:0] [0:3] s_araddr,
    output logic [3:0] s_rvalid,
    input  logic [3:0] s_rready,
    input  logic [63:0] [0:3] s_rdata,
    input  logic [3:0] m_awvalid,
    output logic [3:0] m_awready,
    output logic [63:0] [0:3] m_awaddr,
    input  logic [3:0] m_wvalid,
    output logic [3:0] m_wready,
    output logic [63:0] [0:3] m_wdata,
    output logic [3:0] m_bvalid,
    input  logic [3:0] m_bready,
    output logic [3:0] m_arvalid,
    output logic [3:0] m_arready,
    output logic [63:0] [0:3] m_araddr,
    output logic [3:0] m_rvalid,
    input  logic [3:0] m_rready,
    output logic [63:0] [0:3] m_rdata
);

endmodule
