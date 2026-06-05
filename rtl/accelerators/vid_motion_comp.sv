`timescale 1ns/1ps
module vid_motion_comp #(
    parameter DATA_WIDTH = 128
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // In from Inverse Quantizer (Residual Pixels)
    input  logic                  resid_tvalid,
    input  logic [DATA_WIDTH-1:0] resid_tdata,
    output logic                  resid_tready,
    
    // In from Memory (Reference Frame Pixels via DMA)
    input  logic                  ref_tvalid,
    input  logic [DATA_WIDTH-1:0] ref_tdata,
    output logic                  ref_tready,
    
    // Out to Memory (Final Decoded Frame via DMA)
    output logic                  out_tvalid,
    output logic [DATA_WIDTH-1:0] out_tdata,
    input  logic                  out_tready
);

    // Motion Compensation
    // Reconstructs the final frame by adding the residual pixels (from IDCT)
    // to the predicted pixels (fetched from a previously decoded reference frame).
    
    // Wait for both residual and reference data to be valid
    logic both_valid;
    assign both_valid = resid_tvalid && ref_tvalid;
    
    assign resid_tready = both_valid && out_tready;
    assign ref_tready   = both_valid && out_tready;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_tvalid <= 1'b0;
            out_tdata  <= '0;
        end else if (out_tready) begin
            out_tvalid <= both_valid;
            
            if (both_valid) begin
                // Saturated addition of 8-bit pixels
                for (int i=0; i<DATA_WIDTH/8; i++) begin
                    logic [8:0] sum;
                    sum = {1'b0, resid_tdata[i*8 +: 8]} + {1'b0, ref_tdata[i*8 +: 8]};
                    // Saturate to 255
                    out_tdata[i*8 +: 8] <= (sum > 9'd255) ? 8'd255 : sum[7:0];
                end
            end
        end
    end

endmodule
