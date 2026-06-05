`timescale 1ns/1ps
module l1_icache_ctrl #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 128
) (
    input  logic                     clk,
    input  logic                     rst_n,
    
    // Core Fetch Interface
    input  logic                     core_req_val,
    input  logic [ADDR_WIDTH-1:0]    core_req_addr,
    output logic                     core_rsp_val,
    output logic [DATA_WIDTH-1:0]    core_rsp_data,
    output logic                     core_req_rdy,
    
    // AXI Master to L2 Interface
    output logic                  m_axi_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_araddr,
    output logic [7:0]            m_axi_arlen,
    input  logic                  m_axi_arready,
    input  logic                  m_axi_rvalid,
    input  logic [DATA_WIDTH-1:0] m_axi_rdata,
    input  logic                  m_axi_rlast,
    output logic                  m_axi_rready
);
    // Stub
    always_comb begin
        core_rsp_val = m_axi_rvalid;
        core_rsp_data = m_axi_rdata;
        core_req_rdy = m_axi_arready;
        
        m_axi_arvalid = core_req_val;
        m_axi_araddr = core_req_addr;
        m_axi_arlen = 8'd0;
        m_axi_rready = 1'b1;
    end
endmodule
