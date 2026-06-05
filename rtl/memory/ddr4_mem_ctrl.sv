`timescale 1ns/1ps
module ddr4_mem_ctrl #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // AXI Slave Interface
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
    
    // DDR4 Physical Interface
    output logic                  ddr4_ck_p,
    output logic                  ddr4_ck_n,
    output logic                  ddr4_cke,
    output logic                  ddr4_cs_n,
    output logic                  ddr4_ras_n,
    output logic                  ddr4_cas_n,
    output logic                  ddr4_we_n,
    output logic [1:0]            ddr4_bg,
    output logic [1:0]            ddr4_ba,
    output logic [15:0]           ddr4_a,
    inout  wire  [63:0]           ddr4_dq,
    inout  wire  [7:0]            ddr4_dqs_p,
    inout  wire  [7:0]            ddr4_dqs_n,
    output logic [7:0]            ddr4_dm
);
    // Stub
    always_comb begin
        s_axi_arready = 1'b1;
        s_axi_rvalid  = 1'b0;
        s_axi_rdata   = '0;
        s_axi_rlast   = 1'b0;
        s_axi_awready = 1'b1;
        s_axi_wready  = 1'b1;
        s_axi_bvalid  = 1'b0;
        
        ddr4_ck_p = clk;
        ddr4_ck_n = ~clk;
        ddr4_cke = 1'b1;
        ddr4_cs_n = 1'b0;
        ddr4_ras_n = 1'b1;
        ddr4_cas_n = 1'b1;
        ddr4_we_n = 1'b1;
        ddr4_bg = '0;
        ddr4_ba = '0;
        ddr4_a = '0;
        ddr4_dm = '0;
    end
endmodule
