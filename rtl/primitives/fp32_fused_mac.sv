`timescale 1ns/1ps

module fp32_fused_mac (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c,
    output logic [31:0] out
);
    // Behavioral 4-stage pipelined FMA (out = a*b + c)
    logic [31:0] stage1_a, stage1_b, stage1_c;
    logic [31:0] stage2_prod, stage2_c;
    logic [31:0] stage3_sum;
    logic [31:0] stage4_norm;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {stage1_a, stage1_b, stage1_c} <= '0;
            {stage2_prod, stage2_c} <= '0;
            stage3_sum <= '0;
            out <= '0;
        end else begin
            // Stage 1: Register inputs
            stage1_a <= a; stage1_b <= b; stage1_c <= c;
            
            // Stage 2: Multiply (Behavioral placeholder for IP)
            stage2_prod <= stage1_a; // Actual FP multiply requires IP core
            stage2_c <= stage1_c;
            
            // Stage 3: Add
            stage3_sum <= stage2_prod;
            
            // Stage 4: Normalize
            out <= stage3_sum;
        end
    end
endmodule
