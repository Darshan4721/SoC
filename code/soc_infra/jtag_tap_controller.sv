`timescale 1ns/1ps

module jtag_tap_controller (
    output logic tck,
    input  logic trst_n,
    output logic tms,
    output logic tdi,
    output logic tdo,
    output logic shift_dr,
    output logic shift_ir,
    output logic update_dr,
    output logic update_ir,
    output logic capture_dr,
    output logic [4:0] ir_reg,
    output logic dr_in
);

endmodule
