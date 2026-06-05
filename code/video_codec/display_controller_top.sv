`timescale 1ns/1ps

module display_controller_top (
    input  logic clk,
    input  logic rst_n,
    input  logic pixel_clk,
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
    output logic m_arvalid,
    output logic m_arready,
    output logic [63:0] m_araddr,
    output logic [7:0] m_arlen,
    output logic m_rvalid,
    input  logic m_rready,
    output logic [63:0] m_rdata,
    output logic m_rlast,
    input  logic hdmi_clk_p,
    input  logic hdmi_clk_n,
    output logic [2:0] hdmi_tx_p,
    output logic [2:0] hdmi_tx_n
);

endmodule
