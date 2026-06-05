`timescale 1ns/1ps

module clock_domain_crossing_handshake (
    input  logic clk_src,
    input  logic rst_src_n,
    output logic req_in,
    output logic ack_out,
    input  logic clk_dst,
    input  logic rst_dst_n,
    output logic req_out,
    output logic ack_in
);

endmodule
