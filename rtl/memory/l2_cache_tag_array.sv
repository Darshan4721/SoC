`timescale 1ns/1ps
module l2_cache_tag_array #(
    parameter TAG_WIDTH = 48,
    parameter DEPTH = 256
) (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     we,
    input  logic [$clog2(DEPTH)-1:0] index,
    input  logic [TAG_WIDTH-1:0]     wtag,
    input  logic [1:0]               wmesi,
    output logic [TAG_WIDTH-1:0]     rtag,
    output logic [1:0]               rmesi
);
    // MESI States: 00=Invalid, 01=Shared, 10=Exclusive, 11=Modified
    logic [TAG_WIDTH-1:0] tag_mem  [0:DEPTH-1];
    logic [1:0]           mesi_mem [0:DEPTH-1];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<DEPTH; i++) begin
                mesi_mem[i] <= 2'b00; // Initialize all lines to Invalid
            end
        end else begin
            if (we) begin
                tag_mem[index]  <= wtag;
                mesi_mem[index] <= wmesi;
            end
            rtag  <= tag_mem[index];
            rmesi <= mesi_mem[index];
        end
    end
endmodule
