`timescale 1ns/1ps

module sha3_512_hash_engine (
    input  logic clk,
    input  logic rst_n,
    output logic init,
    output logic update,
    output logic finalize,
    output logic [575:0] msg_block,
    output logic ready,
    output logic valid,
    output logic [511:0] digest
);

endmodule
