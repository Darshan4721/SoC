`timescale 1ns/1ps
module vector_lane_1 #(
    parameter LANE_WIDTH = 128 
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    input  logic                  exec_val,
    input  logic [31:0]           opcode,
    input  logic [LANE_WIDTH-1:0] vs1_data,
    input  logic [LANE_WIDTH-1:0] vs2_data,
    input  logic [LANE_WIDTH/8-1:0] mask_data,
    output logic                  exec_ready,
    
    output logic                  res_val,
    output logic [LANE_WIDTH-1:0] res_data,
    input  logic                  res_ready
);
    // Identical Structural SIMD lane to process bits 128-255 of the Vector.
    logic [LANE_WIDTH-1:0] alu_result;
    assign exec_ready = res_ready;
    
    always_comb begin
        alu_result[31:0]   = vs1_data[31:0]   + vs2_data[31:0];
        alu_result[63:32]  = vs1_data[63:32]  + vs2_data[63:32];
        alu_result[95:64]  = vs1_data[95:64]  + vs2_data[95:64];
        alu_result[127:96] = vs1_data[127:96] + vs2_data[127:96];
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            res_val  <= 1'b0;
            res_data <= '0;
        end else if (res_ready) begin
            res_val <= exec_val;
            if (exec_val) begin
                for (int b = 0; b < LANE_WIDTH/8; b++) begin
                    res_data[b*8 +: 8] <= mask_data[b] ? alu_result[b*8 +: 8] : 8'h00;
                end
            end
        end
    end
endmodule
