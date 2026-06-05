`timescale 1ns/1ps

module l3_cache_tags (
    input  logic clk,
    input  logic rst_n,
    output logic read_valid,
    output logic [PPN_WIDTH-1:0] read_ppn,
    output logic [$clog2(SETS)-1:0] read_index,
    output logic hit,
    output logic [$clog2(WAYS)-1:0] hit_way,
    output logic [1:0] mesi_state_out,
    output logic write_en,
    output logic [$clog2(SETS)-1:0] write_index,
    output logic [PPN_WIDTH-1:0] write_tag,
    output logic [$clog2(WAYS)-1:0] write_way,
    output logic [1:0] mesi_state_in,
    output logic update_mesi,
    output logic [$clog2(SETS)-1:0] update_index,
    output logic [$clog2(WAYS)-1:0] update_way,
    output logic [1:0] update_mesi_state
);

endmodule
