`timescale 1ns/1ps

module weight_scratchpad_bank_0 (
    input  logic clk,
    input  logic rst_n,
    output logic read_en,
    output logic [$clog2(DEPTH)-1:0] read_addr,
    output logic [DATA_WIDTH-1:0] read_data,
    output logic write_en,
    output logic [$clog2(DEPTH)-1:0] write_addr,
    output logic [DATA_WIDTH-1:0] write_data
);

endmodule
