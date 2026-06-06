`timescale 1ns/1ps
module fpu_subsystem_top #(
    parameter DATA_WIDTH = 64,
    parameter FREG_WIDTH = 5
) (
    input  logic clk,
    input  logic rst_n,
    input  logic flush, // Pipeline flush
    
    // Core Dispatch Interface (Receives instructions from Dispatch Unit)
    input  logic                  dispatch_val,
    input  logic [31:0]           dispatch_instr,
    input  logic [FREG_WIDTH-1:0] dispatch_fd,
    input  logic [FREG_WIDTH-1:0] dispatch_fs1,
    input  logic [FREG_WIDTH-1:0] dispatch_fs2,
    input  logic [FREG_WIDTH-1:0] dispatch_fs3,
    output logic                  queue_ready,
    
    // FPU Register File Read (Asynchronous/Combinational from Core Regfile)
    output logic [FREG_WIDTH-1:0] fpu_rs1_addr,
    input  logic [DATA_WIDTH-1:0] fpu_rs1_data,
    output logic [FREG_WIDTH-1:0] fpu_rs2_addr,
    input  logic [DATA_WIDTH-1:0] fpu_rs2_data,
    output logic [FREG_WIDTH-1:0] fpu_rs3_addr,
    input  logic [DATA_WIDTH-1:0] fpu_rs3_data,
    
    // Writeback Interface (Common Data Bus to Core ROB/Regfile)
    output logic                  wb_val,
    output logic [FREG_WIDTH-1:0] wb_fd,
    output logic [DATA_WIDTH-1:0] wb_data,
    output logic [4:0]            wb_fflags,
    input  logic                  wb_ready
);

    // =========================================================================
    // INTERNAL WIRING
    // =========================================================================
    
    // Dispatch Queue -> Execution Units
    logic                  issue_val;
    logic [31:0]           issue_instr;
    logic [FREG_WIDTH-1:0] issue_fd;
    logic [FREG_WIDTH-1:0] issue_fs1;
    logic [FREG_WIDTH-1:0] issue_fs2;
    logic [FREG_WIDTH-1:0] issue_fs3;
    logic                  issue_ready;
    
    // Register File routing
    assign fpu_rs1_addr = issue_fs1;
    assign fpu_rs2_addr = issue_fs2;
    assign fpu_rs3_addr = issue_fs3;
    
    // Execution Unit Demux (Decode FMA vs DIV)
    logic is_div;
    assign is_div = (issue_instr[6:0] == 7'h53) && (issue_instr[31:27] == 5'h0C); // Simplified RV-F div decode
    
    logic fma_issue_val, fma_issue_ready;
    logic div_issue_val, div_issue_ready;
    
    assign fma_issue_val = issue_val && !is_div;
    assign div_issue_val = issue_val && is_div;
    
    assign issue_ready = is_div ? div_issue_ready : fma_issue_ready;
    
    // Pipeline Registers to carry FD down the FMA and DIV pipelines
    // FMA is 4 cycles
    logic [FREG_WIDTH-1:0] fma_fd_shift [0:3];
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<4; i++) fma_fd_shift[i] <= '0;
        end else if (fma_issue_val && fma_issue_ready) begin
            fma_fd_shift[0] <= issue_fd;
            fma_fd_shift[1] <= fma_fd_shift[0];
            fma_fd_shift[2] <= fma_fd_shift[1];
            fma_fd_shift[3] <= fma_fd_shift[2];
        end else begin
            // Shift on pipeline advance
            fma_fd_shift[1] <= fma_fd_shift[0];
            fma_fd_shift[2] <= fma_fd_shift[1];
            fma_fd_shift[3] <= fma_fd_shift[2];
        end
    end
    
    // Divider is variable latency (SRT Radix-4), need to capture FD
    logic [FREG_WIDTH-1:0] div_fd_reg;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) div_fd_reg <= '0;
        else if (div_issue_val && div_issue_ready) div_fd_reg <= issue_fd;
    end

    // Execution Unit Outputs
    logic                  fma_res_val;
    logic [DATA_WIDTH-1:0] fma_res_data;
    logic [4:0]            fma_fflags;
    logic                  fma_res_ready;
    
    logic                  div_res_val;
    logic [DATA_WIDTH-1:0] div_res_data;
    logic [4:0]            div_fflags;
    logic                  div_res_ready;

    // Output Arbitration (FMA vs DIV)
    // Simple priority: FMA > DIV
    assign wb_val = fma_res_val | div_res_val;
    assign wb_data = fma_res_val ? fma_res_data : div_res_data;
    assign wb_fd = fma_res_val ? fma_fd_shift[3] : div_fd_reg;
    assign wb_fflags = fma_res_val ? fma_fflags : div_fflags;
    
    assign fma_res_ready = wb_ready;
    assign div_res_ready = wb_ready && !fma_res_val;

    // =========================================================================
    // MODULE INSTANTIATIONS
    // =========================================================================

    // 1. FPU Dispatch Queue (Acts as Controller FSM)
    fpu_dispatch_queue #(
        .DEPTH(16),
        .FREG_WIDTH(FREG_WIDTH)
    ) i_fpu_queue (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush),
        .dispatch_val(dispatch_val),
        .dispatch_instr(dispatch_instr),
        .dispatch_fd(dispatch_fd),
        .dispatch_fs1(dispatch_fs1),
        .dispatch_fs2(dispatch_fs2),
        .dispatch_fs3(dispatch_fs3),
        .queue_ready(queue_ready),
        .issue_val(issue_val),
        .issue_instr(issue_instr),
        .issue_fd(issue_fd),
        .issue_fs1(issue_fs1),
        .issue_fs2(issue_fs2),
        .issue_fs3(issue_fs3),
        .issue_ready(issue_ready)
    );

    // 2. FPU FMA Pipeline (Multiplies & Adds)
    fpu_fma_pipeline #(
        .DATA_WIDTH(DATA_WIDTH)
    ) i_fpu_fma (
        .clk(clk),
        .rst_n(rst_n),
        .issue_val(fma_issue_val),
        .opcode(issue_instr),
        .fs1_data(fpu_rs1_data),
        .fs2_data(fpu_rs2_data),
        .fs3_data(fpu_rs3_data),
        .issue_ready(fma_issue_ready),
        .res_val(fma_res_val),
        .res_data(fma_res_data),
        .fflags(fma_fflags),
        .res_ready(fma_res_ready)
    );

    // 3. FPU SRT Divider
    fpu_srt_divider #(
        .DATA_WIDTH(DATA_WIDTH)
    ) i_fdiv (
        .clk(clk),
        .rst_n(rst_n),
        .issue_val(div_issue_val),
        .opcode(issue_instr),
        .fs1_data(fpu_rs1_data),
        .fs2_data(fpu_rs2_data),
        .issue_ready(div_issue_ready),
        .res_val(div_res_val),
        .res_data(div_res_data),
        .fflags(div_fflags),
        .res_ready(div_res_ready)
    );

endmodule
