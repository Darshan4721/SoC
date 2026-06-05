`timescale 1ns/1ps

module aes_gcm_crypto_engine (
    input  logic clk,
    input  logic rst_n,
    output logic start,
    output logic encrypt_decrypt_n,
    output logic [255:0] key,
    output logic [95:0] iv,
    output logic in_valid,
    output logic [127:0] in_data,
    output logic in_ready,
    output logic out_valid,
    output logic [127:0] out_data,
    output logic out_ready,
    output logic tag_valid,
    output logic [127:0] auth_tag
);

endmodule
