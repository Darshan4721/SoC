`timescale 1ns/1ps

module iommu_translation_cache (
    input  logic clk,
    input  logic rst_n,
    output logic req_valid,
    output logic [15:0] dev_id,
    output logic [63:0] iova,
    output logic hit,
    output logic [55:0] paddr,
    output logic refill_valid,
    output logic [15:0] refill_dev_id,
    output logic [63:0] refill_iova,
    output logic [55:0] refill_paddr,
    output logic inval_valid,
    output logic [15:0] inval_dev_id,
    output logic [63:0] inval_iova
);

endmodule
