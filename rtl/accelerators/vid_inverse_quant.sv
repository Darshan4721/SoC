`timescale 1ns/1ps
module vid_inverse_quant #(
    parameter DATA_WIDTH = 128 // Operates on 8x8 blocks or 4x4 blocks of residuals
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // In from Entropy Decoder (Quantized Coefficients)
    input  logic                  coeff_tvalid,
    input  logic [DATA_WIDTH-1:0] coeff_tdata,
    output logic                  coeff_tready,
    
    // Config: Quantization Parameter (QP)
    input  logic [7:0]            qp_value,
    
    // Out to Motion Comp (Residual Pixels)
    output logic                  resid_tvalid,
    output logic [DATA_WIDTH-1:0] resid_tdata,
    input  logic                  resid_tready
);

    // Inverse Quantization & Inverse Transform (IDCT)
    // Multiplies the frequency coefficients by the quantization step size
    // and applies the Inverse Discrete Cosine Transform to get spatial pixels.
    
    // 2-Stage Pipeline
    logic                  val_s1;
    logic [DATA_WIDTH-1:0] data_s1;
    
    assign coeff_tready = resid_tready;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            val_s1 <= 1'b0;
            data_s1 <= '0;
            resid_tvalid <= 1'b0;
            resid_tdata <= '0;
        end else if (resid_tready) begin
            // Stage 1: Inverse Quantization (Multiplication by QP step)
            val_s1 <= coeff_tvalid;
            if (coeff_tvalid) begin
                for (int i=0; i<DATA_WIDTH/16; i++) begin
                    data_s1[i*16 +: 16] <= coeff_tdata[i*16 +: 16] * qp_value;
                end
            end
            
            // Stage 2: Inverse Transform (Structural Mock of IDCT matrix multiply)
            resid_tvalid <= val_s1;
            if (val_s1) begin
                // Butterfly mixing mock
                resid_tdata <= {data_s1[DATA_WIDTH/2-1:0], data_s1[DATA_WIDTH-1:DATA_WIDTH/2]} ^ {DATA_WIDTH{1'b1}};
            end
        end
    end

endmodule
