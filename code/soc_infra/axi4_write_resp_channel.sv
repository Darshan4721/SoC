`timescale 1ns/1ps

module axi4_write_resp_channel (
    input  logic clk,
    input  logic rst_n,
    output logic [3:0] m_bvalid,
    input  logic [3:0] m_bready,
    output logic [1:0] [0:3] m_bresp,
    output logic [3:0] s_bvalid,
    input  logic [3:0] s_bready,
    input  logic [1:0] [0:3] s_bresp,
    output logic [1:0] [0:3] target_master
);

endmodule
