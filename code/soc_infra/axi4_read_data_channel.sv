`timescale 1ns/1ps

module axi4_read_data_channel (
    input  logic clk,
    input  logic rst_n,
    output logic [3:0] m_rvalid,
    input  logic [3:0] m_rready,
    output logic [63:0] [0:3] m_rdata,
    output logic [3:0] s_rvalid,
    input  logic [3:0] s_rready,
    input  logic [63:0] [0:3] s_rdata,
    output logic [1:0] [0:3] target_master
);

endmodule
