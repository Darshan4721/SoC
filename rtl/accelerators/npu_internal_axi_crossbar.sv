`timescale 1ns/1ps
module npu_internal_axi_crossbar #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // ==========================================
    // 1. AXI-Full (Master traffic from NPU DMA -> Out to NoC)
    // ==========================================
    // From NPU DMA
    input  logic                  s_axi_full_arvalid,
    input  logic [ADDR_WIDTH-1:0] s_axi_full_araddr,
    input  logic [7:0]            s_axi_full_arlen,
    output logic                  s_axi_full_arready,
    output logic                  s_axi_full_rvalid,
    output logic [DATA_WIDTH-1:0] s_axi_full_rdata,
    output logic                  s_axi_full_rlast,
    input  logic                  s_axi_full_rready,
    
    // To NoC Router
    output logic                  m_axi_full_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_full_araddr,
    output logic [7:0]            m_axi_full_arlen,
    input  logic                  m_axi_full_arready,
    input  logic                  m_axi_full_rvalid,
    input  logic [DATA_WIDTH-1:0] m_axi_full_rdata,
    input  logic                  m_axi_full_rlast,
    output logic                  m_axi_full_rready,
    
    // ==========================================
    // 2. AXI-Lite (Slave traffic from NoC -> In to NPU Controller)
    // ==========================================
    // From NoC Router
    input  logic                  s_axi_lite_awvalid,
    input  logic [31:0]           s_axi_lite_awaddr,
    output logic                  s_axi_lite_awready,
    input  logic                  s_axi_lite_wvalid,
    input  logic [31:0]           s_axi_lite_wdata,
    input  logic [3:0]            s_axi_lite_wstrb,
    output logic                  s_axi_lite_wready,
    output logic                  s_axi_lite_bvalid,
    output logic [1:0]            s_axi_lite_bresp,
    input  logic                  s_axi_lite_bready,
    input  logic                  s_axi_lite_arvalid,
    input  logic [31:0]           s_axi_lite_araddr,
    output logic                  s_axi_lite_arready,
    output logic                  s_axi_lite_rvalid,
    output logic [31:0]           s_axi_lite_rdata,
    output logic [1:0]            s_axi_lite_rresp,
    input  logic                  s_axi_lite_rready,
    
    // To NPU Controller FSM
    output logic                  m_axi_lite_awvalid,
    output logic [31:0]           m_axi_lite_awaddr,
    input  logic                  m_axi_lite_awready,
    output logic                  m_axi_lite_wvalid,
    output logic [31:0]           m_axi_lite_wdata,
    output logic [3:0]            m_axi_lite_wstrb,
    input  logic                  m_axi_lite_wready,
    input  logic                  m_axi_lite_bvalid,
    input  logic [1:0]            m_axi_lite_bresp,
    output logic                  m_axi_lite_bready,
    output logic                  m_axi_lite_arvalid,
    output logic [31:0]           m_axi_lite_araddr,
    input  logic                  m_axi_lite_arready,
    input  logic                  m_axi_lite_rvalid,
    input  logic [31:0]           m_axi_lite_rdata,
    input  logic [1:0]            m_axi_lite_rresp,
    output logic                  m_axi_lite_rready
);

    // Structural routing (Pass-through for a single master/slave in this implementation)
    // This provides the structural boundary required by the architecture BOM.
    
    // AXI-Full Routing (DMA -> NoC)
    assign m_axi_full_arvalid = s_axi_full_arvalid;
    assign m_axi_full_araddr  = s_axi_full_araddr;
    assign m_axi_full_arlen   = s_axi_full_arlen;
    assign s_axi_full_arready = m_axi_full_arready;
    assign s_axi_full_rvalid  = m_axi_full_rvalid;
    assign s_axi_full_rdata   = m_axi_full_rdata;
    assign s_axi_full_rlast   = m_axi_full_rlast;
    assign m_axi_full_rready  = s_axi_full_rready;

    // AXI-Lite Routing (NoC -> Controller)
    assign m_axi_lite_awvalid = s_axi_lite_awvalid;
    assign m_axi_lite_awaddr  = s_axi_lite_awaddr;
    assign s_axi_lite_awready = m_axi_lite_awready;
    assign m_axi_lite_wvalid  = s_axi_lite_wvalid;
    assign m_axi_lite_wdata   = s_axi_lite_wdata;
    assign m_axi_lite_wstrb   = s_axi_lite_wstrb;
    assign s_axi_lite_wready  = m_axi_lite_wready;
    assign s_axi_lite_bvalid  = m_axi_lite_bvalid;
    assign s_axi_lite_bresp   = m_axi_lite_bresp;
    assign m_axi_lite_bready  = s_axi_lite_bready;
    assign m_axi_lite_arvalid = s_axi_lite_arvalid;
    assign m_axi_lite_araddr  = s_axi_lite_araddr;
    assign s_axi_lite_arready = m_axi_lite_arready;
    assign s_axi_lite_rvalid  = m_axi_lite_rvalid;
    assign s_axi_lite_rdata   = m_axi_lite_rdata;
    assign s_axi_lite_rresp   = m_axi_lite_rresp;
    assign m_axi_lite_rready  = s_axi_lite_rready;

endmodule
