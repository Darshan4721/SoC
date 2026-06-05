`timescale 1ns/1ps

module sha256_message_schedule_array (
    input  logic clk,
    input  logic rst_n,
    output logic write_en,
    output logic [5:0] write_addr,
    output logic [31:0] write_data,
    output logic read_en,
    output logic [5:0] read_addr,
    output logic [31:0] read_data
);

endmodule
