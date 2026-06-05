`timescale 1ns/1ps
module fetch_buffer #(
    parameter INSTR_WIDTH = 32,
    parameter PC_WIDTH = 64,
    parameter DEPTH = 16
) (
    input  logic                   clk,
    input  logic                   rst_n,
    
    // I-Cache Response Interface
    input  logic                   flush,
    input  logic                   icache_rsp_val,
    input  logic [INSTR_WIDTH-1:0] icache_rsp_instr,
    input  logic [PC_WIDTH-1:0]    icache_rsp_pc,
    
    // Decoder Interface
    input  logic                   decode_ready,
    output logic                   fetch_valid,
    output logic [INSTR_WIDTH-1:0] fetch_instr,
    output logic [PC_WIDTH-1:0]    fetch_pc,
    output logic                   fetch_full
);

    // Deep queue to hide I-Cache latency
    logic [INSTR_WIDTH-1:0] instr_queue [0:DEPTH-1];
    logic [PC_WIDTH-1:0]    pc_queue    [0:DEPTH-1];
    
    logic [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;
    logic [$clog2(DEPTH):0]   count;
    
    assign fetch_full = (count == DEPTH);
    assign fetch_valid = (count != 0);
    
    assign fetch_instr = instr_queue[rd_ptr];
    assign fetch_pc    = pc_queue[rd_ptr];
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
        end else if (flush) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
        end else begin
            // Write
            if (icache_rsp_val && !fetch_full) begin
                instr_queue[wr_ptr] <= icache_rsp_instr;
                pc_queue[wr_ptr]    <= icache_rsp_pc;
                wr_ptr <= wr_ptr + 1'b1;
            end
            
            // Read
            if (fetch_valid && decode_ready) begin
                rd_ptr <= rd_ptr + 1'b1;
            end
            
            // Count Update
            if (icache_rsp_val && !fetch_full && !(fetch_valid && decode_ready))
                count <= count + 1'b1;
            else if (!(icache_rsp_val && !fetch_full) && (fetch_valid && decode_ready))
                count <= count - 1'b1;
        end
    end

endmodule
