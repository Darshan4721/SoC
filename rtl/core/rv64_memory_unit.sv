`timescale 1ns/1ps
module rv64_memory_unit #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter PHYS_REG_WIDTH = 7
) (
    input  logic clk,
    input  logic rst_n,
    input  logic flush,
    
    // Dispatch Interface (from Decode/Rename)
    input  logic                      dispatch_val,
    input  logic                      is_store,
    input  logic [PHYS_REG_WIDTH-1:0] dispatch_rd,
    input  logic [PHYS_REG_WIDTH-1:0] dispatch_rs1,
    input  logic [PHYS_REG_WIDTH-1:0] dispatch_rs2,
    input  logic [11:0]               dispatch_imm,
    output logic                      lsu_ready,
    
    // Operand Fetch Interface (from Physical Regfile / Bypass)
    output logic [PHYS_REG_WIDTH-1:0] op_rs1_addr,
    input  logic [DATA_WIDTH-1:0]     op_rs1_data,
    output logic [PHYS_REG_WIDTH-1:0] op_rs2_addr,
    input  logic [DATA_WIDTH-1:0]     op_rs2_data,
    
    // CDB Wakeup Interface (from Execution Units)
    input  logic [3:0]                      cdb_val,
    input  logic [3:0][PHYS_REG_WIDTH-1:0]  cdb_rd,
    
    // Commit Interface (from ROB)
    input  logic                      commit_store,
    
    // Writeback Interface (to CDB)
    output logic                      wb_val,
    output logic [PHYS_REG_WIDTH-1:0] wb_rd,
    output logic [DATA_WIDTH-1:0]     wb_data,
    
    // Exception Interface
    output logic                      tlb_miss_exception,
    
    // AXI Master Interface (to NoC/L2)
    output logic                  m_axi_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_araddr,
    output logic [7:0]            m_axi_arlen,
    input  logic                  m_axi_arready,
    input  logic                  m_axi_rvalid,
    input  logic [255:0]          m_axi_rdata,
    input  logic                  m_axi_rlast,
    output logic                  m_axi_rready,
    
    output logic                  m_axi_awvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_awaddr,
    output logic [7:0]            m_axi_awlen,
    input  logic                  m_axi_awready,
    output logic                  m_axi_wvalid,
    output logic [255:0]          m_axi_wdata,
    output logic                  m_axi_wlast,
    input  logic                  m_axi_wready,
    input  logic                  m_axi_bvalid,
    output logic                  m_axi_bready
);

    // =========================================================================
    // INTERNAL WIRING
    // =========================================================================

    // LSQ to AGU
    logic                      agu_req_val;
    logic                      agu_is_store;
    logic [PHYS_REG_WIDTH-1:0] agu_rs1;
    logic [PHYS_REG_WIDTH-1:0] agu_rs2;
    logic [11:0]               agu_imm;
    logic [PHYS_REG_WIDTH-1:0] agu_rd;
    logic                      agu_req_rdy;
    
    // AGU to TLB
    logic                  tlb_req_val;
    logic                  tlb_is_store;
    logic [ADDR_WIDTH-1:0] tlb_virt_addr;
    logic [DATA_WIDTH-1:0] tlb_store_data;
    logic [6:0]            tlb_rd;
    logic                  tlb_req_rdy;
    
    // TLB to Cache/Store Buffer
    logic                  phys_req_val;
    logic                  phys_is_store;
    logic [ADDR_WIDTH-1:0] phys_addr;
    logic [DATA_WIDTH-1:0] phys_store_data;
    logic [6:0]            phys_rd;
    logic                  phys_req_rdy;
    
    // Store Buffer to D-Cache
    logic                  dcache_req_val;
    logic [ADDR_WIDTH-1:0] dcache_req_addr;
    logic [DATA_WIDTH-1:0] dcache_req_data;
    logic                  dcache_req_rdy;
    
    // D-Cache Read Ports
    logic                  load_req_rdy;
    logic                  load_rsp_val;
    logic [DATA_WIDTH-1:0] load_rsp_data;

    // =========================================================================
    // LSU CONTROLLER / ROUTING LOGIC
    // =========================================================================
    
    // Operand fetching occurs dynamically when the LSQ decides to issue an instruction
    assign op_rs1_addr = agu_rs1;
    assign op_rs2_addr = agu_rs2;
    
    // Route TLB outputs
    logic tlb_to_cache_val;
    logic tlb_to_sb_val;
    
    assign tlb_to_cache_val = phys_req_val && !phys_is_store;
    assign tlb_to_sb_val    = phys_req_val && phys_is_store;
    
    // The TLB is ready if the downstream receiver (Cache or SB) is ready
    assign phys_req_rdy = phys_is_store ? 1'b1 : load_req_rdy; // StoreBuffer rdy tied internally
    
    // Writeback to CDB (only for Loads)
    // In a real pipeline, the RD tag would be pipelined alongside the cache access.
    // For structural wiring, we pass the phys_rd through a small FIFO/Register.
    logic [6:0] load_rd_reg;
    always_ff @(posedge clk) begin
        if (tlb_to_cache_val) load_rd_reg <= phys_rd;
    end
    
    assign wb_val = load_rsp_val;
    assign wb_data = load_rsp_data;
    assign wb_rd = load_rd_reg;

    // =========================================================================
    // MODULE INSTANTIATIONS
    // =========================================================================

    // 1. Load/Store Queue (Instruction Window)
    load_store_queue #(
        .DEPTH(32),
        .PHYS_REG_WIDTH(PHYS_REG_WIDTH)
    ) i_lsq (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush),
        .dispatch_val(dispatch_val),
        .is_store(is_store),
        .dispatch_rd(dispatch_rd),
        .dispatch_rs1(dispatch_rs1),
        .dispatch_rs2(dispatch_rs2),
        .dispatch_imm(dispatch_imm),
        .lsq_ready(lsu_ready),
        .cdb_val(cdb_val),
        .cdb_rd(cdb_rd),
        .agu_req_val(agu_req_val),
        .agu_is_store(agu_is_store),
        .agu_rs1(agu_rs1),
        .agu_rs2(agu_rs2),
        .agu_imm(agu_imm),
        .agu_rd(agu_rd),
        .agu_req_rdy(agu_req_rdy)
    );

    // 2. Address Generation Unit (Calculates Virtual Address)
    address_generation_unit #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_agu (
        .clk(clk),
        .rst_n(rst_n),
        .agu_req_val(agu_req_val),
        .agu_is_store(agu_is_store),
        .agu_rs1_data(op_rs1_data), // From Register File Bypass
        .agu_rs2_data(op_rs2_data), // Store Data
        .agu_imm(agu_imm),
        .agu_rd(agu_rd),
        .agu_req_rdy(agu_req_rdy),
        .tlb_req_val(tlb_req_val),
        .tlb_is_store(tlb_is_store),
        .tlb_virt_addr(tlb_virt_addr),
        .tlb_store_data(tlb_store_data),
        .tlb_rd(tlb_rd),
        .tlb_req_rdy(tlb_req_rdy)
    );

    // 3. MMU / TLB Unit (Virtual to Physical Translation)
    mmu_tlb_unit #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .TLB_ENTRIES(64)
    ) i_mmu (
        .clk(clk),
        .rst_n(rst_n),
        .tlb_req_val(tlb_req_val),
        .tlb_is_store(tlb_is_store),
        .tlb_virt_addr(tlb_virt_addr),
        .tlb_store_data(tlb_store_data),
        .tlb_rd(tlb_rd),
        .tlb_req_rdy(tlb_req_rdy),
        .phys_req_val(phys_req_val),
        .phys_is_store(phys_is_store),
        .phys_addr(phys_addr),
        .phys_store_data(phys_store_data),
        .phys_rd(phys_rd),
        .phys_req_rdy(phys_req_rdy),
        .tlb_miss_exception(tlb_miss_exception)
    );

    // 4. Store Buffer (Holds stores until retirement)
    store_buffer #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(16)
    ) i_store_buf (
        .clk(clk),
        .rst_n(rst_n),
        .store_val(tlb_to_sb_val),
        .store_addr(phys_addr),
        .store_data(phys_store_data),
        .store_rdy(), // Ignored, assume never full for simple mock
        .commit_store(commit_store),
        .dcache_req_val(dcache_req_val),
        .dcache_req_addr(dcache_req_addr),
        .dcache_req_data(dcache_req_data),
        .dcache_req_rdy(dcache_req_rdy)
    );

    // 5. L1 Data Cache Controller
    l1_dcache_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .CACHE_LINE_WIDTH(256)
    ) i_dcache (
        .clk(clk),
        .rst_n(rst_n),
        .load_req_val(tlb_to_cache_val),
        .load_req_addr(phys_addr),
        .load_req_rdy(load_req_rdy),
        .load_rsp_val(load_rsp_val),
        .load_rsp_data(load_rsp_data),
        .store_req_val(dcache_req_val),
        .store_req_addr(dcache_req_addr),
        .store_req_data(dcache_req_data),
        .store_req_rdy(dcache_req_rdy),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arready(m_axi_arready),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rready(m_axi_rready),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_awready(m_axi_awready),
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wlast(m_axi_wlast),
        .m_axi_wready(m_axi_wready),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bready(m_axi_bready)
    );

endmodule
