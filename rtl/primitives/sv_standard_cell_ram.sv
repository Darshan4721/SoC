`timescale 1ns/1ps

module sv_standard_cell_ram #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 256
) (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     we,
    input  logic [$clog2(DEPTH)-1:0] addr,
    input  logic [DATA_WIDTH-1:0]    wdata,
    output logic [DATA_WIDTH-1:0]    rdata
);
    logic [DATA_WIDTH-1:0] mem_array [0:DEPTH-1];

    always_ff @(posedge clk) begin
        if (we) begin
            mem_array[addr] <= wdata;
        end
        rdata <= mem_array[addr];
    end
endmodule
