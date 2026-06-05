`timescale 1ns/1ps

module return_address_stack (
    input  logic clk,
    input  logic rst_n,
    output logic push,
    output logic [PC_WIDTH-1:0] push_pc,
    output logic pop,
    output logic [PC_WIDTH-1:0] pop_pc,
    output logic empty,
    output logic full,
    output logic [$clog2(DEPTH):0] current_ptr,
    output logic recover,
    output logic [$clog2(DEPTH):0] recover_ptr
);

endmodule
