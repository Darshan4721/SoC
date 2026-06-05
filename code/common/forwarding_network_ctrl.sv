`timescale 1ns/1ps

module forwarding_network_ctrl (
    output logic [0:3] ex_valid,
    output logic [6:0] [0:3] ex_prd,
    output logic [63:0] [0:3] ex_data,
    output logic mem_valid,
    output logic [6:0] mem_prd,
    output logic [63:0] mem_data,
    output logic req_valid,
    output logic [6:0] req_prs1,
    output logic [6:0] req_prs2,
    output logic [63:0] rf_rs1_data,
    output logic [63:0] rf_rs2_data,
    output logic [63:0] fwd_rs1_data,
    output logic [63:0] fwd_rs2_data
);

endmodule
