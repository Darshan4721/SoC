`timescale 1ns/1ps

module rv64_core_top #(
    parameter PC_WIDTH = 64,
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256, // AXI data width matching cache line fills
    parameter INSTR_WIDTH = 32,
    parameter ARCH_REG_WIDTH = 5,
    parameter PHYS_REG_WIDTH = 7
) (
    // Global Signals
    input  logic                  clk,
    input  logic                  rst_n,

    // Standard RISC-V Interrupts
    input  logic                  timer_irq,
    input  logic                  ext_irq,
    input  logic                  soft_irq,

    // =========================================================================
    // I-Cache AXI4 Master Interface (Read Only)
    // =========================================================================
    output logic                  m_axi_icache_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_icache_araddr,
    output logic [7:0]            m_axi_icache_arlen,
    input  logic                  m_axi_icache_arready,
    
    input  logic                  m_axi_icache_rvalid,
    input  logic [DATA_WIDTH-1:0] m_axi_icache_rdata,
    input  logic                  m_axi_icache_rlast,
    output logic                  m_axi_icache_rready,

    // =========================================================================
    // D-Cache AXI4 Master Interface (Read / Write)
    // =========================================================================
    output logic                  m_axi_dcache_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_dcache_araddr,
    output logic [7:0]            m_axi_dcache_arlen,
    input  logic                  m_axi_dcache_arready,
    
    input  logic                  m_axi_dcache_rvalid,
    input  logic [DATA_WIDTH-1:0] m_axi_dcache_rdata,
    input  logic                  m_axi_dcache_rlast,
    output logic                  m_axi_dcache_rready,
    
    output logic                  m_axi_dcache_awvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_dcache_awaddr,
    output logic [7:0]            m_axi_dcache_awlen,
    input  logic                  m_axi_dcache_awready,
    
    output logic                  m_axi_dcache_wvalid,
    output logic [DATA_WIDTH-1:0] m_axi_dcache_wdata,
    output logic                  m_axi_dcache_wlast,
    input  logic                  m_axi_dcache_wready,
    
    input  logic                  m_axi_dcache_bvalid,
    output logic                  m_axi_dcache_bready
);

    // =========================================================================
    // INTERNAL WIRING NETS
    // =========================================================================

    // Flush & Stall vectors from Controller
    logic global_stall;
    logic fetch_flush, decode_flush, execute_flush, memory_flush, fpu_flush, vector_flush;
    logic trap_valid;
    logic [PC_WIDTH-1:0] trap_target_pc;
    
    // Fetch to Decode (4-wide)
    logic decode_ready;
    logic [3:0] fetch_valid;
    logic [3:0][INSTR_WIDTH-1:0] fetch_instr;
    logic [3:0][PC_WIDTH-1:0] fetch_pc;
    
    // Decode to Execute/Memory/FPU/Vector (4-wide Dispatch)
    logic [3:0] dispatch_valid;
    logic [3:0][PHYS_REG_WIDTH-1:0] dispatch_rd_phys, dispatch_rs1_phys, dispatch_rs2_phys;
    logic [3:0][ARCH_REG_WIDTH-1:0] dispatch_rd_arch;
    logic [3:0] dispatch_rs1_ready, dispatch_rs2_ready;
    logic [3:0][63:0] dispatch_rs1_data, dispatch_rs2_data;
    logic [3:0][PC_WIDTH-1:0] dispatch_pc;
    logic [3:0][6:0] dispatch_opcode;
    logic [3:0][63:0] dispatch_imm;
    logic [3:0][2:0] dispatch_funct3;
    logic [3:0][6:0] dispatch_funct7;
    
    // Execute/ROB Commit feedback to Decode
    logic [31:0][PHYS_REG_WIDTH-1:0] arat_state;
    logic [3:0] fl_free_req;
    logic [3:0][PHYS_REG_WIDTH-1:0] fl_free_phys_id;
    logic execute_ready;
    
    // CDB from Execute back to everyone
    logic [3:0] cdb_val;
    logic [3:0][PHYS_REG_WIDTH-1:0] cdb_rd_phys;
    logic [3:0][63:0] cdb_data;
    
    // External CDB aggregation (Memory, FPU, Vector writing back to ROB)
    logic ext_cdb_val;
    logic [PHYS_REG_WIDTH-1:0] ext_cdb_rd;
    logic [63:0] ext_cdb_data;
    
    // =========================================================================
    // MASTER PIPELINE CONTROLLER
    // =========================================================================
    core_pipeline_controller #(
        .PC_WIDTH(PC_WIDTH)
    ) i_controller (
        .clk(clk),
        .rst_n(rst_n),
        .timer_irq(timer_irq),
        .ext_irq(ext_irq),
        .soft_irq(soft_irq),
        
        // Mocking precise commit signals using Execute exceptions
        .commit_valid(cdb_val[0]), 
        .commit_exception(1'b0), // Tie off mock for synthesis
        .commit_exception_pc('0),
        .commit_exception_cause('0),
        .commit_branch_mispredict(1'b0),
        .commit_branch_target('0),
        .commit_mret(1'b0),
        
        .global_stall(global_stall),
        .fetch_flush(fetch_flush),
        .decode_flush(decode_flush),
        .execute_flush(execute_flush),
        .memory_flush(memory_flush),
        .fpu_flush(fpu_flush),
        .vector_flush(vector_flush),
        .trap_valid(trap_valid),
        .trap_target_pc(trap_target_pc)
    );

    // =========================================================================
    // FETCH SUBSYSTEM
    // =========================================================================
    rv64_fetch_unit #(
        .PC_WIDTH(PC_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH)
    ) i_fetch_unit (
        .clk(clk),
        .rst_n(rst_n),
        .flush(fetch_flush | trap_valid),
        .flush_target_pc(trap_target_pc),
        .stall(global_stall),
        .bpu_update_en(1'b0),
        .bpu_update_pc('0),
        .bpu_update_taken(1'b0),
        .bpu_update_target('0),
        .decode_ready(decode_ready),
        .fetch_valid(fetch_valid),
        .fetch_instr(fetch_instr),
        .fetch_pc(fetch_pc),
        
        // I-Cache AXI boundary
        .m_axi_arvalid(m_axi_icache_arvalid),
        .m_axi_araddr(m_axi_icache_araddr),
        .m_axi_arlen(m_axi_icache_arlen),
        .m_axi_arready(m_axi_icache_arready),
        .m_axi_rvalid(m_axi_icache_rvalid),
        .m_axi_rdata(m_axi_icache_rdata),
        .m_axi_rlast(m_axi_icache_rlast),
        .m_axi_rready(m_axi_icache_rready)
    );

    // =========================================================================
    // DECODE & RENAME SUBSYSTEM
    // =========================================================================
    // Wait logic for structural stub
    logic rob_ready_stub = 1'b1;
    
    rv64_decode_rename_unit #(
        .PC_WIDTH(PC_WIDTH),
        .INSTR_WIDTH(INSTR_WIDTH),
        .ARCH_REG_WIDTH(ARCH_REG_WIDTH),
        .PHYS_REG_WIDTH(PHYS_REG_WIDTH)
    ) i_decode_unit (
        .clk(clk),
        .rst_n(rst_n),
        .flush(decode_flush),
        .arat_state(arat_state),
        .fetch_valid(fetch_valid),
        .fetch_instr(fetch_instr),
        .fetch_pc(fetch_pc),
        .decode_ready(decode_ready),
        
        .dispatch_valid(dispatch_valid),
        .dispatch_rd_phys(dispatch_rd_phys),
        .dispatch_rd_arch(dispatch_rd_arch),
        .dispatch_rs1_phys(dispatch_rs1_phys),
        .dispatch_rs2_phys(dispatch_rs2_phys),
        .dispatch_rs1_ready(dispatch_rs1_ready),
        .dispatch_rs2_ready(dispatch_rs2_ready),
        .dispatch_rs1_data(dispatch_rs1_data),
        .dispatch_rs2_data(dispatch_rs2_data),
        .dispatch_pc(dispatch_pc),
        .dispatch_opcode(dispatch_opcode),
        .dispatch_imm(dispatch_imm),
        .dispatch_funct3(dispatch_funct3),
        .dispatch_funct7(dispatch_funct7),
        
        .rs_ready(execute_ready),
        .rob_ready(rob_ready_stub),
        
        .cdb_val(cdb_val),
        .cdb_rd(cdb_rd_phys),
        .cdb_data(cdb_data),
        
        .commit_fl_free_req(fl_free_req),
        .commit_fl_free_phys_id(fl_free_phys_id)
    );

    // =========================================================================
    // EXECUTE & COMMIT SUBSYSTEM (ALU/ROB)
    // =========================================================================
    logic [3:0][3:0] dispatch_unit_sel;
    assign dispatch_unit_sel[0] = 4'd0;
    assign dispatch_unit_sel[1] = 4'd1;
    assign dispatch_unit_sel[2] = 4'd2;
    assign dispatch_unit_sel[3] = 4'd3;

    rv64_execute_commit_unit #(
        .ROB_ENTRIES(64),
        .PHYS_REG_WIDTH(PHYS_REG_WIDTH),
        .ARCH_REG_WIDTH(ARCH_REG_WIDTH),
        .PC_WIDTH(PC_WIDTH)
    ) i_execute_unit (
        .clk(clk),
        .rst_n(rst_n),
        .flush(execute_flush),
        .dispatch_val(dispatch_valid),
        .dispatch_rd_phys(dispatch_rd_phys),
        .dispatch_rd_arch(dispatch_rd_arch),
        .dispatch_rs1(dispatch_rs1_phys),
        .dispatch_rs2(dispatch_rs2_phys),
        .dispatch_rs1_ready(dispatch_rs1_ready),
        .dispatch_rs2_ready(dispatch_rs2_ready),
        .dispatch_rs1_data(dispatch_rs1_data),
        .dispatch_rs2_data(dispatch_rs2_data),
        .dispatch_pc(dispatch_pc),
        .dispatch_unit_sel(dispatch_unit_sel),
        .execute_ready(execute_ready),
        
        .ext_cdb_val(ext_cdb_val),
        .ext_cdb_rd(ext_cdb_rd),
        .ext_cdb_data(ext_cdb_data),
        
        .cdb_val(cdb_val),
        .cdb_rd_phys(cdb_rd_phys),
        .cdb_data(cdb_data),
        .cdb_branch_mispredict(),
        .cdb_exception(),
        
        .arat_state(arat_state),
        .fl_free_req(fl_free_req),
        .fl_free_phys_id(fl_free_phys_id),
        .global_flush(),
        .exception_vector()
    );

    // =========================================================================
    // MEMORY SUBSYSTEM
    // =========================================================================
    logic mem_wb_val;
    logic [PHYS_REG_WIDTH-1:0] mem_wb_rd;
    logic [63:0] mem_wb_data;
    
    rv64_memory_unit #(
        .PHYS_REG_WIDTH(PHYS_REG_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(64)
    ) i_memory_unit (
        .clk(clk),
        .rst_n(rst_n),
        .flush(memory_flush),
        .dispatch_val(dispatch_valid[0]), // Map to lane 0
        .is_store(1'b0),
        .dispatch_rd(dispatch_rd_phys[0]),
        .dispatch_rs1(dispatch_rs1_phys[0]),
        .dispatch_rs2(dispatch_rs2_phys[0]),
        .dispatch_imm(dispatch_imm[0][11:0]),
        .lsu_ready(),
        .op_rs1_addr(),
        .op_rs1_data(dispatch_rs1_data[0]),
        .op_rs2_addr(),
        .op_rs2_data(dispatch_rs2_data[0]),
        .cdb_val(cdb_val),
        .cdb_rd(cdb_rd_phys),
        .commit_store(1'b0),
        .wb_val(mem_wb_val),
        .wb_rd(mem_wb_rd),
        .wb_data(mem_wb_data),
        .tlb_miss_exception(),
        
        // D-Cache AXI boundary
        .m_axi_arvalid(m_axi_dcache_arvalid),
        .m_axi_araddr(m_axi_dcache_araddr),
        .m_axi_arlen(m_axi_dcache_arlen),
        .m_axi_arready(m_axi_dcache_arready),
        .m_axi_rvalid(m_axi_dcache_rvalid),
        .m_axi_rdata(m_axi_dcache_rdata),
        .m_axi_rlast(m_axi_dcache_rlast),
        .m_axi_rready(m_axi_dcache_rready),
        .m_axi_awvalid(m_axi_dcache_awvalid),
        .m_axi_awaddr(m_axi_dcache_awaddr),
        .m_axi_awlen(m_axi_dcache_awlen),
        .m_axi_awready(m_axi_dcache_awready),
        .m_axi_wvalid(m_axi_dcache_wvalid),
        .m_axi_wdata(m_axi_dcache_wdata),
        .m_axi_wlast(m_axi_dcache_wlast),
        .m_axi_wready(m_axi_dcache_wready),
        .m_axi_bvalid(m_axi_dcache_bvalid),
        .m_axi_bready(m_axi_dcache_bready)
    );

    // =========================================================================
    // FPU SUBSYSTEM
    // =========================================================================
    logic fpu_wb_val;
    logic [PHYS_REG_WIDTH-1:0] fpu_wb_fd;
    logic [63:0] fpu_wb_data;
    
    fpu_subsystem_top #(
        .FREG_WIDTH(PHYS_REG_WIDTH),
        .DATA_WIDTH(64)
    ) i_fpu_unit (
        .clk(clk),
        .rst_n(rst_n),
        .flush(fpu_flush),
        .dispatch_val(dispatch_valid[1]),
        .dispatch_instr(32'h0),
        .dispatch_fd(dispatch_rd_phys[1]),
        .dispatch_fs1(dispatch_rs1_phys[1]),
        .dispatch_fs2(dispatch_rs2_phys[1]),
        .dispatch_fs3('0),
        .queue_ready(),
        .fpu_rs1_addr(),
        .fpu_rs1_data(dispatch_rs1_data[1]),
        .fpu_rs2_addr(),
        .fpu_rs2_data(dispatch_rs2_data[1]),
        .fpu_rs3_addr(),
        .fpu_rs3_data('0),
        .wb_val(fpu_wb_val),
        .wb_fd(fpu_wb_fd),
        .wb_data(fpu_wb_data),
        .wb_fflags(),
        .wb_ready(1'b1)
    );

    // =========================================================================
    // VECTOR SUBSYSTEM
    // =========================================================================
    vector_subsystem_top #(
        .VLEN(512),
        .ELEM_WIDTH(32),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) i_vector_unit (
        .clk(clk),
        .rst_n(rst_n),
        .flush(vector_flush),
        .dispatch_val(dispatch_valid[2]),
        .dispatch_instr(32'h0),
        .dispatch_vd(dispatch_rd_phys[2][4:0]),
        .dispatch_vs1(dispatch_rs1_phys[2][4:0]),
        .dispatch_vs2(dispatch_rs2_phys[2][4:0]),
        .dispatch_vm(1'b1),
        .queue_ready(),
        .mem_req_val(),
        .mem_is_store(),
        .mem_addr(),
        .mem_wdata(),
        .mem_req_rdy(1'b1),
        .mem_rsp_val(1'b0),
        .mem_rdata('0)
    );

    // External CDB aggregation (Simple OR for this structural stub)
    assign ext_cdb_val = mem_wb_val | fpu_wb_val;
    assign ext_cdb_rd = mem_wb_val ? mem_wb_rd : fpu_wb_fd;
    assign ext_cdb_data = mem_wb_val ? mem_wb_data : fpu_wb_data;

endmodule
