`timescale 1ns/1ps

module l2_cache_coherency_dir (
    input  logic clk,
    input  logic rst_n,
    output logic rd_en,
    output logic [$clog2(SETS)-1:0] rd_index,
    output logic [NUM_CORES-1:0] [0:WAYS-1] rd_sharers,
    output logic [1:0] [0:WAYS-1] rd_state,
    output logic wr_en,
    output logic [$clog2(SETS)-1:0] wr_index,
    output logic [$clog2(WAYS)-1:0] wr_way,
    output logic [NUM_CORES-1:0] wr_sharers,
    output logic [1:0] wr_state
);

endmodule
