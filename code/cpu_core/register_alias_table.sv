`timescale 1ns/1ps

module register_alias_table (
    input  logic clk,
    input  logic rst_n,
    output logic [4:0] logical_rs1,
    output logic [4:0] logical_rs2,
    output logic [6:0] phys_rs1,
    output logic [6:0] phys_rs2,
    output logic rename_valid,
    output logic [4:0] logical_rd,
    output logic [6:0] allocated_phys_rd,
    output logic recover_valid,
    output logic [6:0] [0:ARCH_REGS-1] recovery_map
);

endmodule
