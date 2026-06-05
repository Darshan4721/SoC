`timescale 1ns/1ps

module ddr4_memory_controller (
    input  logic clk,
    input  logic rst_n,
    input  logic s_awvalid,
    output logic s_awready,
    input  logic [63:0] s_awaddr,
    input  logic s_wvalid,
    output logic s_wready,
    input  logic [63:0] s_wdata,
    output logic s_bvalid,
    input  logic s_bready,
    output logic s_arvalid,
    output logic s_arready,
    input  logic [63:0] s_araddr,
    output logic s_rvalid,
    input  logic s_rready,
    input  logic [63:0] s_rdata,
    output logic cmd_req,
    output logic [2:0] cmd_type,
    output logic [63:0] cmd_addr,
    output logic cmd_ack,
    output logic [63:0] write_data,
    output logic [63:0] read_data,
    output logic read_data_valid
);

endmodule
