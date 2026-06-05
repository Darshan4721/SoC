`timescale 1ns/1ps

module rv32_hazard_unit (
    output logic id_rs1_used_i,
    output logic id_rs2_used_i,
    output logic [4:0] id_rs1_i,
    output logic [4:0] id_rs2_i,
    output logic id_ex_mem_read_i,
    output logic [4:0] id_ex_rd_i,
    output logic branch_flush_i,
    output logic pc_stall_o,
    output logic if_id_stall_o,
    output logic if_id_flush_o,
    output logic id_ex_flush_o
);

endmodule
