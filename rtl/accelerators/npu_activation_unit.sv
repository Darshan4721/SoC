`timescale 1ns/1ps
module npu_activation_unit #(
    parameter ARRAY_DIM = 16,
    parameter DATA_WIDTH = 16
) (
    input  logic                               clk,
    input  logic                               rst_n,
    
    // Interface from Systolic Array (Partial Sums)
    input  logic                               psum_valid,
    input  logic [ARRAY_DIM-1:0][DATA_WIDTH-1:0] psum_in,
    output logic                               psum_ready,
    
    // Config Interface
    input  logic                               relu_en, // 1 = ReLU, 0 = Pass-through
    
    // Output Interface (To DMA / Writeback)
    output logic                               act_out_valid,
    output logic [ARRAY_DIM-1:0][DATA_WIDTH-1:0] act_out,
    input  logic                               act_out_ready
);

    // Simple Pipeline Stage for Activation Function
    assign psum_ready = act_out_ready;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            act_out_valid <= 1'b0;
            for (int i=0; i<ARRAY_DIM; i++) act_out[i] <= '0;
        end else if (act_out_ready) begin
            act_out_valid <= psum_valid;
            
            if (psum_valid) begin
                for (int i = 0; i < ARRAY_DIM; i++) begin
                    if (relu_en) begin
                        // ReLU: max(0, x)
                        // Assuming MSB is sign bit for signed representations
                        act_out[i] <= psum_in[i][DATA_WIDTH-1] ? '0 : psum_in[i];
                    end else begin
                        // Pass-through
                        act_out[i] <= psum_in[i];
                    end
                end
            end
        end
    end

endmodule
