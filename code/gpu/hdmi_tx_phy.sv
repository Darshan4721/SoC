`timescale 1ns/1ps

module hdmi_tx_phy (
    input  logic pixel_clk,
    input  logic pixel_clk_x5,
    input  logic rst_n,
    output logic [23:0] pixel_data,
    output logic hsync,
    output logic vsync,
    output logic de,
    input  logic tmds_clk_p,
    input  logic tmds_clk_n,
    output logic [2:0] tmds_data_p,
    output logic [2:0] tmds_data_n
);

endmodule
