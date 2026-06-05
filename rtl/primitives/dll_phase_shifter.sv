`timescale 1ns/1ps

module dll_phase_shifter (
    input  logic       clk_in,
    input  logic       rst_n,
    input  logic [3:0] phase_sel,
    output logic       clk_out,
    output logic       locked
);
    // Behavioral model for DLL. Mapped to physical IP.
    assign clk_out = clk_in;
    
    always_ff @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) locked <= 1'b0;
        else        locked <= 1'b1;
    end
endmodule
