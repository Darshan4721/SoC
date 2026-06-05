`timescale 1ns/1ps

module vector_processing_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [31:0] v_instr,
    output logic [63:0] rs1_data,
    output logic [63:0] rs2_data,
    output logic ready_out,
    output logic valid_out,
    output logic [VLEN-1:0] vd_data_out
);

endmodule
