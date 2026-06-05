`timescale 1ns/1ps

module eth_mdio_ctrl (
    input  logic clk,
    input  logic rst_n,
    output logic mdio_start,
    output logic mdio_op,
    output logic [4:0] mdio_phy_addr,
    output logic [4:0] mdio_reg_addr,
    output logic [15:0] mdio_wr_data,
    output logic [15:0] mdio_rd_data,
    output logic mdio_done,
    output logic mdc,
    output wire mdio
);

endmodule
