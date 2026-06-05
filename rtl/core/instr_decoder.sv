`timescale 1ns/1ps
module instr_decoder #(
    parameter INSTR_WIDTH = 32,
    parameter PC_WIDTH = 64
) (
    input  logic                   clk,
    input  logic                   rst_n,
    
    // Fetch Buffer Interface
    input  logic                   fetch_valid,
    input  logic [INSTR_WIDTH-1:0] fetch_instr,
    input  logic [PC_WIDTH-1:0]    fetch_pc,
    output logic                   decode_ready,
    
    // Dispatch/Rename Interface
    input  logic                   dispatch_ready,
    output logic                   decode_valid,
    output logic [PC_WIDTH-1:0]    decode_pc,
    output logic [6:0]             opcode,
    output logic [4:0]             rd,
    output logic [4:0]             rs1,
    output logic [4:0]             rs2,
    output logic [2:0]             funct3,
    output logic [6:0]             funct7,
    output logic [63:0]            imm_val
);

    assign decode_ready = dispatch_ready;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            decode_valid <= 1'b0;
        end else begin
            if (dispatch_ready) begin
                decode_valid <= fetch_valid;
                decode_pc    <= fetch_pc;
                
                // RV64G Instruction Extraction
                opcode <= fetch_instr[6:0];
                rd     <= fetch_instr[11:7];
                funct3 <= fetch_instr[14:12];
                rs1    <= fetch_instr[19:15];
                rs2    <= fetch_instr[24:20];
                funct7 <= fetch_instr[31:25];
                
                // Immediate Decoding (I-Type baseline, full decode requires muxing based on opcode)
                case (fetch_instr[6:0])
                    7'b0010011: imm_val <= {{52{fetch_instr[31]}}, fetch_instr[31:20]}; // I-Type
                    7'b0100011: imm_val <= {{52{fetch_instr[31]}}, fetch_instr[31:25], fetch_instr[11:7]}; // S-Type
                    7'b1100011: imm_val <= {{51{fetch_instr[31]}}, fetch_instr[31], fetch_instr[7], fetch_instr[30:25], fetch_instr[11:8], 1'b0}; // B-Type
                    default:    imm_val <= '0;
                endcase
            end
        end
    end

endmodule
