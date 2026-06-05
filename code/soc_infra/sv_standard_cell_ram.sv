`timescale 1ns/1ps

module sv_standard_cell_ram (
    input  logic clk,
    input  logic rst_n,
    output logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] wdata,
    output logic we,
    output logic [DATA_WIDTH-1:0] rdata
);

endmodule
