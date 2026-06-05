`timescale 1ns/1ps

module l3_cache_data_banks (
    input  logic clk,
    input  logic rst_n,
    output logic read_en,
    output logic [$clog2(SETS)-1:0] read_index,
    output logic [$clog2(WAYS)-1:0] read_way,
    output logic [LINE_SIZE*8-1:0] read_data,
    output logic write_en,
    output logic [$clog2(SETS)-1:0] write_index,
    output logic [$clog2(WAYS)-1:0] write_way,
    output logic [LINE_SIZE-1:0] write_mask,
    output logic [LINE_SIZE*8-1:0] write_data
);

endmodule
