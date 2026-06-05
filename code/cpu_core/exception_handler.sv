`timescale 1ns/1ps

module exception_handler (
    input  logic clk,
    input  logic rst_n,
    output logic exception_valid,
    output logic [3:0] exception_cause,
    output logic [63:0] exception_pc,
    output logic [63:0] exception_tval,
    output logic csr_trap_req,
    output logic [3:0] csr_trap_cause,
    output logic [63:0] csr_trap_pc,
    output logic [63:0] csr_trap_val,
    output logic trap_redirect_valid,
    output logic [63:0] trap_redirect_pc,
    output logic [63:0] trap_vector_base
);

endmodule
