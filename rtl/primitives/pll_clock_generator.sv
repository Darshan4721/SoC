`timescale 1ns/1ps

module pll_clock_generator (
    input  logic       clk_ref,
    input  logic       rst_n,
    input  logic [7:0] mult,
    input  logic [7:0] div,
    output logic       clk_out,
    output logic       locked
);
    // Behavioral model for simulation. 
    // In physical design, this is mapped to a hard IP macro (e.g. TSMC PLL or Xilinx MMCM).
    assign clk_out = clk_ref; // Passthrough for RTL
    
    always_ff @(posedge clk_ref or negedge rst_n) begin
        if (!rst_n) locked <= 1'b0;
        else        locked <= 1'b1;
    end
endmodule
