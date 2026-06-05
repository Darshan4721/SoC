`timescale 1ns/1ps

module vector_reduction_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [3:0] op_type,
    output logic [1:0] sew,
    output logic [VLEN-1:0] vs2,
    output logic [63:0] vs1,
    output logic [(VLEN/8)-1:0] v0_mask,
    output logic valid_out,
    output logic [63:0] vd
);

endmodule
