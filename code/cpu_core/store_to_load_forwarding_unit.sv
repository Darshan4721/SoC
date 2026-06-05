`timescale 1ns/1ps

module store_to_load_forwarding_unit (
    output logic [63:0] load_addr,
    output logic [1:0] load_size,
    output logic [63:0] store_addr,
    output logic [1:0] store_size,
    output logic [63:0] store_data,
    output logic [63:0] fwd_data,
    output logic fwd_valid
);

endmodule
