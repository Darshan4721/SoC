`timescale 1ns/1ps

module rv32_forward_unit (
    output logic ex_mem_can_forward_i,
    output logic [4:0] ex_mem_rd_i,
    output logic mem_wb_regwrite_i,
    output logic [4:0] mem_wb_rd_i,
    output logic [4:0] id_ex_rs1_i,
    output logic [4:0] id_ex_rs2_i,
    output logic [1:0] fwd_a_sel_o,
    output logic [1:0] fwd_b_sel_o
);

endmodule
