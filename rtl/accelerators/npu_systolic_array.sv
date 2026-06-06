`timescale 1ns/1ps
module npu_systolic_array #(
    parameter ARRAY_DIM = 16, // Defaulted to 16 for simulation/synthesis feasibility. Scalable up to 128 as per arch.md
    parameter DATA_WIDTH = 16 // FP16 or INT16
) (
    input  logic                               clk,
    input  logic                               rst_n,
    
    // Weight Pre-load Interface (Broadcast)
    input  logic                               weight_load_en,
    input  logic [ARRAY_DIM-1:0][DATA_WIDTH-1:0] weight_in,
    
    // Activation Input Stream (Left to Right)
    input  logic                               act_in_valid,
    input  logic [ARRAY_DIM-1:0][DATA_WIDTH-1:0] act_in,
    output logic                               act_in_ready,
    
    // Partial Sum Output Stream (Top to Bottom)
    output logic                               psum_out_valid,
    output logic [ARRAY_DIM-1:0][DATA_WIDTH-1:0] psum_out,
    input  logic                               psum_out_ready
);

    // Internal wires for connecting MACs in the 2D grid
    // Dimensions: [row][col]
    logic [DATA_WIDTH-1:0] act_wire  [0:ARRAY_DIM-1][0:ARRAY_DIM];
    logic [DATA_WIDTH-1:0] psum_wire [0:ARRAY_DIM][0:ARRAY_DIM-1];
    
    // Weight Registers (Stationary in this architecture)
    logic [DATA_WIDTH-1:0] weight_reg [0:ARRAY_DIM-1][0:ARRAY_DIM-1];
    
    // Connect input activations to the first column (col 0)
    always_comb begin
        for (int r = 0; r < ARRAY_DIM; r++) begin
            act_wire[r][0] = act_in[r];
        end
    end
    
    // Top row partial sums are strictly initialized to 0
    always_comb begin
        for (int c = 0; c < ARRAY_DIM; c++) begin
            psum_wire[0][c] = '0;
        end
    end
    
    // Simple backpressure: halt the entire array if output is stalled
    assign act_in_ready = psum_out_ready;
    
    // Generate the 2D Systolic Grid
    generate
        genvar r, c;
        for (r = 0; r < ARRAY_DIM; r++) begin : row_gen
            for (c = 0; c < ARRAY_DIM; c++) begin : col_gen
                
                // Weight Pre-load Logic (Broadcast across rows, shift down columns)
                // Simplified stationary load: In a real 128x128 array, weights are shifted in via a dedicated daisy chain.
                always_ff @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        weight_reg[r][c] <= '0;
                    end else if (weight_load_en) begin
                        // For illustration: shift down (row-wise load)
                        if (r == 0) begin
                            weight_reg[r][c] <= weight_in[c];
                        end else begin
                            weight_reg[r][c] <= weight_reg[r-1][c];
                        end
                    end
                end
                
                // Structural Multiplier Instance (256x unrolled in this grid)
                logic signed [15:0] mult_out;
                int8_multiplier i_mac_mult (
                    .a(act_wire[r][c][7:0]), // Downcast to INT8 for the hardware multiplier
                    .b(weight_reg[r][c][7:0]),
                    .prod(mult_out)
                );
                
                // The MAC Operation Accumulator
                always_ff @(posedge clk or negedge rst_n) begin
                    if (!rst_n) begin
                        act_wire[r][c+1]  <= '0;
                        psum_wire[r+1][c] <= '0;
                    end else if (act_in_valid && act_in_ready) begin
                        // Pass activation horizontally
                        act_wire[r][c+1] <= act_wire[r][c];
                        
                        // Accumulate vertically (Sign extend the 16-bit product to DATA_WIDTH)
                        psum_wire[r+1][c] <= psum_wire[r][c] + $signed(mult_out);
                    end
                end
                
            end
        end
    endgenerate

    // Connect bottom row partial sums to output
    always_comb begin
        for (int c = 0; c < ARRAY_DIM; c++) begin
            psum_out[c] = psum_wire[ARRAY_DIM][c];
        end
    end
    
    // The systolic pipeline latency is ARRAY_DIM + ARRAY_DIM cycles.
    // We use a simple valid shift register to track when valid data hits the bottom.
    logic [(ARRAY_DIM*2)-1:0] valid_shift;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_shift <= '0;
        end else if (act_in_ready) begin
            valid_shift <= {valid_shift[(ARRAY_DIM*2)-2:0], act_in_valid};
        end
    end
    
    assign psum_out_valid = valid_shift[(ARRAY_DIM*2)-1];

endmodule
