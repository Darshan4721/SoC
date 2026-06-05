`timescale 1ns/1ps

module rv32_lsu (
    output logic [31:0] addr_i,
    output logic [31:0] store_data_i,
    output logic [1:0] mem_size_i,
    output logic mem_unsigned_i,
    output logic [31:0] bus_rdata_i,
    output logic [3:0] be_o,
    output logic [31:0] bus_wdata_o,
    output logic [31:0] load_data_o,
    output logic misalign_o
);

endmodule
