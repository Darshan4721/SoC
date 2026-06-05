`timescale 1ns/1ps

module sv_standard_cell_rom #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH = 256,
    parameter INIT_FILE = ""
) (
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     re,
    input  logic [$clog2(DEPTH)-1:0] addr,
    output logic [DATA_WIDTH-1:0]    rdata
);
    logic [DATA_WIDTH-1:0] rom_array [0:DEPTH-1];

    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, rom_array);
        end
    end

    always_ff @(posedge clk) begin
        if (re) begin
            rdata <= rom_array[addr];
        end
    end
endmodule
