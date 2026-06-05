`timescale 1ns/1ps

module rv32_wb_mux (
    output logic [31:0] alu_result_i,
    output logic [31:0] load_data_i,
    output logic [31:0] pc_plus4_i,
    output logic [1:0] wb_sel_i,
    output logic [31:0] wb_data_o
);

endmodule
