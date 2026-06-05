`timescale 1ns/1ps

module pulse_synchronizer (
    input  logic clk_src,
    input  logic rst_src_n,
    input  logic pulse_in,
    
    input  logic clk_dest,
    input  logic rst_dest_n,
    output logic pulse_out
);
    logic toggle_src;
    logic sync1, sync2, sync3;
    
    always_ff @(posedge clk_src or negedge rst_src_n) begin
        if (!rst_src_n) toggle_src <= 1'b0;
        else if (pulse_in) toggle_src <= ~toggle_src;
    end
    
    always_ff @(posedge clk_dest or negedge rst_dest_n) begin
        if (!rst_dest_n) begin
            sync1 <= 1'b0;
            sync2 <= 1'b0;
            sync3 <= 1'b0;
        end else begin
            sync1 <= toggle_src;
            sync2 <= sync1;
            sync3 <= sync2;
        end
    end
    
    assign pulse_out = sync2 ^ sync3;
endmodule
