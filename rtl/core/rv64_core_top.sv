`timescale 1ns/1ps
module rv64_core_top #(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 64,
    parameter FETCH_WIDTH = 128,
    parameter ROB_ENTRIES = 128,
    parameter PHYS_REGS = 128
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // External Interrupts
    input  logic                  meip, // Machine External Interrupt
    input  logic                  mtip, // Machine Timer Interrupt
    input  logic                  msip, // Machine Software Interrupt
    
    // AXI Master to L1 Instruction Cache
    output logic                  m_axi_icache_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_icache_araddr,
    output logic [7:0]            m_axi_icache_arlen,
    input  logic                  m_axi_icache_arready,
    input  logic                  m_axi_icache_rvalid,
    input  logic [FETCH_WIDTH-1:0]m_axi_icache_rdata,
    input  logic                  m_axi_icache_rlast,
    output logic                  m_axi_icache_rready,
    
    // AXI Master to L1 Data Cache
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
    output logic [DATA_WIDTH/8-1:0]m_axi_dcache_wstrb,
    output logic                  m_axi_dcache_wlast,
    input  logic                  m_axi_dcache_wready,
    input  logic                  m_axi_dcache_bvalid,
    output logic                  m_axi_dcache_bready
);

    // Pipeline Flush / Exceptions
    logic flush_pipeline;
    logic [ADDR_WIDTH-1:0] flush_target_pc;
    
    // PC Gen <-> Fetch <-> I-Cache
    logic [ADDR_WIDTH-1:0] pc_to_fetch;
    logic pc_valid_to_fetch;
    logic icache_req_val;
    logic [ADDR_WIDTH-1:0] icache_req_addr;
    logic icache_req_rdy;
    logic icache_rsp_val;
    logic [FETCH_WIDTH-1:0] icache_rsp_data;
    
    logic fetch_valid;
    logic [31:0] fetch_data;
    logic [ADDR_WIDTH-1:0] fetch_pc_out;
    logic fetch_full;
    logic decode_ready;
    
    logic disp_ready;
    logic decode_valid_scalar;
    logic [ADDR_WIDTH-1:0] decode_pc_scalar;
    logic [6:0] opcode;
    logic [4:0] arch_rd, arch_rs1, arch_rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [63:0] imm_val;
    
    logic [6:0] phys_rd;
    logic [31:0][6:0] arat_state;
    logic [3:0][6:0] rat_rs1_phys, rat_rs2_phys;
    
    logic [3:0] fl_alloc_req;
    logic [3:0][6:0] fl_alloc_phys_id;
    logic fl_alloc_rdy;
    
    logic [3:0] dispatch_rat_read_req;
    logic [3:0][4:0] dispatch_rat_read_rs1, dispatch_rat_read_rs2;
    logic [3:0] dispatch_rat_write_req;
    logic [3:0][4:0] dispatch_rat_write_rd;
    logic [3:0][6:0] dispatch_rat_write_phys;
    
    logic [3:0] disp_valid;
    logic [3:0][6:0] disp_phys_rd, disp_phys_rs1, disp_phys_rs2;
    
    logic rs_alu0_ready;
    logic alu0_val;
    logic [6:0] alu0_prd, alu0_prs1, alu0_prs2;
    
    logic [3:0] cdb_val;
    logic [3:0][6:0] cdb_rd_phys;
    logic [3:0] cdb_branch_mispredict;
    logic [3:0] cdb_exception;
    
    logic rob_ready;
    logic [3:0] commit_ack;
    logic [3:0] commit_valid;
    logic [3:0][6:0] commit_rd_phys;
    logic [3:0][4:0] commit_rd_arch;
    logic [3:0] commit_branch_mispredict;
    logic [3:0] commit_exception;
    
    logic [3:0] fl_free_req;
    logic [3:0][6:0] fl_free_phys_id;

    // --- Instantiations ---
    pc_gen_unit #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) i_pc_gen (
        .clk(clk),
        .rst_n(rst_n),
        .stall(1'b0),
        .flush(flush_pipeline),
        .branch_taken(1'b0),
        .branch_target(64'b0),
        .icache_req_val(icache_req_val),
        .icache_req_addr(icache_req_addr),
        .icache_req_rdy(icache_req_rdy),
        .current_pc(pc_to_fetch),
        .valid_pc(pc_valid_to_fetch)
    );

    fetch_buffer #(
        .INSTR_WIDTH(32),
        .PC_WIDTH(ADDR_WIDTH),
        .DEPTH(16)
    ) i_fetch_buffer (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush_pipeline),
        .icache_rsp_val(icache_rsp_val),
        .icache_rsp_instr(icache_rsp_data[31:0]),
        .icache_rsp_pc(pc_to_fetch),
        .decode_ready(decode_ready),
        .fetch_valid(fetch_valid),
        .fetch_instr(fetch_data),
        .fetch_pc(fetch_pc_out),
        .fetch_full(fetch_full)
    );

    l1_icache_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(FETCH_WIDTH)
    ) i_icache (
        .clk(clk),
        .rst_n(rst_n),
        .core_req_val(icache_req_val),
        .core_req_addr(icache_req_addr),
        .core_rsp_val(icache_rsp_val),
        .core_rsp_data(icache_rsp_data),
        .core_req_rdy(icache_req_rdy),
        .m_axi_arvalid(m_axi_icache_arvalid),
        .m_axi_araddr(m_axi_icache_araddr),
        .m_axi_arlen(m_axi_icache_arlen),
        .m_axi_arready(m_axi_icache_arready),
        .m_axi_rvalid(m_axi_icache_rvalid),
        .m_axi_rdata(m_axi_icache_rdata),
        .m_axi_rlast(m_axi_icache_rlast),
        .m_axi_rready(m_axi_icache_rready)
    );

    instr_decoder #(
        .INSTR_WIDTH(32),
        .PC_WIDTH(ADDR_WIDTH)
    ) i_decoder (
        .clk(clk),
        .rst_n(rst_n),
        .fetch_valid(fetch_valid),
        .fetch_instr(fetch_data),
        .fetch_pc(fetch_pc_out),
        .decode_ready(decode_ready),
        .dispatch_ready(disp_ready),
        .decode_valid(decode_valid_scalar),
        .decode_pc(decode_pc_scalar),
        .opcode(opcode),
        .rd(arch_rd),
        .rs1(arch_rs1),
        .rs2(arch_rs2),
        .funct3(funct3),
        .funct7(funct7),
        .imm_val(imm_val)
    );

    register_alias_table #(
        .ARCH_REGS(32),
        .ARCH_REG_WIDTH(5),
        .PHYS_REG_WIDTH(7)
    ) i_rat (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush_pipeline),
        .arat_state(arat_state),
        .rat_read_req({3'b0, decode_valid_scalar}),
        .rat_read_rs1({15'b0, arch_rs1}),
        .rat_read_rs2({15'b0, arch_rs2}),
        .rat_rs1_phys(rat_rs1_phys),
        .rat_rs2_phys(rat_rs2_phys),
        .rat_write_req({3'b0, decode_valid_scalar}),
        .rat_write_rd({15'b0, arch_rd}),
        .rat_write_phys({21'b0, fl_alloc_phys_id[0]})
    );

    dispatch_unit_4way #(
        .PC_WIDTH(ADDR_WIDTH),
        .ARCH_REG_WIDTH(5),
        .PHYS_REG_WIDTH(7)
    ) i_dispatch (
        .clk(clk),
        .rst_n(rst_n),
        .decode_valid({3'b0, decode_valid_scalar}),
        .decode_pc({192'b0, decode_pc_scalar}),
        .opcode({21'b0, opcode}),
        .rd_arch({15'b0, arch_rd}),
        .rs1_arch({15'b0, arch_rs1}),
        .rs2_arch({15'b0, arch_rs2}),
        .dispatch_ready(disp_ready),
        .fl_alloc_req(fl_alloc_req),
        .fl_alloc_phys_id(fl_alloc_phys_id),
        .fl_alloc_rdy(fl_alloc_rdy),
        .rat_read_req(dispatch_rat_read_req),
        .rat_read_rs1(dispatch_rat_read_rs1),
        .rat_read_rs2(dispatch_rat_read_rs2),
        .rat_rs1_phys(rat_rs1_phys),
        .rat_rs2_phys(rat_rs2_phys),
        .rat_write_req(dispatch_rat_write_req),
        .rat_write_rd(dispatch_rat_write_rd),
        .rat_write_phys(dispatch_rat_write_phys),
        .rs_ready(1'b1),
        .rob_ready(1'b1),
        .dispatch_valid(disp_valid),
        .dispatch_rd_phys(disp_phys_rd),
        .dispatch_rs1_phys(disp_phys_rs1),
        .dispatch_rs2_phys(disp_phys_rs2)
    );

    reservation_station_alu_0 #(
        .DEPTH(8),
        .PHYS_REG_WIDTH(7)
    ) i_rs_alu0 (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush_pipeline),
        .dispatch_val(disp_valid[0]),
        .dispatch_rd(disp_phys_rd[0]),
        .dispatch_rs1(disp_phys_rs1[0]),
        .dispatch_rs2(disp_phys_rs2[0]),
        .rs1_ready(1'b1),
        .rs2_ready(1'b1),
        .rs_ready(rs_alu0_ready),
        .cdb_val(cdb_val),
        .cdb_rd(cdb_rd_phys),
        .issue_val(alu0_val),
        .issue_rd(alu0_prd),
        .issue_rs1(alu0_prs1),
        .issue_rs2(alu0_prs2)
    );

    reorder_buffer_ctrl #(
        .ROB_ENTRIES(ROB_ENTRIES),
        .PHYS_REG_WIDTH(7),
        .ARCH_REG_WIDTH(5),
        .PC_WIDTH(ADDR_WIDTH)
    ) i_rob (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush_pipeline),
        .dispatch_val(disp_valid),
        .dispatch_rd_phys(disp_phys_rd),
        .dispatch_rd_arch({15'b0, arch_rd}),
        .dispatch_pc({192'b0, decode_pc_scalar}),
        .rob_ready(rob_ready),
        .cdb_val(cdb_val),
        .cdb_rd_phys(cdb_rd_phys),
        .cdb_branch_mispredict(cdb_branch_mispredict),
        .cdb_exception(cdb_exception),
        .commit_ack(commit_ack),
        .commit_val(commit_valid),
        .commit_rd_phys(commit_rd_phys),
        .commit_rd_arch(commit_rd_arch),
        .commit_branch_mispredict(commit_branch_mispredict),
        .commit_exception(commit_exception)
    );

    commit_unit #(
        .PHYS_REG_WIDTH(7),
        .ARCH_REG_WIDTH(5),
        .ARCH_REGS(32)
    ) i_commit (
        .clk(clk),
        .rst_n(rst_n),
        .commit_val(commit_valid),
        .commit_rd_phys(commit_rd_phys),
        .commit_rd_arch(commit_rd_arch),
        .commit_branch_mispredict(commit_branch_mispredict),
        .commit_exception(commit_exception),
        .commit_ack(commit_ack),
        .arat_state(arat_state),
        .fl_free_req(fl_free_req),
        .fl_free_phys_id(fl_free_phys_id),
        .global_flush(flush_pipeline),
        .exception_vector(flush_target_pc)
    );

    l1_dcache_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_dcache (
        .clk(clk),
        .rst_n(rst_n),
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

endmodule
