`timescale 1ns/1ps
module l1_dcache_tag_array #(
    parameter TAG_WIDTH = 48,
    parameter DEPTH = 64
) (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     we,
    input  logic [$clog2(DEPTH)-1:0] index,
    input  logic [TAG_WIDTH-1:0]     wtag,
    input  logic                     wvalid,
    input  logic                     wdirty,
    output logic [TAG_WIDTH-1:0]     rtag,
    output logic                     rvalid,
    output logic                     rdirty
);
    logic [TAG_WIDTH-1:0] tag_mem   [0:DEPTH-1];
    logic                 valid_mem [0:DEPTH-1];
    logic                 dirty_mem [0:DEPTH-1];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<DEPTH; i++) begin
                valid_mem[i] <= 1'b0;
                dirty_mem[i] <= 1'b0;
            end
        end else begin
            if (we) begin
                tag_mem[index]   <= wtag;
                valid_mem[index] <= wvalid;
                dirty_mem[index] <= wdirty;
            end
            rtag   <= tag_mem[index];
            rvalid <= valid_mem[index];
            rdirty <= dirty_mem[index];
        end
    end
endmodule
