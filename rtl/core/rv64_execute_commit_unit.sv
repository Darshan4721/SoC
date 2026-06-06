`timescale 1ns/1ps
module rv64_execute_commit_unit #(
    parameter ROB_ENTRIES = 64,
    parameter PHYS_REG_WIDTH = 7,
    parameter ARCH_REG_WIDTH = 5,
    parameter PC_WIDTH = 64
) (
    input  logic clk,
    input  logic rst_n,
    input  logic flush, // Note: Global flush generated internally by commit_unit
    
    // Dispatch Interface (from Decode)
    // Up to 4 instructions dispatched per cycle
    input  logic [3:0]                      dispatch_val,
    input  logic [3:0][PHYS_REG_WIDTH-1:0]  dispatch_rd_phys,
    input  logic [3:0][ARCH_REG_WIDTH-1:0]  dispatch_rd_arch,
    input  logic [3:0][PHYS_REG_WIDTH-1:0]  dispatch_rs1,
    input  logic [3:0][PHYS_REG_WIDTH-1:0]  dispatch_rs2,
    input  logic [3:0]                      dispatch_rs1_ready,
    input  logic [3:0]                      dispatch_rs2_ready,
    input  logic [3:0][63:0]                dispatch_rs1_data,
    input  logic [3:0][63:0]                dispatch_rs2_data,
    input  logic [3:0][PC_WIDTH-1:0]        dispatch_pc,
    input  logic [3:0][3:0]                 dispatch_unit_sel, // 0=ALU0, 1=ALU1, 2=MUL, 3=DIV
    output logic                            execute_ready,     // Backpressure to Decode
    
    // External CDB Inputs (from LSU, FPU, Vector)
    input  logic                      ext_cdb_val,
    input  logic [PHYS_REG_WIDTH-1:0] ext_cdb_rd,
    input  logic [63:0]               ext_cdb_data,
    
    // Common Data Bus (CDB) Output (Broadcast to entire core)
    output logic [3:0]                      cdb_val,
    output logic [3:0][PHYS_REG_WIDTH-1:0]  cdb_rd_phys,
    output logic [3:0][63:0]                cdb_data,
    output logic [3:0]                      cdb_branch_mispredict,
    output logic [3:0]                      cdb_exception,
    
    // Commit/ARAT interface (to Decode/Rename/Front-end)
    output logic [31:0][PHYS_REG_WIDTH-1:0] arat_state,
    output logic [3:0]                      fl_free_req,
    output logic [3:0][PHYS_REG_WIDTH-1:0]  fl_free_phys_id,
    output logic                            global_flush,
    output logic [63:0]                     exception_vector
);

    // =========================================================================
    // INTERNAL WIRING
    // =========================================================================

    // ROB Ready
    logic rob_ready;
    
    // Reservation Station Ready signals
    logic rs_alu0_ready, rs_alu1_ready, rs_mul_ready, rs_div_ready;
    
    // Global execute unit ready requires ROB and all targeted RS to be ready
    assign execute_ready = rob_ready && rs_alu0_ready && rs_alu1_ready && rs_mul_ready && rs_div_ready;
    
    // Demux dispatch instructions into specific Reservation Stations
    logic rs_alu0_disp_val, rs_alu1_disp_val, rs_mul_disp_val, rs_div_disp_val;
    logic [PHYS_REG_WIDTH-1:0] rs_alu0_rd, rs_alu1_rd, rs_mul_rd, rs_div_rd;
    // (Simplified Demux: assuming up to 1 of each type per cycle for this structural mock)
    always_comb begin
        rs_alu0_disp_val = 1'b0; rs_alu1_disp_val = 1'b0; rs_mul_disp_val = 1'b0; rs_div_disp_val = 1'b0;
        rs_alu0_rd = '0; rs_alu1_rd = '0; rs_mul_rd = '0; rs_div_rd = '0;
        
        for (int i=0; i<4; i++) begin
            if (dispatch_val[i]) begin
                case (dispatch_unit_sel[i])
                    4'd0: begin rs_alu0_disp_val = 1'b1; rs_alu0_rd = dispatch_rd_phys[i]; end
                    4'd1: begin rs_alu1_disp_val = 1'b1; rs_alu1_rd = dispatch_rd_phys[i]; end
                    4'd2: begin rs_mul_disp_val = 1'b1; rs_mul_rd = dispatch_rd_phys[i]; end
                    4'd3: begin rs_div_disp_val = 1'b1; rs_div_rd = dispatch_rd_phys[i]; end
                endcase
            end
        end
    end

    // Execution Unit Outputs
    logic alu0_val, alu1_val, mul_val, div_val;
    logic [PHYS_REG_WIDTH-1:0] alu0_rd, alu1_rd, mul_rd, div_rd;
    logic [63:0] alu0_data, alu1_data, mul_data, div_data;
    
    // CDB Arbitration (4 ports available: port0=ALU0, port1=ALU1, port2=MUL/DIV, port3=EXT)
    assign cdb_val[0] = alu0_val;
    assign cdb_rd_phys[0] = alu0_rd;
    assign cdb_data[0] = alu0_data;
    assign cdb_branch_mispredict[0] = 1'b0; // Mock: ALU0 handles branches?
    assign cdb_exception[0] = 1'b0;
    
    assign cdb_val[1] = alu1_val;
    assign cdb_rd_phys[1] = alu1_rd;
    assign cdb_data[1] = alu1_data;
    assign cdb_branch_mispredict[1] = 1'b0;
    assign cdb_exception[1] = 1'b0;
    
    assign cdb_val[2] = mul_val | div_val;
    assign cdb_rd_phys[2] = mul_val ? mul_rd : div_rd;
    assign cdb_data[2] = mul_val ? mul_data : div_data;
    assign cdb_branch_mispredict[2] = 1'b0;
    assign cdb_exception[2] = 1'b0;
    
    assign cdb_val[3] = ext_cdb_val;
    assign cdb_rd_phys[3] = ext_cdb_rd;
    assign cdb_data[3] = ext_cdb_data;
    assign cdb_branch_mispredict[3] = 1'b0;
    assign cdb_exception[3] = 1'b0;

    // Commit wiring
    logic [3:0] commit_val;
    logic [3:0][PHYS_REG_WIDTH-1:0] commit_rd_phys;
    logic [3:0][ARCH_REG_WIDTH-1:0] commit_rd_arch;
    logic [3:0] commit_branch_mispredict;
    logic [3:0] commit_exception;
    logic [3:0] commit_ack;

    // =========================================================================
    // MODULE INSTANTIATIONS
    // =========================================================================

    // 1. Reorder Buffer
    reorder_buffer_ctrl #(
        .ROB_ENTRIES(ROB_ENTRIES),
        .PHYS_REG_WIDTH(PHYS_REG_WIDTH),
        .ARCH_REG_WIDTH(ARCH_REG_WIDTH),
        .PC_WIDTH(PC_WIDTH)
    ) i_rob (
        .clk(clk),
        .rst_n(rst_n),
        .flush(global_flush),
        .dispatch_val(dispatch_val),
        .dispatch_rd_phys(dispatch_rd_phys),
        .dispatch_rd_arch(dispatch_rd_arch),
        .dispatch_pc(dispatch_pc),
        .rob_ready(rob_ready),
        .cdb_val(cdb_val),
        .cdb_rd_phys(cdb_rd_phys),
        .cdb_branch_mispredict(cdb_branch_mispredict),
        .cdb_exception(cdb_exception),
        .commit_ack(commit_ack),
        .commit_val(commit_val),
        .commit_rd_phys(commit_rd_phys),
        .commit_rd_arch(commit_rd_arch),
        .commit_branch_mispredict(commit_branch_mispredict),
        .commit_exception(commit_exception)
    );

    // 2. Commit Unit
    commit_unit #(
        .PHYS_REG_WIDTH(PHYS_REG_WIDTH),
        .ARCH_REG_WIDTH(ARCH_REG_WIDTH),
        .ARCH_REGS(32)
    ) i_commit (
        .clk(clk),
        .rst_n(rst_n),
        .commit_val(commit_val),
        .commit_rd_phys(commit_rd_phys),
        .commit_rd_arch(commit_rd_arch),
        .commit_branch_mispredict(commit_branch_mispredict),
        .commit_exception(commit_exception),
        .commit_ack(commit_ack),
        .arat_state(arat_state),
        .fl_free_req(fl_free_req),
        .fl_free_phys_id(fl_free_phys_id),
        .global_flush(global_flush),
        .exception_vector(exception_vector)
    );

    // 3. Reservation Station ALU 0 (Fast math & Branches)
    reservation_station_alu_0 #(
        .DEPTH(8),
        .PHYS_REG_WIDTH(PHYS_REG_WIDTH)
    ) i_rs_alu0 (
        .clk(clk),
        .rst_n(rst_n),
        .flush(global_flush),
        .dispatch_val(rs_alu0_disp_val),
        .dispatch_rd(rs_alu0_rd),
        .dispatch_rs1(dispatch_rs1[0]), // Simplified indexing
        .dispatch_rs2(dispatch_rs2[0]),
        .rs1_ready(dispatch_rs1_ready[0]),
        .rs2_ready(dispatch_rs2_ready[0]),
        .rs_ready(rs_alu0_ready),
        .dispatch_rs1_data(dispatch_rs1_data[0]),
        .dispatch_rs2_data(dispatch_rs2_data[0]),
        .cdb_val(cdb_val),
        .cdb_rd(cdb_rd_phys),
        .cdb_data(cdb_data),
        .exec_val(alu0_val),
        .exec_rd(alu0_rd),
        .exec_data(alu0_data)
    );

    // 4. Reservation Station ALU 1
    reservation_station_alu_1 #(
        .DEPTH(8),
        .PHYS_REG_WIDTH(PHYS_REG_WIDTH)
    ) i_rs_alu1 (
        .clk(clk),
        .rst_n(rst_n),
        .flush(global_flush),
        .dispatch_val(rs_alu1_disp_val),
        .dispatch_rd(rs_alu1_rd),
        .dispatch_rs1(dispatch_rs1[1]),
        .dispatch_rs2(dispatch_rs2[1]),
        .rs1_ready(dispatch_rs1_ready[1]),
        .rs2_ready(dispatch_rs2_ready[1]),
        .rs_ready(rs_alu1_ready),
        .dispatch_rs1_data(dispatch_rs1_data[1]),
        .dispatch_rs2_data(dispatch_rs2_data[1]),
        .cdb_val(cdb_val),
        .cdb_rd(cdb_rd_phys),
        .cdb_data(cdb_data),
        .exec_val(alu1_val),
        .exec_rd(alu1_rd),
        .exec_data(alu1_data)
    );

    // 5. Reservation Station MUL
    reservation_station_mul #(
        .DEPTH(4),
        .PHYS_REG_WIDTH(PHYS_REG_WIDTH)
    ) i_rs_mul (
        .clk(clk),
        .rst_n(rst_n),
        .flush(global_flush),
        .dispatch_val(rs_mul_disp_val),
        .dispatch_rd(rs_mul_rd),
        .dispatch_rs1(dispatch_rs1[2]),
        .dispatch_rs2(dispatch_rs2[2]),
        .rs1_ready(dispatch_rs1_ready[2]),
        .rs2_ready(dispatch_rs2_ready[2]),
        .rs_ready(rs_mul_ready),
        .dispatch_rs1_data(dispatch_rs1_data[2]),
        .dispatch_rs2_data(dispatch_rs2_data[2]),
        .cdb_val(cdb_val),
        .cdb_rd(cdb_rd_phys),
        .cdb_data(cdb_data),
        .exec_val(mul_val),
        .exec_rd(mul_rd),
        .exec_data(mul_data)
    );

    // 6. Reservation Station DIV
    reservation_station_div #(
        .DEPTH(4),
        .PHYS_REG_WIDTH(PHYS_REG_WIDTH)
    ) i_rs_div (
        .clk(clk),
        .rst_n(rst_n),
        .flush(global_flush),
        .dispatch_val(rs_div_disp_val),
        .dispatch_rd(rs_div_rd),
        .dispatch_rs1(dispatch_rs1[3]),
        .dispatch_rs2(dispatch_rs2[3]),
        .rs1_ready(dispatch_rs1_ready[3]),
        .rs2_ready(dispatch_rs2_ready[3]),
        .rs_ready(rs_div_ready),
        .dispatch_rs1_data(dispatch_rs1_data[3]),
        .dispatch_rs2_data(dispatch_rs2_data[3]),
        .cdb_val(cdb_val),
        .cdb_rd(cdb_rd_phys),
        .cdb_data(cdb_data),
        .exec_val(div_val),
        .exec_rd(div_rd),
        .exec_data(div_data)
    );

endmodule
