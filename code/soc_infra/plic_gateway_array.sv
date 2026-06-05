`timescale 1ns/1ps

module plic_gateway_array (
    input  logic clk,
    input  logic rst_n,
    output logic [NUM_SOURCES-1:0] irq_in,
    output logic [NUM_SOURCES-1:0] irq_pending,
    output logic [NUM_SOURCES-1:0] claim,
    output logic [NUM_SOURCES-1:0] complete
);

endmodule
