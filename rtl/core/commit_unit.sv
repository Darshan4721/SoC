`timescale 1ns/1ps
module commit_unit #(
    parameter PHYS_REG_WIDTH = 7,
    parameter ARCH_REG_WIDTH = 5,
    parameter ARCH_REGS = 32
) (
    input  logic clk,
    input  logic rst_n,
    
    // Interface from ROB
    input  logic [3:0]                      commit_val,
    input  logic [3:0][PHYS_REG_WIDTH-1:0]  commit_rd_phys,
    input  logic [3:0][ARCH_REG_WIDTH-1:0]  commit_rd_arch,
    input  logic [3:0]                      commit_branch_mispredict,
    input  logic [3:0]                      commit_exception,
    output logic [3:0]                      commit_ack,
    
    // Architectural Register Alias Table (ARAT)
    // Represents the true, precise committed state of the machine.
    output logic [ARCH_REGS-1:0][PHYS_REG_WIDTH-1:0] arat_state,
    
    // Interface to Freelist Manager (Freeing old physical registers)
    output logic [3:0]                      fl_free_req,
    output logic [3:0][PHYS_REG_WIDTH-1:0]  fl_free_phys_id,
    
    // Global Exception/Flush Signals
    output logic                            global_flush,
    output logic [63:0]                     exception_vector
);

    // The Architectural RAT (ARAT).
    // Stores the precise mapping of Arch->Phys registers at the commit point.
    logic [PHYS_REG_WIDTH-1:0] arat [0:ARCH_REGS-1];
    
    // Output ARAT state for branch mispredict recovery in the speculative RAT
    always_comb begin
        for (int i = 0; i < ARCH_REGS; i++) begin
            arat_state[i] = arat[i];
        end
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < ARCH_REGS; i++) begin
                arat[i] <= i[PHYS_REG_WIDTH-1:0]; // Initial 1:1 mapping
            end
            global_flush <= 1'b0;
            for (int i=0; i<4; i++) begin
                fl_free_req[i] <= 1'b0;
            end
        end else begin
            global_flush <= 1'b0;
            for (int i = 0; i < 4; i++) begin
                commit_ack[i] <= 1'b0;
                fl_free_req[i] <= 1'b0;
            end
            
            // In-Order Commit processing
            // Assuming the ROB logically guarantees that if commit_val[i] is 1, all prior instructions are also valid.
            for (int i = 0; i < 4; i++) begin
                if (commit_val[i] && !global_flush) begin
                    
                    // 1. Check for Exception or Branch Mispredict
                    if (commit_exception[i] || commit_branch_mispredict[i]) begin
                        global_flush <= 1'b1;
                        // For mispredict, the flush naturally causes the front-end to restore from ARAT.
                        // Do not commit any further instructions in this cycle.
                        break; 
                    end
                    
                    // 2. Commit the instruction
                    commit_ack[i] <= 1'b1;
                    
                    // 3. Update ARAT and Free the OVERWRITTEN physical register
                    if (commit_rd_arch[i] != 0) begin
                        // Free the old physical register mapped to this arch register
                        fl_free_req[i] <= 1'b1;
                        fl_free_phys_id[i] <= arat[commit_rd_arch[i]];
                        
                        // Update ARAT with the newly committed physical register
                        arat[commit_rd_arch[i]] <= commit_rd_phys[i];
                    end
                end
            end
        end
    end

endmodule
