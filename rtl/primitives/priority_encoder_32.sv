`timescale 1ns/1ps

module priority_encoder_32 (
    input  logic [31:0] req,
    output logic        valid,
    output logic [4:0]  grant
);
    assign valid = |req;
    
    always_comb begin
        grant = 5'd0;
        for (int i = 31; i >= 0; i--) begin
            if (req[i]) grant = i[4:0];
        end
    end
endmodule
