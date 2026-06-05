`timescale 1ns/1ps
module dispatch_unit_4way #(
    parameter PC_WIDTH = 64,
    parameter ARCH_REG_WIDTH = 5,
    parameter PHYS_REG_WIDTH = 7
) (
    input  logic                      clk,
    input  logic                      rst_n,
    
    // Interface from Decoder
    input  logic [3:0]                decode_valid,
    input  logic [3:0][PC_WIDTH-1:0]  decode_pc,
    input  logic [3:0][6:0]           opcode,
    input  logic [3:0][ARCH_REG_WIDTH-1:0] rd_arch,
    input  logic [3:0][ARCH_REG_WIDTH-1:0] rs1_arch,
    input  logic [3:0][ARCH_REG_WIDTH-1:0] rs2_arch,
    output logic                      dispatch_ready,
    
    // Interface to Freelist Manager
    output logic [3:0]                fl_alloc_req,
    input  logic [3:0][PHYS_REG_WIDTH-1:0] fl_alloc_phys_id,
    input  logic                      fl_alloc_rdy,
    
    // Interface to RAT
    output logic [3:0]                rat_read_req,
    output logic [3:0][ARCH_REG_WIDTH-1:0] rat_read_rs1,
    output logic [3:0][ARCH_REG_WIDTH-1:0] rat_read_rs2,
    input  logic [3:0][PHYS_REG_WIDTH-1:0] rat_rs1_phys,
    input  logic [3:0][PHYS_REG_WIDTH-1:0] rat_rs2_phys,
    
    output logic [3:0]                rat_write_req,
    output logic [3:0][ARCH_REG_WIDTH-1:0] rat_write_rd,
    output logic [3:0][PHYS_REG_WIDTH-1:0] rat_write_phys,
    
    // Interface to Reservation Stations & ROB
    input  logic                      rs_ready,
    input  logic                      rob_ready,
    output logic [3:0]                dispatch_valid,
    output logic [3:0][PHYS_REG_WIDTH-1:0] dispatch_rd_phys,
    output logic [3:0][PHYS_REG_WIDTH-1:0] dispatch_rs1_phys,
    output logic [3:0][PHYS_REG_WIDTH-1:0] dispatch_rs2_phys
);

    // Dispatch is ready only if we have free physical registers, RS space, and ROB space.
    assign dispatch_ready = fl_alloc_rdy && rs_ready && rob_ready;
    
    always_comb begin
        for (int i = 0; i < 4; i++) begin
            // Default inactive
            fl_alloc_req[i] = 1'b0;
            rat_read_req[i] = 1'b0;
            rat_write_req[i] = 1'b0;
            dispatch_valid[i] = 1'b0;
            
            rat_read_rs1[i] = rs1_arch[i];
            rat_read_rs2[i] = rs2_arch[i];
            rat_write_rd[i] = rd_arch[i];
            rat_write_phys[i] = fl_alloc_phys_id[i];
            
            dispatch_rd_phys[i]  = fl_alloc_phys_id[i];
            dispatch_rs1_phys[i] = rat_rs1_phys[i];
            dispatch_rs2_phys[i] = rat_rs2_phys[i];
            
            if (decode_valid[i] && dispatch_ready) begin
                rat_read_req[i] = 1'b1;
                dispatch_valid[i] = 1'b1;
                
                // If instruction writes to a register (rd != 0), allocate a physical register
                if (rd_arch[i] != 5'd0) begin
                    fl_alloc_req[i] = 1'b1;
                    rat_write_req[i] = 1'b1;
                end
            end
        end
    end
endmodule
