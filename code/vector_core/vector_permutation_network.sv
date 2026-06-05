`timescale 1ns/1ps

module vector_permutation_network (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [VLEN-1:0] vs2,
    output logic [VLEN-1:0] vs1,
    output logic [1:0] sew,
    output logic [VLEN-1:0] vold,
    output logic [(VLEN/8)-1:0] v0_mask,
    output logic valid_out,
    output logic [VLEN-1:0] vd
);

endmodule
