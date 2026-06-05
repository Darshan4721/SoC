`timescale 1ns/1ps

module tensor_reshape_unit (
    input  logic clk,
    input  logic rst_n,
    output logic start,
    output logic [31:0] base_src_addr,
    output logic [31:0] base_dst_addr,
    output logic [15:0] total_elements,
    output logic [31:0] src_stride_0,
    output logic src_stride_1,
    output logic src_stride_2,
    output logic [31:0] dst_stride_0,
    output logic dst_stride_1,
    output logic dst_stride_2,
    output logic [15:0] dim_0,
    output logic dim_1,
    output logic dim_2,
    output logic dim_3,
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
