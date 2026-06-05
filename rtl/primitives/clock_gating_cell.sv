`timescale 1ns/1ps

module clock_gating_cell (
    input  logic rst_n,
    input  logic clk_in,
    input  logic en,
    input  logic test_en,
    output logic clk_out
);
    logic latch_en;
    
    always_latch begin
        if (!clk_in) begin
            latch_en <= en | test_en;
        end
    end
    
    assign clk_out = clk_in & latch_en;
endmodule
