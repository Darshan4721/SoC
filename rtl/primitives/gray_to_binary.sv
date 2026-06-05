`timescale 1ns/1ps

module gray_to_binary #(
    parameter WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic [WIDTH-1:0] gray_in,
    output logic [WIDTH-1:0] bin_out
);
    logic [WIDTH-1:0] bin_next;
    
    always_comb begin
        bin_next[WIDTH-1] = gray_in[WIDTH-1];
        for (int i = WIDTH-2; i >= 0; i--) begin
            bin_next[i] = bin_next[i+1] ^ gray_in[i];
        end
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) bin_out <= '0;
        else        bin_out <= bin_next;
    end
endmodule
