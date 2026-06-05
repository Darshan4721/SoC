`timescale 1ns/1ps

module vector_gather_scatter_unit (
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic is_store,
    output logic [63:0] base_addr,
    output logic [VLEN-1:0] v_offsets,
    output logic [VLEN-1:0] v_data,
    output logic [1:0] sew,
    output logic [(VLEN/8)-1:0] v0_mask,
    output logic mem_req_valid,
    output logic [63:0] mem_req_addr,
    output logic [63:0] mem_req_data,
    output logic [7:0] mem_req_be,
    output logic mem_req_write,
    output logic mem_req_ready,
    output logic mem_rsp_valid,
    output logic [63:0] mem_rsp_data,
    output logic valid_out,
    output logic [VLEN-1:0] vd
);

endmodule
