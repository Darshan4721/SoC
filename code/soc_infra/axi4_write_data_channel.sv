`timescale 1ns/1ps

module axi4_write_data_channel (
    input  logic clk,
    input  logic rst_n,
    input  logic [3:0] s_wvalid,
    output logic [3:0] s_wready,
    input  logic [63:0] [0:3] s_wdata,
    input  logic [3:0] m_wvalid,
    output logic [3:0] m_wready,
    output logic [63:0] [0:3] m_wdata,
    output logic [3:0] [0:3] target_slave
);

endmodule
