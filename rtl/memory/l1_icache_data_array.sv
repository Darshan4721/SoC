`timescale 1ns/1ps
module l1_icache_data_array #(
    parameter DATA_WIDTH = 256,
    parameter DEPTH = 64
) (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     we,
    input  logic [$clog2(DEPTH)-1:0] index,
    input  logic [DATA_WIDTH-1:0]    wdata,
    output logic [DATA_WIDTH-1:0]    rdata
);
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge clk) begin
        if (we) begin
            mem[index] <= wdata;
        end
        rdata <= mem[index];
    end
endmodule
