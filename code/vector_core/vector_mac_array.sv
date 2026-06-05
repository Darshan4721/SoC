`timescale 1ns/1ps

module vector_mac_array (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic [3:0] op_type,
    output logic [1:0] sew,
    output logic [LANE_WIDTH-1:0] vs1,
    output logic [LANE_WIDTH-1:0] vs2,
    output logic [LANE_WIDTH-1:0] vs3,
    output logic [(LANE_WIDTH/8)-1:0] v0_mask,
    output logic valid_out,
    output logic [LANE_WIDTH-1:0] vd
);

endmodule
