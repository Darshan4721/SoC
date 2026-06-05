`timescale 1ns/1ps
module pc_gen_unit #(
    parameter ADDR_WIDTH = 64
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Control Interface
    input  logic                  stall,
    input  logic                  flush,
    
    // Branch / Jump Interface
    input  logic                  branch_taken,
    input  logic [ADDR_WIDTH-1:0] branch_target,
    
    // I-Cache Interface
    output logic                  icache_req_val,
    output logic [ADDR_WIDTH-1:0] icache_req_addr,
    input  logic                  icache_req_rdy,
    
    // Output PC to Fetch Stage
    output logic [ADDR_WIDTH-1:0] current_pc,
    output logic                  valid_pc
);

    logic [ADDR_WIDTH-1:0] pc_reg, next_pc;
    
    always_comb begin
        if (branch_taken) begin
            next_pc = branch_target;
        end else if (!stall && icache_req_rdy) begin
            next_pc = pc_reg + 32'h4; // 4 bytes per instruction (RV32/64)
        end else begin
            next_pc = pc_reg;
        end
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_reg <= 64'h8000_0000; // Standard RV64 boot address
        end else if (flush) begin
            pc_reg <= branch_target; // Flush redirects to correct target
        end else begin
            pc_reg <= next_pc;
        end
    end
    
    assign current_pc = pc_reg;
    assign icache_req_val = !stall && !flush;
    assign icache_req_addr = pc_reg;
    assign valid_pc = !stall && !flush && icache_req_rdy;

endmodule
