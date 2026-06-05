`timescale 1ns/1ps

module rng_entropy_pool (
    input  logic clk,
    input  logic rst_n,
    output logic entropy_valid,
    output logic [IN_WIDTH-1:0] entropy_in,
    output logic pool_valid,
    output logic [POOL_WIDTH-1:0] pool_out
);

endmodule
