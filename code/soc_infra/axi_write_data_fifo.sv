`timescale 1ns/1ps

module axi_write_data_fifo (
    input  logic clk,
    input  logic rst_n,
    input  logic s_axi_wvalid,
    output logic s_axi_wready,
    input  logic [DATA_WIDTH-1:0] s_axi_wdata,
    input  logic [STRB_WIDTH-1:0] s_axi_wstrb,
    input  logic s_axi_wlast,
    input  logic m_axi_wvalid,
    output logic m_axi_wready,
    output logic [DATA_WIDTH-1:0] m_axi_wdata,
    output logic [STRB_WIDTH-1:0] m_axi_wstrb,
    output logic m_axi_wlast
);

endmodule
