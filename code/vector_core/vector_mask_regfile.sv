`timescale 1ns/1ps

module vector_mask_regfile (
    input  logic clk,
    input  logic rst_n,
    output logic [$clog2(NUM_REGS)-1:0] read_addr_1,
    output logic [MASK_WIDTH-1:0] read_data_1,
    output logic [$clog2(NUM_REGS)-1:0] read_addr_2,
    output logic [MASK_WIDTH-1:0] read_data_2,
    output logic write_en,
    output logic [$clog2(NUM_REGS)-1:0] write_addr,
    output logic [MASK_WIDTH-1:0] write_data
);

endmodule
