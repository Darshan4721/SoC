`timescale 1ns/1ps

module decoder_5to32 (
    input  logic        en,
    input  logic [4:0]  sel,
    output logic [31:0] dec_out
);
    always_comb begin
        dec_out = '0;
        if (en) begin
            dec_out[sel] = 1'b1;
        end
    end
endmodule
