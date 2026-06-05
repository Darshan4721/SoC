`timescale 1ns/1ps

module tensor_transpose_unit (
    input  logic clk,
    input  logic rst_n,
    output logic start,
    output logic [31:0] base_src_addr,
    output logic [31:0] base_dst_addr,
    output logic [15:0] rows,
    output logic [15:0] cols,
    output logic rd_req,
    output logic [31:0] rd_addr,
    output logic [63:0] rd_data,
    output logic rd_ack,
    output logic wr_req,
    output logic [31:0] wr_addr,
    output logic [63:0] wr_data,
    output logic wr_ack,
    output logic done
);

endmodule
