`timescale 1ns/1ps
module reorder_buffer_ctrl #(
    parameter ROB_ENTRIES = 64,
    parameter PHYS_REG_WIDTH = 7,
    parameter ARCH_REG_WIDTH = 5,
    parameter PC_WIDTH = 64
) (
    input  logic clk,
    input  logic rst_n,
    input  logic flush,
    
    // Dispatch Interface (Allocate)
    input  logic [3:0]                      dispatch_val,
    input  logic [3:0][PHYS_REG_WIDTH-1:0]  dispatch_rd_phys,
    input  logic [3:0][ARCH_REG_WIDTH-1:0]  dispatch_rd_arch,
    input  logic [3:0][PC_WIDTH-1:0]        dispatch_pc,
    output logic                            rob_ready,
    
    // CDB Interface (Complete from ALUs/MUL/DIV/LSU)
    input  logic [3:0]                      cdb_val,
    input  logic [3:0][PHYS_REG_WIDTH-1:0]  cdb_rd_phys,
    input  logic [3:0]                      cdb_branch_mispredict,
    input  logic [3:0]                      cdb_exception,
    
    // Commit Interface (to Commit Unit)
    input  logic [3:0]                      commit_ack,
    output logic [3:0]                      commit_val,
    output logic [3:0][PHYS_REG_WIDTH-1:0]  commit_rd_phys,
    output logic [3:0][ARCH_REG_WIDTH-1:0]  commit_rd_arch,
    output logic [3:0]                      commit_branch_mispredict,
    output logic [3:0]                      commit_exception
);

    // ROB Array Structures
    logic                      valid_arr     [0:ROB_ENTRIES-1];
    logic                      completed_arr [0:ROB_ENTRIES-1];
    logic [PHYS_REG_WIDTH-1:0] rd_phys_arr   [0:ROB_ENTRIES-1];
    logic [ARCH_REG_WIDTH-1:0] rd_arch_arr   [0:ROB_ENTRIES-1];
    logic                      mispred_arr   [0:ROB_ENTRIES-1];
    logic                      except_arr    [0:ROB_ENTRIES-1];
    
    // Pointers
    logic [$clog2(ROB_ENTRIES)-1:0] head; // Points to oldest instruction to commit
    logic [$clog2(ROB_ENTRIES)-1:0] tail; // Points to next free slot for dispatch
    logic [$clog2(ROB_ENTRIES):0]   count;
    
    // Ready if there is space for 4 allocations
    assign rob_ready = (ROB_ENTRIES - count) >= 4;
    
    // Commit logic mapping (combinatorial reading of the head elements)
    always_comb begin
        for (int i = 0; i < 4; i++) begin
            logic [$clog2(ROB_ENTRIES)-1:0] idx;
            idx = (head + i) % ROB_ENTRIES;
            commit_val[i] = valid_arr[idx] && completed_arr[idx];
            commit_rd_phys[i] = rd_phys_arr[idx];
            commit_rd_arch[i] = rd_arch_arr[idx];
            commit_branch_mispredict[i] = mispred_arr[idx];
            commit_exception[i] = except_arr[idx];
            
            // Stop parallel commit if the previous instruction wasn't valid/completed
            // or if an exception/branch mispredict is detected (must flush sequentially).
            if (i > 0 && (!commit_val[i-1] || commit_branch_mispredict[i-1] || commit_exception[i-1])) begin
                commit_val[i] = 1'b0;
            end
        end
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<ROB_ENTRIES; i++) begin
                valid_arr[i] <= 1'b0;
                completed_arr[i] <= 1'b0;
            end
            head <= '0;
            tail <= '0;
            count <= '0;
        end else if (flush) begin
            for (int i=0; i<ROB_ENTRIES; i++) begin
                valid_arr[i] <= 1'b0;
                completed_arr[i] <= 1'b0;
            end
            head <= '0;
            tail <= '0;
            count <= '0;
        end else begin
            logic [2:0] dispatch_cnt;
            logic [2:0] commit_cnt;
            
            // 1. Completion (CDB Snooping)
            // Search the whole ROB for matching rd_phys and mark completed.
            for (int i = 0; i < ROB_ENTRIES; i++) begin
                if (valid_arr[i] && !completed_arr[i]) begin
                    for (int c = 0; c < 4; c++) begin
                        if (cdb_val[c] && (rd_phys_arr[i] == cdb_rd_phys[c])) begin
                            completed_arr[i] <= 1'b1;
                            mispred_arr[i] <= cdb_branch_mispredict[c];
                            except_arr[i]  <= cdb_exception[c];
                        end
                    end
                end
            end
            
            // 2. Allocation (Dispatch)
            dispatch_cnt = dispatch_val[0] + dispatch_val[1] + dispatch_val[2] + dispatch_val[3];
            
            if (rob_ready && dispatch_cnt > 0) begin
                for (int i = 0; i < 4; i++) begin
                    if (dispatch_val[i]) begin
                        logic [$clog2(ROB_ENTRIES)-1:0] alloc_idx;
                        alloc_idx = (tail + i) % ROB_ENTRIES;
                        valid_arr[alloc_idx]     <= 1'b1;
                        completed_arr[alloc_idx] <= 1'b0; // Wait for execution
                        rd_phys_arr[alloc_idx]   <= dispatch_rd_phys[i];
                        rd_arch_arr[alloc_idx]   <= dispatch_rd_arch[i];
                        mispred_arr[alloc_idx]   <= 1'b0;
                        except_arr[alloc_idx]    <= 1'b0;
                        
                        // Handle single-cycle complete for instructions with no execution latency (like NOPs)
                        // Handled elsewhere or explicitly completed.
                    end
                end
                tail <= (tail + dispatch_cnt) % ROB_ENTRIES;
            end
            
            // 3. Deallocation (Commit)
            commit_cnt = commit_ack[0] + commit_ack[1] + commit_ack[2] + commit_ack[3];
            
            if (commit_cnt > 0) begin
                for (int i = 0; i < 4; i++) begin
                    if (commit_ack[i]) begin
                        logic [$clog2(ROB_ENTRIES)-1:0] dealloc_idx;
                        dealloc_idx = (head + i) % ROB_ENTRIES;
                        valid_arr[dealloc_idx] <= 1'b0;
                    end
                end
                head <= (head + commit_cnt) % ROB_ENTRIES;
            end
            
            count <= count + dispatch_cnt - commit_cnt;
        end
    end

endmodule
