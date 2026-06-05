`timescale 1ns/1ps

module barrel_shifter_64 (
    input  logic [63:0] data_in,
    input  logic [5:0]  shift_amt,
    input  logic        arith,
    output logic [63:0] data_out
);
    always_comb begin
        if (arith) begin
            data_out = $signed(data_in) >>> shift_amt;
        end else begin
            data_out = data_in >> shift_amt;
        end
    end
endmodule
