`timescale 1ns/1ps

module skid_buffer (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic ready_out,
    output logic [DATA_WIDTH-1:0] data_in,
    output logic valid_out,
    input  logic ready_in,
    output logic [DATA_WIDTH-1:0] data_out
);

endmodule
