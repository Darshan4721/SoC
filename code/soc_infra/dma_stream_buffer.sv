`timescale 1ns/1ps

module dma_stream_buffer (
    input  logic clk,
    input  logic rst_n,
    output logic write_en,
    output logic [DATA_WIDTH-1:0] write_data,
    output logic write_ready,
    output logic read_en,
    output logic read_valid,
    output logic [DATA_WIDTH-1:0] read_data
);

endmodule
