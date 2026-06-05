`timescale 1ns/1ps

module sram_controller (
    input  logic clk,
    output logic en,
    output logic we,
    output logic [DATA_WIDTH/8-1:0] be,
    output logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] wdata,
    output logic [DATA_WIDTH-1:0] rdata
);

endmodule
