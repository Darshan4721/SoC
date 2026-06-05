`timescale 1ns/1ps

module nvme_prp_parser (
    input  logic clk,
    input  logic rst_n,
    output logic cmd_valid,
    output logic [63:0] cmd_prp1,
    output logic [63:0] cmd_prp2,
    output logic [31:0] xfer_len,
    output logic pcie_rd_req,
    output logic [63:0] pcie_rd_addr,
    output logic pcie_rd_ack,
    output logic [511:0] pcie_rd_data,
    output logic pcie_rd_data_valid,
    output logic page_valid,
    output logic [63:0] page_paddr,
    output logic page_ready
);

endmodule
