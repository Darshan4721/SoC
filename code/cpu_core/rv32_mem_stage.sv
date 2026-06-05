`timescale 1ns/1ps

module rv32_mem_stage (
    output logic mem_req_i,
    output logic mem_we_i,
    output logic [1:0] mem_size_i,
    output logic mem_unsigned_i,
    output logic [31:0] addr_i,
    output logic [31:0] store_data_i,
    output logic [31:0] dbus_rdata_i,
    output logic dbus_ready_i,
    output logic dbus_req_o,
    output logic dbus_we_o,
    output logic [3:0] dbus_be_o,
    output logic [31:0] dbus_addr_o,
    output logic [31:0] dbus_wdata_o,
    output logic [31:0] load_data_o,
    output logic misalign_o
);

endmodule
