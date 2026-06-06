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
    input  logic [255:0]          m_axi_rdata, // 32 byte cache line
    input  logic                  m_axi_rlast,
    output logic                  m_axi_rready
);
    localparam DEPTH = 64;
    localparam INDEX_WIDTH = 6;
    localparam OFFSET_WIDTH = 5;
    localparam TAG_WIDTH = ADDR_WIDTH - INDEX_WIDTH - OFFSET_WIDTH;
    
    logic                     tag_we;
    logic [INDEX_WIDTH-1:0]   tag_idx;
    logic [TAG_WIDTH-1:0]     tag_wdata, tag_rdata;
    logic                     tag_wval, tag_rval;
    logic                     tag_wdirty, tag_rdirty;
    
    l1_icache_tag_array #(
        .TAG_WIDTH(TAG_WIDTH),
        .DEPTH(DEPTH)
    ) i_tag_array (
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
    logic [255:0]             data_wdata, data_rdata;
    
    l1_icache_data_array #(
        .DATA_WIDTH(256),
        .DEPTH(DEPTH)
    ) i_data_array (
        .clk(clk),
        .rst_n(rst_n),
        .we(data_we),
        .index(data_idx),
        .wdata(data_wdata),
        .rdata(data_rdata)
    );

    // FSM / Controller Logic (Structural Stub)
    // For this mock, we assume L1 hits always if core_req_val is high
    assign core_req_rdy = 1'b1;
    
    // Delayed response to match SRAM read latency
    logic rsp_val_q;
    logic [ADDR_WIDTH-1:0] req_addr_q;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rsp_val_q <= 1'b0;
            req_addr_q <= '0;
        end else begin
            rsp_val_q <= core_req_val;
            if (core_req_val) req_addr_q <= core_req_addr;
        end
    end
    
    assign tag_idx = core_req_val ? core_req_addr[OFFSET_WIDTH+INDEX_WIDTH-1:OFFSET_WIDTH] : req_addr_q[OFFSET_WIDTH+INDEX_WIDTH-1:OFFSET_WIDTH];
    assign data_idx = tag_idx;
    
    // Write ports tied off for read-only I-Cache mock
    assign tag_we = 1'b0;
    assign tag_wdata = '0;
    assign tag_wval = 1'b0;
    assign tag_wdirty = 1'b0;
    
    assign data_we = 1'b0;
    assign data_wdata = '0;
    
    assign core_rsp_val = rsp_val_q;
    // Select upper or lower 128 bits based on offset
    assign core_rsp_data = req_addr_q[4] ? data_rdata[255:128] : data_rdata[127:0];

    // AXI Tied off
    assign m_axi_arvalid = 1'b0;
    assign m_axi_araddr = '0;
    assign m_axi_arlen = '0;
    assign m_axi_rready = 1'b0;

endmodule
