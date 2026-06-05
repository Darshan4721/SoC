`timescale 1ns/1ps

module dvfs_power_controller (
    input  logic clk,
    input  logic rst_n,
    input  logic s_awvalid,
    output logic s_awready,
    input  logic [31:0] s_awaddr,
    input  logic s_wvalid,
    output logic s_wready,
    input  logic [31:0] s_wdata,
    output logic s_bvalid,
    input  logic s_bready,
    output logic s_arvalid,
    output logic s_arready,
    input  logic [31:0] s_araddr,
    output logic s_rvalid,
    input  logic s_rready,
    input  logic [31:0] s_rdata,
    output logic pll_update_req,
    output logic [7:0] pll_mult_ratio,
    output logic [3:0] pll_div_ratio,
    output logic pll_locked,
    output logic pmic_i2c_req,
    output logic [7:0] pmic_i2c_addr,
    output logic [7:0] pmic_i2c_data,
    output logic pmic_i2c_ack
);

endmodule
