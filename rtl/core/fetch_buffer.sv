`timescale 1ns/1ps
module fetch_buffer #(
    parameter INSTR_WIDTH = 32,
    parameter PC_WIDTH = 64,
    parameter DEPTH = 8 // 8 entries of 4 instructions (32 instructions total)
) (
    input  logic                   clk,
    input  logic                   rst_n,
    
    // I-Cache Response Interface (128-bit block = 4 instructions)
    input  logic                   flush,
    input  logic                   icache_rsp_val,
    input  logic [127:0]           icache_rsp_data, // 4 instructions
    input  logic [PC_WIDTH-1:0]    icache_rsp_pc,   // Base PC of the block
    
    // Decoder Interface (4-wide)
    input  logic                   decode_ready,
    output logic [3:0]             fetch_valid,
    output logic [3:0][INSTR_WIDTH-1:0] fetch_instr,
    output logic [3:0][PC_WIDTH-1:0]    fetch_pc,
    output logic                   fetch_full
);

    logic [127:0]           data_queue [0:DEPTH-1];
    logic [PC_WIDTH-1:0]    pc_queue   [0:DEPTH-1];
    
    logic [$clog2(DEPTH)-1:0] wr_ptr, rd_ptr;
    logic [$clog2(DEPTH):0]   count;
    
    assign fetch_full = (count == DEPTH);
    
    // If we have data, all 4 slots are valid in this simple block-aligned mock
    logic has_data;
    assign has_data = (count != 0);
    
    assign fetch_valid[0] = has_data;
    assign fetch_valid[1] = has_data;
    assign fetch_valid[2] = has_data;
    assign fetch_valid[3] = has_data;
    
    assign fetch_instr[0] = data_queue[rd_ptr][31:0];
    assign fetch_instr[1] = data_queue[rd_ptr][63:32];
    assign fetch_instr[2] = data_queue[rd_ptr][95:64];
    assign fetch_instr[3] = data_queue[rd_ptr][127:96];
    
    assign fetch_pc[0] = pc_queue[rd_ptr] + 0;
    assign fetch_pc[1] = pc_queue[rd_ptr] + 4;
    assign fetch_pc[2] = pc_queue[rd_ptr] + 8;
    assign fetch_pc[3] = pc_queue[rd_ptr] + 12;
    
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
                data_queue[wr_ptr] <= icache_rsp_data;
                pc_queue[wr_ptr]   <= icache_rsp_pc;
                wr_ptr <= wr_ptr + 1'b1;
            end
            
            // Read
            if (has_data && decode_ready) begin
                rd_ptr <= rd_ptr + 1'b1;
            end
            
            // Count Update
            if (icache_rsp_val && !fetch_full && !(has_data && decode_ready))
                count <= count + 1'b1;
            else if (!(icache_rsp_val && !fetch_full) && (has_data && decode_ready))
                count <= count - 1'b1;
        end
    end
endmodule
