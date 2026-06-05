`timescale 1ns/1ps

module priority_encoder_64 (
    input  logic [63:0] req,
    output logic        valid,
    output logic [5:0]  grant
);
    assign valid = |req;
    
    always_comb begin
        grant = 6'd0;
        for (int i = 63; i >= 0; i--) begin
            if (req[i]) grant = i[5:0];
        end
    end
endmodule
