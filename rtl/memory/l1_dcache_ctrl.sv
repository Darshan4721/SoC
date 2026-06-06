`timescale 1ns/1ps
module l1_dcache_ctrl #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter CACHE_LINE_WIDTH = 256
) (
    input  logic                     clk,
    input  logic                     rst_n,
    
    // CPU Load Interface (from TLB)
    input  logic                  load_req_val,
    input  logic [ADDR_WIDTH-1:0] load_req_addr,
    output logic                  load_req_rdy,
    output logic                  load_rsp_val,
    output logic [DATA_WIDTH-1:0] load_rsp_data,
    
    // CPU Store Interface (from Store Buffer)
    input  logic                  store_req_val,
    input  logic [ADDR_WIDTH-1:0] store_req_addr,
    input  logic [DATA_WIDTH-1:0] store_req_data,
    output logic                  store_req_rdy,
    
    // AXI Master to L2 Data Cache Interface
    output logic                  m_axi_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_araddr,
    output logic [7:0]            m_axi_arlen,
    input  logic                  m_axi_arready,
    input  logic                  m_axi_rvalid,
    input  logic [CACHE_LINE_WIDTH-1:0] m_axi_rdata, // Cache line fill
    input  logic                  m_axi_rlast,
    output logic                  m_axi_rready,
    
    output logic                  m_axi_awvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_awaddr,
    output logic [7:0]            m_axi_awlen,
    input  logic                  m_axi_awready,
    output logic                  m_axi_wvalid,
    output logic [CACHE_LINE_WIDTH-1:0] m_axi_wdata,
    output logic                  m_axi_wlast,
    input  logic                  m_axi_wready,
    input  logic                  m_axi_bvalid,
    output logic                  m_axi_bready
);
    // Basic Direct-Mapped Cache Parameters
    localparam DEPTH = 64;
    localparam INDEX_WIDTH = 6;
    localparam OFFSET_WIDTH = 5;
    localparam TAG_WIDTH = ADDR_WIDTH - INDEX_WIDTH - OFFSET_WIDTH;
    
    // Tag and Data Array Instantiations
    logic                     tag_we;
    logic [INDEX_WIDTH-1:0]   tag_idx;
    logic [TAG_WIDTH-1:0]     tag_wdata, tag_rdata;
    logic                     tag_wval, tag_rval;
    logic                     tag_wdirty, tag_rdirty;
    
    l1_dcache_tag_array #(
        .TAG_WIDTH(TAG_WIDTH),
        .DEPTH(DEPTH)
    ) i_dcache_tags (
        .clk(clk),
        .rst_n(rst_n),
        .we(tag_we),
        .index(tag_idx),
        .wtag(tag_wdata),
        .wvalid(tag_wval),
        .wdirty(tag_wdirty),
        .rtag(tag_rdata),
        .rvalid(tag_rval),
        .rdirty(tag_rdirty)
    );
    
    logic                     data_we;
    logic [INDEX_WIDTH-1:0]   data_idx;
    logic [CACHE_LINE_WIDTH-1:0] data_wdata, data_rdata;
    
    l1_dcache_data_array #(
        .DATA_WIDTH(CACHE_LINE_WIDTH),
        .DEPTH(DEPTH)
    ) i_dcache_data (
        .clk(clk),
        .rst_n(rst_n),
        .we(data_we),
        .index(data_idx),
        .wdata(data_wdata),
        .rdata(data_rdata)
    );
    
    // Controller FSM (Structural Stub)
    // In a real cache, an FSM handles hit/miss detection, eviction, and AXI fills.
    
    assign load_req_rdy = 1'b1;
    assign store_req_rdy = 1'b1;
    
    assign load_rsp_val = load_req_val; // Fake immediate hit
    assign load_rsp_data = data_rdata[DATA_WIDTH-1:0];
    
    assign tag_we = store_req_val;
    assign tag_idx = store_req_addr[OFFSET_WIDTH+INDEX_WIDTH-1:OFFSET_WIDTH];
    assign tag_wdata = store_req_addr[ADDR_WIDTH-1:ADDR_WIDTH-TAG_WIDTH];
    assign tag_wval = 1'b1;
    assign tag_wdirty = 1'b1;
    
    assign data_we = store_req_val;
    assign data_idx = tag_idx;
    assign data_wdata = { {(CACHE_LINE_WIDTH-DATA_WIDTH){1'b0}}, store_req_data };
    
    // AXI Stubs
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
