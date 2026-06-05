`timescale 1ns/1ps

module gemini_soc_top (
    input  logic clk_ref,
    input  logic rtc_clk_ext,
    input  logic ext_rst_n,
    output logic [2:0] boot_mode,
    output logic tck,
    input  logic trst_n,
    output logic tms,
    output logic tdi,
    output logic tdo,
    output wire  [63:0] gpio_pads
);

endmodule
