`timescale 1ns/1ps

module radix4_booth_encoder (
    input  logic [2:0] mult,
    output logic       neg,
    output logic       zero,
    output logic       two,
    output logic       one
);
    always_comb begin
        neg  = mult[2];
        zero = (mult == 3'b000) || (mult == 3'b111);
        two  = (mult == 3'b011) || (mult == 3'b100);
        one  = (mult == 3'b001) || (mult == 3'b010) || (mult == 3'b101) || (mult == 3'b110);
    end
endmodule
