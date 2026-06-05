`timescale 1ns/1ps

module iommu_core (
    input  logic clk,
    input  logic rst_n,
    output logic dev_req,
    output logic [15:0] dev_id,
    output logic [63:0] dev_iova,
    output logic dev_is_write,
    output logic dev_ack,
    output logic [55:0] dev_paddr,
    output logic dev_fault,
    output logic ptw_req,
    output logic [55:0] ptw_addr,
    output logic ptw_ack,
    output logic [63:0] ptw_data,
    output logic atc_req,
    output logic atc_hit,
    output logic [55:0] atc_paddr
);

endmodule
