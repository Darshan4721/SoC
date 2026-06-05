`timescale 1ns/1ps

module ddr4_phy_interface (
    input  logic clk,
    input  logic rst_n,
    output logic dfi_rddata_en,
    output logic dfi_wrdata_en,
    output logic [63:0] dfi_wrdata,
    output logic [63:0] dfi_rddata,
    output logic dfi_rddata_valid,
    output logic [13:0] dfi_address,
    output logic [2:0] dfi_bank,
    output logic [1:0] dfi_bg,
    output logic dfi_cas_n,
    output logic dfi_ras_n,
    output logic dfi_we_n,
    output logic dfi_cs_n,
    output logic [13:0] ddr4_a,
    output logic [2:0] ddr4_ba,
    output logic [1:0] ddr4_bg,
    output logic ddr4_act_n,
    output wire  [63:0] ddr4_dq,
    output wire  [7:0] ddr4_dqs_t,
    output wire  [7:0] ddr4_dqs_c
);

endmodule
