`timescale 1ns/1ps

module sync_fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 16
) (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  push,
    input  logic                  pop,
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic                  full,
    output logic                  empty
);
    localparam PTR_WIDTH = $clog2(DEPTH);
    
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [PTR_WIDTH:0]    wr_ptr;
    logic [PTR_WIDTH:0]    rd_ptr;

    assign empty = (wr_ptr == rd_ptr);
    assign full  = (wr_ptr[PTR_WIDTH] != rd_ptr[PTR_WIDTH]) && 
                   (wr_ptr[PTR_WIDTH-1:0] == rd_ptr[PTR_WIDTH-1:0]);

    assign data_out = mem[rd_ptr[PTR_WIDTH-1:0]];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
        end else begin
            if (push && !full) begin
                mem[wr_ptr[PTR_WIDTH-1:0]] <= data_in;
                wr_ptr <= wr_ptr + 1'b1;
            end
            if (pop && !empty) begin
                rd_ptr <= rd_ptr + 1'b1;
            end
        end
    end
endmodule
