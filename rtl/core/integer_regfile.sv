`timescale 1ns/1ps
module integer_regfile #(
    parameter DATA_WIDTH = 64,
    parameter PHYS_REGS = 128,
    parameter PHYS_REG_WIDTH = 7
) (
    input  logic clk,
    input  logic rst_n,
    
    // 8 Read Ports (4 instructions * 2 operands)
    input  logic [7:0]                      read_req,
    input  logic [7:0][PHYS_REG_WIDTH-1:0]  read_addr,
    output logic [7:0][DATA_WIDTH-1:0]      read_data,
    
    // 4 Write Ports (4 execution units committing/completing)
    input  logic [3:0]                      write_req,
    input  logic [3:0][PHYS_REG_WIDTH-1:0]  write_addr,
    input  logic [3:0][DATA_WIDTH-1:0]      write_data
);

    // The physical register array
    logic [DATA_WIDTH-1:0] phys_regs [0:PHYS_REGS-1];
    
    // Read Logic (Combinatorial)
    always_comb begin
        for (int i = 0; i < 8; i++) begin
            if (read_req[i]) begin
                // Physical register 0 is always mapped to Architectural x0 = 0
                if (read_addr[i] == 0) begin
                    read_data[i] = '0;
                end else begin
                    read_data[i] = phys_regs[read_addr[i]];
                end
            end else begin
                read_data[i] = '0;
            end
        end
    end
    
    // Write Logic (Sequential)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < PHYS_REGS; i++) begin
                phys_regs[i] <= '0;
            end
        end else begin
            for (int i = 0; i < 4; i++) begin
                if (write_req[i] && write_addr[i] != 0) begin
                    phys_regs[write_addr[i]] <= write_data[i];
                end
            end
        end
    end

endmodule
