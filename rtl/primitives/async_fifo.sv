`timescale 1ns/1ps

module async_fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 16
) (
    input  logic                  wclk,
    input  logic                  wrst_n,
    input  logic                  wpush,
    input  logic [DATA_WIDTH-1:0] wdata,
    output logic                  wfull,
    
    input  logic                  rclk,
    input  logic                  rrst_n,
    input  logic                  rpop,
    output logic [DATA_WIDTH-1:0] rdata,
    output logic                  rempty
);
    localparam PTR_WIDTH = $clog2(DEPTH);
    
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    
    logic [PTR_WIDTH:0] wptr_bin, wptr_gray, wptr_gray_sync1, wptr_gray_sync2;
    logic [PTR_WIDTH:0] rptr_bin, rptr_gray, rptr_gray_sync1, rptr_gray_sync2;
    
    // Write Domain
    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wptr_bin  <= '0;
            wptr_gray <= '0;
        end else if (wpush && !wfull) begin
            mem[wptr_bin[PTR_WIDTH-1:0]] <= wdata;
            wptr_bin  <= wptr_bin + 1'b1;
            wptr_gray <= (wptr_bin + 1'b1) ^ ((wptr_bin + 1'b1) >> 1);
        end
    end
    
    // Read Domain
    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rptr_bin  <= '0;
            rptr_gray <= '0;
        end else if (rpop && !rempty) begin
            rptr_bin  <= rptr_bin + 1'b1;
            rptr_gray <= (rptr_bin + 1'b1) ^ ((rptr_bin + 1'b1) >> 1);
        end
    end
    
    assign rdata = mem[rptr_bin[PTR_WIDTH-1:0]];
    
    // Synchronizers
    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) {rptr_gray_sync2, rptr_gray_sync1} <= '0;
        else         {rptr_gray_sync2, rptr_gray_sync1} <= {rptr_gray_sync1, rptr_gray};
    end
    
    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) {wptr_gray_sync2, wptr_gray_sync1} <= '0;
        else         {wptr_gray_sync2, wptr_gray_sync1} <= {wptr_gray_sync1, wptr_gray};
    end
    
    assign wfull  = (wptr_gray == {~rptr_gray_sync2[PTR_WIDTH:PTR_WIDTH-1], rptr_gray_sync2[PTR_WIDTH-2:0]});
    assign rempty = (rptr_gray == wptr_gray_sync2);

endmodule
