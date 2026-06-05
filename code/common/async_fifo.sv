`timescale 1ns/1ps

module async_fifo (
    input  logic wclk,
    input  logic wrst_n,
    output logic push,
    output logic [DATA_WIDTH-1:0] data_in,
    output logic full,
    input  logic rclk,
    input  logic rrst_n,
    output logic pop,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic empty
);    parameter DATA_WIDTH = 32;
    parameter DEPTH = 16;
    localparam ADDR_WIDTH = $clog2(DEPTH);

    // --- RAM Array ---
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // --- Pointers ---
    logic [ADDR_WIDTH:0] wptr_bin, wptr_gray, wptr_gray_next, wptr_bin_next;
    logic [ADDR_WIDTH:0] rptr_bin, rptr_gray, rptr_gray_next, rptr_bin_next;
    
    // --- Synchronizers ---
    logic [ADDR_WIDTH:0] wq1_rptr, wq2_rptr;
    logic [ADDR_WIDTH:0] rq1_wptr, rq2_wptr;

    // --- Write Domain Logic ---
    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wptr_bin  <= '0;
            wptr_gray <= '0;
        end else if (push && !full) begin
            mem[wptr_bin[ADDR_WIDTH-1:0]] <= data_in;
            wptr_bin  <= wptr_bin_next;
            wptr_gray <= wptr_gray_next;
        end
    end

    assign wptr_bin_next  = wptr_bin + (push && !full);
    assign wptr_gray_next = (wptr_bin_next >> 1) ^ wptr_bin_next;
    
    // Synchronize read pointer to write domain
    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wq1_rptr <= '0;
            wq2_rptr <= '0;
        end else begin
            wq1_rptr <= rptr_gray;
            wq2_rptr <= wq1_rptr;
        end
    end
    
    assign full = (wptr_gray_next == {~wq2_rptr[ADDR_WIDTH:ADDR_WIDTH-1], wq2_rptr[ADDR_WIDTH-2:0]});

    // --- Read Domain Logic ---
    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rptr_bin  <= '0;
            rptr_gray <= '0;
        end else if (pop && !empty) begin
            rptr_bin  <= rptr_bin_next;
            rptr_gray <= rptr_gray_next;
        end
    end

    assign rptr_bin_next  = rptr_bin + (pop && !empty);
    assign rptr_gray_next = (rptr_bin_next >> 1) ^ rptr_bin_next;
    assign data_out = mem[rptr_bin[ADDR_WIDTH-1:0]];
    
    // Synchronize write pointer to read domain
    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rq1_wptr <= '0;
            rq2_wptr <= '0;
        end else begin
            rq1_wptr <= wptr_gray;
            rq2_wptr <= rq1_wptr;
        end
    end
    
    assign empty = (rptr_gray == rq2_wptr);

endmodule
