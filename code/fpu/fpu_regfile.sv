`timescale 1ns/1ps

module fpu_regfile (
    input  logic clk,
    input  logic rst_n,
    output logic [4:0] read_addr_1,
    output logic [DATA_WIDTH-1:0] read_data_1,
    output logic [4:0] read_addr_2,
    output logic [DATA_WIDTH-1:0] read_data_2,
    output logic [4:0] read_addr_3,
    output logic [DATA_WIDTH-1:0] read_data_3,
    output logic write_en,
    output logic [4:0] write_addr,
    output logic [DATA_WIDTH-1:0] write_data
);

endmodule
