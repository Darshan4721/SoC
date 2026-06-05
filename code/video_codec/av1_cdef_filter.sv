`timescale 1ns/1ps

module av1_cdef_filter (
    input  logic clk,
    input  logic rst_n,
    output logic filter_start,
    output logic [2:0] cdef_strength,
    output logic mem_req,
    output logic [15:0] mem_addr,
    output logic mem_we,
    output logic [63:0] mem_wdata,
    output logic [63:0] mem_rdata,
    output logic mem_ack,
    output logic filter_done
);

endmodule
