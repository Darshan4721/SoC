`timescale 1ns/1ps

module lsq_control_unit (
    input  logic clk,
    input  logic rst_n,
    output logic load_addr_valid,
    output logic [63:0] load_addr,
    output logic [31:0] sq_entry_valid,
    output logic [31:0] sq_addr_ready,
    output logic [63:0] [0:31] sq_addrs,
    output logic [31:0] older_mask,
    output logic hazard_detected,
    output logic forward_valid,
    output logic [4:0] forward_sq_idx
);

endmodule
