`timescale 1ns/1ps

module apb_register_file (
    input  logic clk,
    input  logic rst_n,
    output logic [ADDR_WIDTH-1:0] paddr,
    output logic psel,
    output logic penable,
    output logic pwrite,
    output logic [DATA_WIDTH-1:0] pwdata,
    output logic [DATA_WIDTH-1:0] prdata,
    output logic pready,
    output logic pslverr,
    output logic [DATA_WIDTH-1:0] [0:NUM_REGS-1] reg_out,
    output logic [DATA_WIDTH-1:0] [0:NUM_REGS-1] reg_in
);

endmodule
