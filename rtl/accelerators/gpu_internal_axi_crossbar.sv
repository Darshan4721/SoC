`timescale 1ns/1ps
module gpu_internal_axi_crossbar #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // ==========================================
    // 1. AXI-Full Master Interfaces (From GPU internals)
    // ==========================================
    // Master 0: Command Fetcher
    input  logic                  s0_axi_arvalid,
    input  logic [ADDR_WIDTH-1:0] s0_axi_araddr,
    input  logic [7:0]            s0_axi_arlen,
    output logic                  s0_axi_arready,
    output logic                  s0_axi_rvalid,
    output logic [DATA_WIDTH-1:0] s0_axi_rdata,
    output logic                  s0_axi_rlast,
    input  logic                  s0_axi_rready,
    
    // Master 1: Texture L1 Cache
    input  logic                  s1_axi_arvalid,
    input  logic [ADDR_WIDTH-1:0] s1_axi_araddr,
    input  logic [7:0]            s1_axi_arlen,
    output logic                  s1_axi_arready,
    output logic                  s1_axi_rvalid,
    output logic [DATA_WIDTH-1:0] s1_axi_rdata,
    output logic                  s1_axi_rlast,
    input  logic                  s1_axi_rready,
    
    // Master 2: ROP Frame Buffer Write
    input  logic                  s2_axi_awvalid,
    input  logic [ADDR_WIDTH-1:0] s2_axi_awaddr,
    output logic                  s2_axi_awready,
    input  logic                  s2_axi_wvalid,
    input  logic [DATA_WIDTH-1:0] s2_axi_wdata,
    output logic                  s2_axi_wready,
    
    // ==========================================
    // 2. AXI-Full Master Interface (To Global NoC)
    // ==========================================
    output logic                  m_axi_awvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_awaddr,
    input  logic                  m_axi_awready,
    output logic                  m_axi_wvalid,
    output logic [DATA_WIDTH-1:0] m_axi_wdata,
    input  logic                  m_axi_wready,
    
    output logic                  m_axi_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_araddr,
    output logic [7:0]            m_axi_arlen,
    input  logic                  m_axi_arready,
    input  logic                  m_axi_rvalid,
    input  logic [DATA_WIDTH-1:0] m_axi_rdata,
    input  logic                  m_axi_rlast,
    output logic                  m_axi_rready,
    
    // ==========================================
    // 3. AXI-Lite Slave Interface (From NoC -> FSM)
    // ==========================================
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

    // Simple priority arbitration for READS (Cmd=High, Tex=Low)
    assign m_axi_arvalid = s0_axi_arvalid ? s0_axi_arvalid : s1_axi_arvalid;
    assign m_axi_araddr  = s0_axi_arvalid ? s0_axi_araddr  : s1_axi_araddr;
    assign m_axi_arlen   = s0_axi_arvalid ? s0_axi_arlen   : s1_axi_arlen;
    
    assign s0_axi_arready = s0_axi_arvalid ? m_axi_arready : 1'b0;
    assign s1_axi_arready = (!s0_axi_arvalid && s1_axi_arvalid) ? m_axi_arready : 1'b0;
    
    // Read response routing based on who requested it (Simplified, assumes no outstanding interleaving)
    logic r_dest;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) r_dest <= 1'b0;
        else if (m_axi_arvalid && m_axi_arready) r_dest <= s0_axi_arvalid ? 1'b0 : 1'b1;
    end
    
    assign s0_axi_rvalid = (r_dest == 1'b0) ? m_axi_rvalid : 1'b0;
    assign s1_axi_rvalid = (r_dest == 1'b1) ? m_axi_rvalid : 1'b0;
    assign s0_axi_rdata  = m_axi_rdata;
    assign s1_axi_rdata  = m_axi_rdata;
    assign s0_axi_rlast  = m_axi_rlast;
    assign s1_axi_rlast  = m_axi_rlast;
    assign m_axi_rready  = (r_dest == 1'b0) ? s0_axi_rready : s1_axi_rready;

    // WRITES (Only ROP writes to Memory in this GPU architecture)
    assign m_axi_awvalid = s2_axi_awvalid;
    assign m_axi_awaddr  = s2_axi_awaddr;
    assign s2_axi_awready = m_axi_awready;
    
    assign m_axi_wvalid  = s2_axi_wvalid;
    assign m_axi_wdata   = s2_axi_wdata;
    assign s2_axi_wready = m_axi_wready;

    // AXI-Lite Route Through
    assign m_axi_lite_awvalid = s_axi_lite_awvalid;
    assign m_axi_lite_awaddr  = s_axi_lite_awaddr;
    assign s_axi_lite_awready = m_axi_lite_awready;
    assign m_axi_lite_wvalid  = s_axi_lite_wvalid;
    assign m_axi_lite_wdata   = s_axi_lite_wdata;
    assign m_axi_lite_wstrb   = s_axi_lite_wstrb;
    assign s_axi_lite_wready  = m_axi_lite_wready;
    assign s_axi_lite_bvalid  = m_axi_lite_bvalid;
    assign s_axi_lite_bresp   = m_axi_lite_bresp;
    assign s_axi_lite_bready  = s_axi_lite_bready;
    assign m_axi_lite_arvalid = s_axi_lite_arvalid;
    assign m_axi_lite_araddr  = s_axi_lite_araddr;
    assign s_axi_lite_arready = m_axi_lite_arready;
    assign s_axi_lite_rvalid  = s_axi_lite_rvalid;
    assign s_axi_lite_rdata   = s_axi_lite_rdata;
    assign s_axi_lite_rresp   = s_axi_lite_rresp;
    assign s_axi_lite_rready  = s_axi_lite_rready;

endmodule
