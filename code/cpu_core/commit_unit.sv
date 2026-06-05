`timescale 1ns/1ps

module commit_unit (
    input  logic clk,
    input  logic rst_n,
    output logic [0:3] rob_ready,
    output logic [6:0] [0:3] rob_prd,
    output logic [6:0] [0:3] rob_prev_prd,
    output logic [0:3] rob_exception,
    output logic [2:0] commit_count,
    output logic flush_pipeline,
    output logic [2:0] free_req_count,
    output logic [6:0] [0:3] free_phys_regs,
    output logic commit_exception_valid
);

endmodule
