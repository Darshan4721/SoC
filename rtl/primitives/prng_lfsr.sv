`timescale 1ns/1ps

module prng_lfsr (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] seed,
    input  logic        load,
    input  logic        en,
    output logic [31:0] rand_out
);
    logic [31:0] lfsr;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr <= 32'hDEADBEEF;
        end else if (load) begin
            lfsr <= seed;
        end else if (en) begin
            // Galois LFSR x^32 + x^22 + x^2 + x^1 + 1
            lfsr <= {lfsr[30:0], 1'b0} ^ ({32{lfsr[31]}} & 32'h80200003);
        end
    end
    
    assign rand_out = lfsr;
endmodule
