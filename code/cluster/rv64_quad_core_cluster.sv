`timescale 1ns/1ps

module rv64_quad_core_cluster (
    input  logic clk,
    input  logic rst_n,
    output logic [3:0] m_ext_irq,
    input  logic [3:0] s_ext_irq,
    output logic [3:0] timer_irq,
    output logic [3:0] ipi_irq,
    input  logic axi_awvalid,
    output logic axi_awready,
    output logic [63:0] axi_awaddr,
    output logic [7:0] axi_awlen,
    output logic [2:0] axi_awsize,
    input  logic [1:0] axi_awburst,
    input  logic axi_wvalid,
    output logic axi_wready,
    output logic [63:0] axi_wdata,
    output logic [7:0] axi_wstrb,
    output logic axi_wlast,
    output logic axi_bvalid,
    input  logic axi_bready,
    output logic [1:0] axi_bresp,
    output logic axi_arvalid,
    output logic axi_arready,
    output logic [63:0] axi_araddr,
    output logic [7:0] axi_arlen,
    output logic [2:0] axi_arsize,
    input  logic [1:0] axi_arburst,
    output logic axi_rvalid,
    input  logic axi_rready,
    output logic [63:0] axi_rdata,
    output logic [1:0] axi_rresp,
    output logic axi_rlast
);

endmodule
