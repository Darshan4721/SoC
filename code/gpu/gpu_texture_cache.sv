`timescale 1ns/1ps

module gpu_texture_cache (
    input  logic clk,
    input  logic rst_n,
    output logic tex_req_valid,
    output logic [31:0] tex_u,
    output logic [31:0] tex_v,
    output logic tex_req_ready,
    output logic tex_resp_valid,
    output logic [31:0] tex_color,
    output logic m_arvalid,
    output logic m_arready,
    output logic [63:0] m_araddr,
    output logic [7:0] m_arlen,
    output logic m_rvalid,
    input  logic m_rready,
    output logic [63:0] m_rdata,
    output logic m_rlast
);

endmodule
