`timescale 1ns/1ps

module trng_entropy_source (
    input  logic clk,
    input  logic rst_n,
    output logic enable,
    output logic valid,
    output logic [31:0] random_data,
    output logic ready
);

endmodule
