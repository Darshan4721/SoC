`timescale 1ns/1ps

module clock_domain_crossing_fifo (
    input  logic wr_clk,
    input  logic wr_rst_n,
    output logic wr_en,
    output logic [DATA_WIDTH-1:0] wr_data,
    output logic full,
    input  logic rd_clk,
    input  logic rd_rst_n,
    output logic rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic empty
);

endmodule
