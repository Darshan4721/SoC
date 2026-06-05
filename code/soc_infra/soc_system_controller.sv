`timescale 1ns/1ps

module soc_system_controller (
    input  logic clk,
    input  logic rst_n,
    output logic [2:0] boot_mode,
    input  logic sw_rst_req,
    output logic [31:0] hw_version,
    output logic crypto_init_req
);

endmodule
