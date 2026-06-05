`timescale 1ns/1ps

module csr_register_file (
    input  logic clk,
    input  logic rst_n,
    output logic [11:0] read_addr,
    output logic [DATA_WIDTH-1:0] read_data,
    output logic write_en,
    output logic [11:0] write_addr,
    output logic [DATA_WIDTH-1:0] write_data,
    output logic commit_valid,
    output logic trap_valid,
    output logic [DATA_WIDTH-1:0] trap_pc,
    output logic [DATA_WIDTH-1:0] trap_cause,
    output logic [DATA_WIDTH-1:0] trap_val,
    output logic [DATA_WIDTH-1:0] mstatus_out,
    output logic [DATA_WIDTH-1:0] mtvec_out,
    output logic [DATA_WIDTH-1:0] mepc_out
);

endmodule
