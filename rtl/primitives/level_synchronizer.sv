`timescale 1ns/1ps

module level_synchronizer (
    input  logic clk_dest,
    input  logic rst_dest_n,
    input  logic sig_in,
    output logic sig_out
);
    logic sync1;
    
    always_ff @(posedge clk_dest or negedge rst_dest_n) begin
        if (!rst_dest_n) begin
            sync1   <= 1'b0;
            sig_out <= 1'b0;
        end else begin
            sync1   <= sig_in;
            sig_out <= sync1;
        end
    end
endmodule
