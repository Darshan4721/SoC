`timescale 1ns/1ps

module trap_vector_ctrl (
    input  logic clk,
    input  logic rst_n,
    output logic msip,
    output logic mtip,
    output logic meip,
    output logic mstatus_mie,
    output logic [63:0] mie,
    output logic [63:0] mip,
    output logic interrupt_valid,
    output logic [3:0] interrupt_cause
);

endmodule
