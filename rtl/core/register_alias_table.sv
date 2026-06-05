`timescale 1ns/1ps
module register_alias_table #(
    parameter ARCH_REGS = 32,
    parameter ARCH_REG_WIDTH = 5,
    parameter PHYS_REG_WIDTH = 7
) (
    input  logic clk,
    input  logic rst_n,
    
    // Flush Interface (Restore from Architectural RAT on Branch Mispredict)
    input  logic flush,
    input  logic [ARCH_REGS-1:0][PHYS_REG_WIDTH-1:0] arat_state,
    
    // Read Ports (4 instructions * 2 sources = 8 read ports)
    input  logic [3:0]                rat_read_req,
    input  logic [3:0][ARCH_REG_WIDTH-1:0] rat_read_rs1,
    input  logic [3:0][ARCH_REG_WIDTH-1:0] rat_read_rs2,
    output logic [3:0][PHYS_REG_WIDTH-1:0] rat_rs1_phys,
    output logic [3:0][PHYS_REG_WIDTH-1:0] rat_rs2_phys,
    
    // Write Ports (4 instructions * 1 destination = 4 write ports)
    input  logic [3:0]                rat_write_req,
    input  logic [3:0][ARCH_REG_WIDTH-1:0] rat_write_rd,
    input  logic [3:0][PHYS_REG_WIDTH-1:0] rat_write_phys
);

    logic [PHYS_REG_WIDTH-1:0] rat_table [0:ARCH_REGS-1];
    
    // Read Logic (Combinatorial)
    always_comb begin
        for (int i = 0; i < 4; i++) begin
            if (rat_read_req[i]) begin
                // x0 is hardwired to physical register 0
                rat_rs1_phys[i] = (rat_read_rs1[i] == 0) ? '0 : rat_table[rat_read_rs1[i]];
                rat_rs2_phys[i] = (rat_read_rs2[i] == 0) ? '0 : rat_table[rat_read_rs2[i]];
            end else begin
                rat_rs1_phys[i] = '0;
                rat_rs2_phys[i] = '0;
            end
        end
    end
    
    // Write Logic (Sequential)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < ARCH_REGS; i++) begin
                rat_table[i] <= i[PHYS_REG_WIDTH-1:0]; // Initial 1:1 mapping
            end
        end else if (flush) begin
            // On a branch mispredict, the speculative RAT is overwritten by the precise ARAT
            for (int i = 0; i < ARCH_REGS; i++) begin
                rat_table[i] <= arat_state[i];
            end
        end else begin
            for (int i = 0; i < 4; i++) begin
                if (rat_write_req[i] && rat_write_rd[i] != 0) begin
                    rat_table[rat_write_rd[i]] <= rat_write_phys[i];
                end
            end
        end
    end

endmodule
