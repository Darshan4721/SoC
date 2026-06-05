`timescale 1ns/1ps

module bf16_multiplier (
    input  logic [15:0] a,
    input  logic [15:0] b,
    output logic [15:0] prod
);
    // Bfloat16: 1 bit sign, 8 bits exponent, 7 bits mantissa
    logic sign_a, sign_b, sign_out;
    logic [7:0] exp_a, exp_b, exp_out;
    logic [7:0] mant_a, mant_b; // Including hidden bit
    logic [15:0] mant_prod;
    
    assign sign_a = a[15];
    assign exp_a  = a[14:7];
    assign mant_a = {|exp_a, a[6:0]}; // Hidden bit logic
    
    assign sign_b = b[15];
    assign exp_b  = b[14:7];
    assign mant_b = {|exp_b, b[6:0]};
    
    assign sign_out = sign_a ^ sign_b;
    assign mant_prod = mant_a * mant_b;
    
    always_comb begin
        if (exp_a == 0 || exp_b == 0) begin
            exp_out = 8'd0; // Flush to zero
            prod = {sign_out, 15'd0};
        end else begin
            exp_out = exp_a + exp_b - 8'd127;
            if (mant_prod[15]) begin
                exp_out = exp_out + 1'b1;
                prod = {sign_out, exp_out, mant_prod[14:8]};
            end else begin
                prod = {sign_out, exp_out, mant_prod[13:7]};
            end
        end
    end
endmodule
