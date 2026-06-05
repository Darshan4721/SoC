`timescale 1ns/1ps

module reset_sequencer (
    input  logic clk_ref,
    input  logic ext_rst_n,
    input  logic wdt_rst_n,
    input  logic sw_rst_n,
    input  logic sys_rst_n,
    input  logic core_rst_n,
    input  logic periph_rst_n,
    input  logic mem_rst_n
);

endmodule
