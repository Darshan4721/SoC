`timescale 1ns/1ps

module l1_icache_tags (
    input  logic clk,
    input  logic rst_n,
    output logic rd_en,
    output logic [$clog2(SETS)-1:0] rd_index,
    output logic [43:0] [0:WAYS-1] rd_tags,
    output logic [WAYS-1:0] rd_valid,
    output logic wr_en,
    output logic [$clog2(SETS)-1:0] wr_index,
    output logic [$clog2(WAYS)-1:0] wr_way,
    output logic [43:0] wr_tag,
    output logic wr_valid_bit
);

endmodule
