`timescale 1ns/1ps
module rv64_decode_rename_unit #(
    parameter PC_WIDTH = 64,
    parameter INSTR_WIDTH = 32,
    parameter ARCH_REG_WIDTH = 5,
    parameter PHYS_REG_WIDTH = 7
) (
    input  logic clk,
    input  logic rst_n,
    input  logic flush, // from Commit Unit
    input  logic [31:0][PHYS_REG_WIDTH-1:0] arat_state, // from Commit Unit
    
    // Fetch Interface
    input  logic [3:0]                   fetch_valid,
    input  logic [3:0][INSTR_WIDTH-1:0]  fetch_instr,
    input  logic [3:0][PC_WIDTH-1:0]     fetch_pc,
    output logic                         decode_ready, // backpressure to fetch
    
    // Dispatch Interface (to Execution/ROB/Memory)
    output logic [3:0]                       dispatch_valid,
    output logic [3:0][PHYS_REG_WIDTH-1:0]   dispatch_rd_phys,
    output logic [3:0][ARCH_REG_WIDTH-1:0]   dispatch_rd_arch,
    output logic [3:0][PHYS_REG_WIDTH-1:0]   dispatch_rs1_phys,
    output logic [3:0][PHYS_REG_WIDTH-1:0]   dispatch_rs2_phys,
    output logic [3:0]                       dispatch_rs1_ready,
    output logic [3:0]                       dispatch_rs2_ready,
    output logic [3:0][63:0]                 dispatch_rs1_data,
    output logic [3:0][63:0]                 dispatch_rs2_data,
    output logic [3:0][PC_WIDTH-1:0]         dispatch_pc,
    output logic [3:0][6:0]                  dispatch_opcode,
    output logic [3:0][63:0]                 dispatch_imm,
    output logic [3:0][2:0]                  dispatch_funct3,
    output logic [3:0][6:0]                  dispatch_funct7,
    
    input  logic                             rs_ready,
    input  logic                             rob_ready,
    
    // Common Data Bus (CDB) for Regfile Wakeup/Writeback
    input  logic [3:0]                       cdb_val,
    input  logic [3:0][PHYS_REG_WIDTH-1:0]   cdb_rd,
    input  logic [3:0][63:0]                 cdb_data,
    
    // Commit Interface (for Freelist)
    input  logic [3:0]                       commit_fl_free_req,
    input  logic [3:0][PHYS_REG_WIDTH-1:0]   commit_fl_free_phys_id
);

    // =========================================================================
    // INTERNAL WIRING
    // =========================================================================

    // Decoded outputs
    logic [3:0]                dec_valid;
    logic [3:0][PC_WIDTH-1:0]  dec_pc;
    logic [3:0][6:0]           dec_opcode;
    logic [3:0][4:0]           dec_rd;
    logic [3:0][4:0]           dec_rs1;
    logic [3:0][4:0]           dec_rs2;
    logic [3:0][2:0]           dec_funct3;
    logic [3:0][6:0]           dec_funct7;
    logic [3:0][63:0]          dec_imm;
    
    // Dispatch outputs from Dispatch Unit
    logic [3:0]                du_disp_valid;
    logic [3:0][PHYS_REG_WIDTH-1:0] du_rd_phys;
    logic [3:0][PHYS_REG_WIDTH-1:0] du_rs1_phys;
    logic [3:0][PHYS_REG_WIDTH-1:0] du_rs2_phys;
    logic                      dispatch_ready;
    
    // RAT & Freelist signals
    logic [3:0]                fl_alloc_req;
    logic [3:0][PHYS_REG_WIDTH-1:0] fl_alloc_phys_id;
    logic                      fl_alloc_rdy;
    
    logic [3:0]                rat_read_req;
    logic [3:0][ARCH_REG_WIDTH-1:0] rat_read_rs1;
    logic [3:0][ARCH_REG_WIDTH-1:0] rat_read_rs2;
    logic [3:0][PHYS_REG_WIDTH-1:0] rat_rs1_phys;
    logic [3:0][PHYS_REG_WIDTH-1:0] rat_rs2_phys;
    
    logic [3:0]                rat_write_req;
    logic [3:0][ARCH_REG_WIDTH-1:0] rat_write_rd;
    logic [3:0][PHYS_REG_WIDTH-1:0] rat_write_phys;
    
    // Scoreboard for Register Readiness
    logic [127:0] phys_reg_ready;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            phys_reg_ready <= '1; // All ready initially
        end else if (flush) begin
            phys_reg_ready <= '1; // Simplified flush behavior
        end else begin
            // Clear ready on allocation
            for (int i=0; i<4; i++) begin
                if (du_disp_valid[i] && dec_rd[i] != 0) begin
                    phys_reg_ready[du_rd_phys[i]] <= 1'b0;
                end
            end
            // Set ready on writeback (CDB)
            for (int c=0; c<4; c++) begin
                if (cdb_val[c] && cdb_rd[c] != 0) begin
                    phys_reg_ready[cdb_rd[c]] <= 1'b1;
                end
            end
        end
    end

    // Skid Buffer (sync_fifo) per lane (Mocking the pipeline stage between Fetch and Decode)
    logic [3:0] skid_full, skid_empty;
    logic [3:0][INSTR_WIDTH-1:0] skid_instr;
    
    assign decode_ready = ~skid_full[0]; // Simplified backpressure
    
    // Regfile Read Interface
    logic [7:0]                      rf_read_req;
    logic [7:0][PHYS_REG_WIDTH-1:0]  rf_read_addr;
    logic [7:0][63:0]                rf_read_data;

    always_comb begin
        for (int i=0; i<4; i++) begin
            rf_read_req[i*2] = du_disp_valid[i];
            rf_read_addr[i*2] = du_rs1_phys[i];
            rf_read_req[i*2+1] = du_disp_valid[i];
            rf_read_addr[i*2+1] = du_rs2_phys[i];
            
            dispatch_valid[i] = du_disp_valid[i];
            dispatch_rd_phys[i] = du_rd_phys[i];
            dispatch_rd_arch[i] = dec_rd[i];
            dispatch_rs1_phys[i] = du_rs1_phys[i];
            dispatch_rs2_phys[i] = du_rs2_phys[i];
            dispatch_pc[i] = dec_pc[i];
            dispatch_opcode[i] = dec_opcode[i];
            dispatch_imm[i] = dec_imm[i];
            dispatch_funct3[i] = dec_funct3[i];
            dispatch_funct7[i] = dec_funct7[i];
            
            dispatch_rs1_ready[i] = phys_reg_ready[du_rs1_phys[i]];
            dispatch_rs2_ready[i] = phys_reg_ready[du_rs2_phys[i]];
            dispatch_rs1_data[i] = rf_read_data[i*2];
            dispatch_rs2_data[i] = rf_read_data[i*2+1];
        end
    end

    // =========================================================================
    // MODULE INSTANTIATIONS
    // =========================================================================

    genvar g;
    generate
        for (g = 0; g < 4; g++) begin : gen_lane
            // 1. Skid Buffer (sync_fifo)
            sync_fifo #(
                .DATA_WIDTH(INSTR_WIDTH),
                .DEPTH(4)
            ) i_skid_buf (
                .clk(clk),
                .rst_n(rst_n),
                .push(fetch_valid[g]),
                .pop(dec_valid[g] && dispatch_ready),
                .data_in(fetch_instr[g]),
                .data_out(skid_instr[g]),
                .full(skid_full[g]),
                .empty(skid_empty[g])
            );

            // 2. Instruction Decoder
            instr_decoder #(
                .INSTR_WIDTH(INSTR_WIDTH),
                .PC_WIDTH(PC_WIDTH)
            ) i_decoder (
                .clk(clk),
                .rst_n(rst_n),
                .fetch_valid(~skid_empty[g]),
                .fetch_instr(skid_instr[g]),
                .fetch_pc(fetch_pc[g]), // Assumes PC is bypassed/pipelined alongside
                .decode_ready(), // handled by global ready
                .dispatch_ready(dispatch_ready),
                .decode_valid(dec_valid[g]),
                .decode_pc(dec_pc[g]),
                .opcode(dec_opcode[g]),
                .rd(dec_rd[g]),
                .rs1(dec_rs1[g]),
                .rs2(dec_rs2[g]),
                .funct3(dec_funct3[g]),
                .funct7(dec_funct7[g]),
                .imm_val(dec_imm[g])
            );
        end
    endgenerate

    // 3. Register Alias Table (RAT)
    register_alias_table #(
        .ARCH_REGS(32),
        .ARCH_REG_WIDTH(ARCH_REG_WIDTH),
        .PHYS_REG_WIDTH(PHYS_REG_WIDTH)
    ) i_rat (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush),
        .arat_state(arat_state),
        .rat_read_req(rat_read_req),
        .rat_read_rs1(rat_read_rs1),
        .rat_read_rs2(rat_read_rs2),
        .rat_rs1_phys(rat_rs1_phys),
        .rat_rs2_phys(rat_rs2_phys),
        .rat_write_req(rat_write_req),
        .rat_write_rd(rat_write_rd),
        .rat_write_phys(rat_write_phys)
    );

    // 4. Freelist Manager
    freelist_manager #(
        .PHYS_REGS(128),
        .PHYS_REG_WIDTH(PHYS_REG_WIDTH)
    ) i_freelist (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush),
        .fl_alloc_req(fl_alloc_req),
        .fl_alloc_phys_id(fl_alloc_phys_id),
        .fl_alloc_rdy(fl_alloc_rdy),
        .fl_free_req(commit_fl_free_req),
        .fl_free_phys_id(commit_fl_free_phys_id)
    );

    // 5. Integer Register File
    integer_regfile #(
        .DATA_WIDTH(64),
        .PHYS_REGS(128),
        .PHYS_REG_WIDTH(PHYS_REG_WIDTH)
    ) i_int_regfile (
        .clk(clk),
        .rst_n(rst_n),
        .read_req(rf_read_req),
        .read_addr(rf_read_addr),
        .read_data(rf_read_data),
        .write_req(cdb_val),
        .write_addr(cdb_rd),
        .write_data(cdb_data)
    );

    // 6. Dispatch Unit 4-Way
    dispatch_unit_4way #(
        .PC_WIDTH(PC_WIDTH),
        .ARCH_REG_WIDTH(ARCH_REG_WIDTH),
        .PHYS_REG_WIDTH(PHYS_REG_WIDTH)
    ) i_dispatch_unit (
        .clk(clk),
        .rst_n(rst_n),
        .decode_valid(dec_valid),
        .decode_pc(dec_pc),
        .opcode(dec_opcode),
        .rd_arch(dec_rd),
        .rs1_arch(dec_rs1),
        .rs2_arch(dec_rs2),
        .dispatch_ready(dispatch_ready),
        .fl_alloc_req(fl_alloc_req),
        .fl_alloc_phys_id(fl_alloc_phys_id),
        .fl_alloc_rdy(fl_alloc_rdy),
        .rat_read_req(rat_read_req),
        .rat_read_rs1(rat_read_rs1),
        .rat_read_rs2(rat_read_rs2),
        .rat_rs1_phys(rat_rs1_phys),
        .rat_rs2_phys(rat_rs2_phys),
        .rat_write_req(rat_write_req),
        .rat_write_rd(rat_write_rd),
        .rat_write_phys(rat_write_phys),
        .rs_ready(rs_ready),
        .rob_ready(rob_ready),
        .dispatch_valid(du_disp_valid),
        .dispatch_rd_phys(du_rd_phys),
        .dispatch_rs1_phys(du_rs1_phys),
        .dispatch_rs2_phys(du_rs2_phys)
    );

endmodule
