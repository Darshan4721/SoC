`timescale 1ns/1ps

module l1_icache_ctrl (
    input  logic clk,
    input  logic rst_n,
    output logic fetch_req,
    output logic [63:0] fetch_vaddr,
    output logic fetch_ack,
    output logic [127:0] fetch_data,
    output logic tlb_req,
    output logic [63:0] tlb_vaddr,
    output logic tlb_hit,
    output logic [55:0] tlb_paddr,
    output logic l2_req,
    output logic [55:0] l2_paddr,
    output logic l2_ack,
    output logic [511:0] l2_data,
    output logic tag_rd_en,
    output logic [5:0] tag_rd_idx,
    output logic [43:0] [0:3] tag_rd_tags,
    output logic [3:0] tag_rd_valid,
    output logic tag_wr_en,
    output logic [5:0] tag_wr_idx,
    output logic [1:0] tag_wr_way,
    output logic [43:0] tag_wr_tag,
    output logic tag_wr_valid_bit,
    output logic data_rd_en,
    output logic [5:0] data_rd_idx,
    output logic [511:0] [0:3] data_rd_data,
    output logic data_wr_en,
    output logic [5:0] data_wr_idx,
    output logic [1:0] data_wr_way,
    output logic [511:0] data_wr_data
);

endmodule
