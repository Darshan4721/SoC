`timescale 1ns/1ps

module soc_media_subsystem (
    input  logic clk,
    input  logic rst_n,
    input  logic s_awvalid,
    output logic s_awready,
    input  logic [63:0] s_awaddr,
    input  logic s_wvalid,
    output logic s_wready,
    input  logic [31:0] s_wdata,
    output logic s_bvalid,
    input  logic s_bready,
    output logic s_arvalid,
    output logic s_arready,
    input  logic [63:0] s_araddr,
    output logic s_rvalid,
    input  logic s_rready,
    input  logic [31:0] s_rdata,
    output logic gpu_m_arvalid,
    output logic gpu_m_arready,
    output logic [63:0] gpu_m_araddr,
    output logic [7:0] gpu_m_arlen,
    output logic gpu_m_rvalid,
    input  logic gpu_m_rready,
    output logic [63:0] gpu_m_rdata,
    output logic gpu_m_rlast,
    input  logic av1_m_awvalid,
    output logic av1_m_awready,
    output logic [63:0] av1_m_awaddr
);

endmodule
