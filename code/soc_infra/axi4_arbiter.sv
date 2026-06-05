`timescale 1ns/1ps

module axi4_arbiter (
    input  logic clk,
    input  logic rst_n,
    output logic [3:0] req,
    output logic done,
    output logic [3:0] grant,
    output logic [1:0] grant_id
);

endmodule
