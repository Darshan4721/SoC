`timescale 1ns/1ps

module fpu_exception_flags (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [63:0] a,
    output logic [63:0] b,
    output logic [63:0] c,
    output logic [3:0] op_type,
    output logic raw_of,
    output logic raw_uf,
    output logic raw_nx,
    output logic raw_dz,
    output logic valid_out,
    output logic [4:0] fflags
);

endmodule
