`timescale 1ns/1ps

module rv32_core (
    input  logic clk,
    input  logic rst_n,
    output logic imem_req_o,
    output logic [31:0] imem_addr_o,
    output logic [31:0] imem_rdata_i,
    output logic imem_ready_i,
    output logic dbus_req_o,
    output logic dbus_we_o,
    output logic [3:0] dbus_be_o,
    output logic [31:0] dbus_addr_o,
    output logic [31:0] dbus_wdata_o,
    output logic [31:0] dbus_rdata_i,
    output logic dbus_ready_i,
    output logic halt_o
);

endmodule
