`timescale 1ns/1ps

module vector_lane_0 (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [31:0] v_instr,
    output logic [LANE_WIDTH-1:0] vs1_data,
    output logic [LANE_WIDTH-1:0] vs2_data,
    output logic [LANE_WIDTH-1:0] vs3_data,
    output logic v0_mask,
    output logic valid_out,
    output logic [LANE_WIDTH-1:0] vd_data
);

endmodule
