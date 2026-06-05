`timescale 1ns/1ps

module interrupt_router (
    input  logic clk,
    input  logic rst_n,
    output logic [NUM_IRQS-1:0] peripheral_irqs,
    output logic m_ext_irq,
    input  logic s_ext_irq,
    input  logic s_awvalid,
    output logic s_awready,
    input  logic [31:0] s_awaddr,
    input  logic s_wvalid,
    output logic s_wready,
    input  logic [31:0] s_wdata,
    output logic s_bvalid,
    input  logic s_bready,
    output logic s_arvalid,
    output logic s_arready,
    input  logic [31:0] s_araddr,
    output logic s_rvalid,
    input  logic s_rready,
    input  logic [31:0] s_rdata
);

endmodule
