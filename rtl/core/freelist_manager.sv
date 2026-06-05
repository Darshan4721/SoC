`timescale 1ns/1ps
module freelist_manager #(
    parameter PHYS_REGS = 128,
    parameter PHYS_REG_WIDTH = 7
) (
    input  logic clk,
    input  logic rst_n,
    
    // Flush Interface
    input  logic flush,
    
    // Allocation Interface (to Dispatch)
    input  logic [3:0]                fl_alloc_req,
    output logic [3:0][PHYS_REG_WIDTH-1:0] fl_alloc_phys_id,
    output logic                      fl_alloc_rdy,
    
    // Free Interface (from Commit)
    input  logic [3:0]                fl_free_req,
    input  logic [3:0][PHYS_REG_WIDTH-1:0] fl_free_phys_id
);

    // Circular FIFO for Freelist
    logic [PHYS_REG_WIDTH-1:0] freelist_fifo [0:PHYS_REGS-1];
    logic [$clog2(PHYS_REGS)-1:0] head, tail;
    logic [$clog2(PHYS_REGS):0] count;
    
    assign fl_alloc_rdy = (count >= 4); // Ready if we have at least 4 free registers
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Initially, registers 32-127 are free (0-31 are mapped to architectural init)
            for (int i = 0; i < PHYS_REGS; i++) begin
                freelist_fifo[i] <= i[PHYS_REG_WIDTH-1:0];
            end
            head <= 'd32; // Start allocating from phys reg 32
            tail <= '0;    // Wrap around
            count <= PHYS_REGS - 32;
        end else if (flush) begin
            // Pipeline flush recovery logic would normally restore head/tail from snapshots.
            // Simplified here for structural placeholder.
        end else begin
            // Variable declarations must be at the very top of the block
            logic [2:0] alloc_count;
            logic [2:0] free_count;
            
            // Allocation (Pop from head)
            alloc_count = fl_alloc_req[0] + fl_alloc_req[1] + fl_alloc_req[2] + fl_alloc_req[3];
            
            // Freeing (Push to tail)
            free_count = fl_free_req[0] + fl_free_req[1] + fl_free_req[2] + fl_free_req[3];
            
            if (alloc_count > 0 && fl_alloc_rdy) begin
                head <= head + alloc_count;
            end
            
            if (free_count > 0) begin
                // Parallel write logic into the FIFO (synthesizes to shifting muxes)
                for (int i = 0; i < 4; i++) begin
                    if (fl_free_req[i]) begin
                        // In reality, an index offset tracks which position to write
                        freelist_fifo[(tail + i) % PHYS_REGS] <= fl_free_phys_id[i];
                    end
                end
                tail <= tail + free_count;
            end
            
            count <= count - alloc_count + free_count;
        end
    end
    
    // Combinatorial Output for Allocations
    always_comb begin
        for (int i = 0; i < 4; i++) begin
            fl_alloc_phys_id[i] = freelist_fifo[(head + i) % PHYS_REGS];
        end
    end

endmodule
