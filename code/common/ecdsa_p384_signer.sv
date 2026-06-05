`timescale 1ns/1ps

module ecdsa_p384_signer (
    input  logic clk,
    input  logic rst_n,
    output logic start,
    output logic ready,
    output logic done,
    output logic [383:0] private_key,
    output logic [383:0] message_hash,
    output logic [383:0] random_k,
    output logic [383:0] sig_r,
    output logic [383:0] sig_s
);

endmodule
