`timescale 1ns/1ps

module ddr4_command_scheduler (
    input  logic clk,
    input  logic rst_n,
    output logic cmd_req,
    output logic [2:0] cmd_type,
    output logic [63:0] cmd_addr,
    output logic cmd_ack,
    output logic ref_req,
    output logic ref_ack,
    output logic dfi_rddata_en,
    output logic dfi_wrdata_en,
    output logic [13:0] dfi_address,
    output logic [2:0] dfi_bank,
    output logic [1:0] dfi_bg,
    output logic dfi_cas_n,
    output logic dfi_ras_n,
    output logic dfi_we_n,
    output logic dfi_cs_n
);

endmodule
