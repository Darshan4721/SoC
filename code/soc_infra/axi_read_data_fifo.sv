`timescale 1ns/1ps

module axi_read_data_fifo (
    input  logic clk,
    input  logic rst_n,
    output logic s_axi_rvalid,
    input  logic s_axi_rready,
    input  logic [DATA_WIDTH-1:0] s_axi_rdata,
    input  logic s_axi_rlast,
    input  logic [ID_WIDTH-1:0] s_axi_rid,
    input  logic [1:0] s_axi_rresp,
    output logic m_axi_rvalid,
    input  logic m_axi_rready,
    output logic [DATA_WIDTH-1:0] m_axi_rdata,
    output logic m_axi_rlast,
    output logic [ID_WIDTH-1:0] m_axi_rid,
    output logic [1:0] m_axi_rresp
);

endmodule
