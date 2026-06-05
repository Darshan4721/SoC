`timescale 1ns/1ps
module l1_dcache_ctrl #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64
) (
    input  logic                     clk,
    input  logic                     rst_n,
    
    // AXI Master to L2 Data Cache Interface
    output logic                  m_axi_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_araddr,
    output logic [7:0]            m_axi_arlen,
    input  logic                  m_axi_arready,
    input  logic                  m_axi_rvalid,
    input  logic [DATA_WIDTH-1:0] m_axi_rdata,
    input  logic                  m_axi_rlast,
    output logic                  m_axi_rready,
    
    output logic                  m_axi_awvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_awaddr,
    output logic [7:0]            m_axi_awlen,
    input  logic                  m_axi_awready,
    output logic                  m_axi_wvalid,
    output logic [DATA_WIDTH-1:0] m_axi_wdata,
    output logic                  m_axi_wlast,
    input  logic                  m_axi_wready,
    input  logic                  m_axi_bvalid,
    output logic                  m_axi_bready
);
    // Stub
    always_comb begin
        m_axi_arvalid = 1'b0;
        m_axi_araddr = '0;
        m_axi_arlen = '0;
        m_axi_rready = 1'b0;
        
        m_axi_awvalid = 1'b0;
        m_axi_awaddr = '0;
        m_axi_awlen = '0;
        m_axi_wvalid = 1'b0;
        m_axi_wdata = '0;
        m_axi_wlast = 1'b0;
        m_axi_bready = 1'b0;
    end
endmodule
