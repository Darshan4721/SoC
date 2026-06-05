`timescale 1ns/1ps

module csr_control_unit (
    input  logic clk,
    input  logic rst_n,
    output logic csr_cmd_valid,
    output logic [11:0] csr_addr,
    output logic [1:0] csr_op,
    output logic [63:0] csr_wdata,
    output logic [63:0] csr_rdata,
    output logic trap_req,
    output logic [3:0] trap_cause,
    output logic [63:0] trap_pc,
    output logic [63:0] trap_val,
    output logic mret_valid,
    output logic [63:0] mstatus,
    output logic [63:0] mtvec,
    output logic [63:0] mepc,
    output logic [63:0] mie,
    output logic [63:0] mip
);

endmodule
