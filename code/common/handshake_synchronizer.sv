`timescale 1ns/1ps

module handshake_synchronizer (
    input  logic clk_src,
    input  logic rst_src_n,
    output logic req_src,
    output logic ack_src,
    output logic [DATA_WIDTH-1:0] data_src,
    input  logic clk_dest,
    input  logic rst_dest_n,
    output logic req_dest,
    output logic ack_dest,
    output logic [DATA_WIDTH-1:0] data_dest
);

endmodule
