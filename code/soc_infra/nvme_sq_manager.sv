`timescale 1ns/1ps

module nvme_sq_manager (
    input  logic clk,
    input  logic rst_n,
    output logic [63:0] sq_base_addr,
    output logic ctrl_enable,
    output logic sq_doorbell,
    output logic pcie_rd_req,
    output logic [63:0] pcie_rd_addr,
    output logic pcie_rd_ack,
    output logic [511:0] pcie_rd_data,
    output logic pcie_rd_data_valid,
    output logic cmd_valid,
    output logic [7:0] cmd_opcode,
    output logic [31:0] cmd_nsid,
    output logic [63:0] cmd_prp1,
    output logic [63:0] cmd_prp2,
    output logic [31:0] cmd_cdw10,
    output logic [31:0] cmd_cdw11,
    output logic [31:0] cmd_cdw12,
    output logic cmd_ready
);

endmodule
