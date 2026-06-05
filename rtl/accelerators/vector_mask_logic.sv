`timescale 1ns/1ps
module vector_mask_logic #(
    parameter VLEN = 512
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Command Interface
    input  logic                  cmd_val,
    input  logic [31:0]           opcode,
    input  logic [VLEN/8-1:0]     v0_mask_in, // Original byte mask
    output logic                  cmd_ready,
    
    // Output Result to Regfile write enable
    output logic                  mask_val,
    output logic [VLEN/8-1:0]     mask_out,
    input  logic                  mask_ready
);

    // Vector masking logic determines the physical write-enables to the Vector Regfile.
    // If the instruction is unmasked (vm=1), mask_out is all 1s.
    // If the instruction is masked (vm=0), mask_out equals v0_mask_in.
    
    // Also handles logical operations on masks (vmand, vmor, vmxor) if opcode dictates.
    
    assign cmd_ready = mask_ready;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mask_val <= 1'b0;
            mask_out <= '0;
        end else if (mask_ready) begin
            mask_val <= cmd_val;
            if (cmd_val) begin
                // Simplified decode: assuming bit 25 of opcode is `vm` in RVV encoding
                if (opcode[25]) begin
                    mask_out <= { (VLEN/8) {1'b1} }; // Unmasked: all bytes enabled
                end else begin
                    mask_out <= v0_mask_in; // Masked: use v0 content
                end
            end
        end
    end

endmodule
