`timescale 1ns/1ps

module gpio_sync_array (
    input  logic clk,
    input  logic rst_n,
    output logic [NUM_PINS-1:0] gpio_in_async,
    output logic [NUM_PINS-1:0] gpio_in_sync
);

endmodule
