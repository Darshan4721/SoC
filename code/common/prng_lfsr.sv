`timescale 1ns/1ps

module prng_lfsr (
    input  logic clk,
    input  logic rst_n,
    output logic [31:0] seed,
    output logic load_seed,
    output logic en,
    output logic [31:0] rand_out
);

endmodule
