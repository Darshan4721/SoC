`timescale 1ns/1ps

module video_dma_engine (
    input  logic clk,
    input  logic rst_n,
    output logic enable,
    output logic [63:0] frame_base_addr,
    output logic [15:0] frame_width,
    output logic [15:0] frame_height,
    output logic arvalid,
    output logic arready,
    output logic [63:0] araddr,
    output logic [7:0] arlen,
    output logic rvalid,
    input  logic rready,
    output logic [63:0] rdata,
    output logic rlast,
    output logic pixel_valid,
    output logic [23:0] pixel_data,
    output logic pixel_sof,
    output logic pixel_eol,
    output logic pixel_ready
);

endmodule
