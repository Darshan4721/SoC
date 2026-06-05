`timescale 1ns/1ps

module aes_key_schedule_mem (
    input  logic clk,
    input  logic rst_n,
    output logic write_en,
    output logic [5:0] write_addr,
    output logic [31:0] write_data,
    output logic [3:0] read_addr,
    output logic [127:0] read_data
);

endmodule
