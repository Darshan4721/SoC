`timescale 1ns/1ps

module jtag_axi_debug_bridge (
    output logic tck,
    input  logic trst_n,
    output logic shift_dr,
    output logic update_dr,
    output logic capture_dr,
    output logic tdi,
    output logic tdo_out,
    output logic [4:0] ir_reg,
    input  logic sys_clk,
    input  logic sys_rst_n,
    input  logic m_awvalid,
    output logic m_awready,
    output logic [31:0] m_awaddr,
    input  logic m_wvalid,
    output logic m_wready,
    output logic [31:0] m_wdata,
    output logic m_bvalid,
    input  logic m_bready,
    output logic m_arvalid,
    output logic m_arready,
    output logic [31:0] m_araddr,
    output logic m_rvalid,
    input  logic m_rready,
    output logic [31:0] m_rdata
);

endmodule
