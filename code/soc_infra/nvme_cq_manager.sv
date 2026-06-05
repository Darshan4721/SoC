`timescale 1ns/1ps

module nvme_cq_manager (
    input  logic clk,
    input  logic rst_n,
    output logic [63:0] cq_base_addr,
    output logic ctrl_enable,
    output logic cq_doorbell,
    output logic cpl_valid,
    output logic [31:0] cpl_cdw0,
    output logic [15:0] cpl_sqid,
    output logic [15:0] cpl_sqhd,
    output logic [15:0] cpl_cid,
    output logic [15:0] cpl_status,
    output logic cpl_ready,
    output logic pcie_wr_req,
    output logic [63:0] pcie_wr_addr,
    output logic [127:0] pcie_wr_data,
    output logic pcie_wr_ack
);

endmodule
