`timescale 1ns/1ps

module vector_slide_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [1:0] op_type,
    output logic [1:0] sew,
    output logic [VLEN-1:0] vs2,
    output logic [VLEN-1:0] vd_old,
    output logic [31:0] offset,
    output logic [63:0] scalar_in,
    output logic [(VLEN/8)-1:0] v0_mask,
    output logic valid_out,
    output logic [VLEN-1:0] vd
);

endmodule
