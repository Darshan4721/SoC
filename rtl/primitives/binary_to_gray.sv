`timescale 1ns/1ps

module binary_to_gray #(
    parameter WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] bin_in,
    output logic [WIDTH-1:0] gray_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) gray_out <= '0;
        else        gray_out <= bin_in ^ (bin_in >> 1);
    end
endmodule
