`timescale 1ns/1ps

module av1_loop_filter (
    input  logic clk,
    input  logic rst_n,
    output logic filter_start,
    output logic [5:0] filter_level,
    output logic [1:0] edge_dir,
    output logic mem_req,
    output logic [15:0] mem_addr,
    output logic mem_we,
    output logic [31:0] mem_wdata,
    output logic [31:0] mem_rdata,
    output logic mem_ack,
    output logic filter_done
);

endmodule
