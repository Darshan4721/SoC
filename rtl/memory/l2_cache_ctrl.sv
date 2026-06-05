`timescale 1ns/1ps
module l2_cache_ctrl #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Slave Interface
    input  logic                  s_axi_arvalid,
    input  logic [ADDR_WIDTH-1:0] s_axi_araddr,
    input  logic [7:0]            s_axi_arlen,
    output logic                  s_axi_arready,
    
    output logic                  s_axi_rvalid,
    output logic [DATA_WIDTH-1:0] s_axi_rdata,
    output logic                  s_axi_rlast,
    input  logic                  s_axi_rready,
    
    input  logic                  s_axi_awvalid,
    input  logic [ADDR_WIDTH-1:0] s_axi_awaddr,
    input  logic [7:0]            s_axi_awlen,
    output logic                  s_axi_awready,
    
    input  logic                  s_axi_wvalid,
    input  logic [DATA_WIDTH-1:0] s_axi_wdata,
    input  logic                  s_axi_wlast,
    output logic                  s_axi_wready,
    
    output logic                  s_axi_bvalid,
    input  logic                  s_axi_bready,
    
    // Master Interface
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
    // Stub to pass through signals
    always_comb begin
        m_axi_arvalid = s_axi_arvalid;
        m_axi_araddr  = s_axi_araddr;
        m_axi_arlen   = s_axi_arlen;
        s_axi_arready = m_axi_arready;
        
        s_axi_rvalid  = m_axi_rvalid;
        s_axi_rdata   = m_axi_rdata;
        s_axi_rlast   = m_axi_rlast;
        m_axi_rready  = s_axi_rready;
        
        m_axi_awvalid = s_axi_awvalid;
        m_axi_awaddr  = s_axi_awaddr;
        m_axi_awlen   = s_axi_awlen;
        s_axi_awready = m_axi_awready;
        
        m_axi_wvalid  = s_axi_wvalid;
        m_axi_wdata   = s_axi_wdata;
        m_axi_wlast   = s_axi_wlast;
        s_axi_wready  = m_axi_wready;
        
        s_axi_bvalid  = m_axi_bvalid;
        m_axi_bready  = s_axi_bready;
    end
endmodule
