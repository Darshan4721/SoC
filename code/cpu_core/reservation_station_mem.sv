`timescale 1ns/1ps

module reservation_station_mem (
    input  logic clk,
    input  logic rst_n,
    output logic disp_valid,
    output logic [6:0] disp_phys_rs1,
    output logic [6:0] disp_phys_rs2,
    output logic disp_rs1_ready,
    output logic disp_rs2_ready,
    output logic [63:0] disp_payload,
    output logic rs_full,
    output logic [3:0] cdb_valid,
    output logic [6:0] [0:3] cdb_phys_rd,
    output logic mem_ready,
    output logic issue_valid,
    output logic [63:0] issue_payload
);

endmodule
