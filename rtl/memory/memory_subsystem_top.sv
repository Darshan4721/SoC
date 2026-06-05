`timescale 1ns/1ps
module memory_subsystem_top #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256,
    parameter NUM_MASTERS = 4
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // AXI-Full Slave Interfaces (From NoC Router / Multiple Masters)
    input  logic [NUM_MASTERS-1:0]                  s_axi_arvalid,
    input  logic [NUM_MASTERS-1:0][ADDR_WIDTH-1:0]  s_axi_araddr,
    input  logic [NUM_MASTERS-1:0][7:0]             s_axi_arlen,
    output logic [NUM_MASTERS-1:0]                  s_axi_arready,
    
    output logic [NUM_MASTERS-1:0]                  s_axi_rvalid,
    output logic [NUM_MASTERS-1:0][DATA_WIDTH-1:0]  s_axi_rdata,
    output logic [NUM_MASTERS-1:0]                  s_axi_rlast,
    input  logic [NUM_MASTERS-1:0]                  s_axi_rready,
    
    input  logic [NUM_MASTERS-1:0]                  s_axi_awvalid,
    input  logic [NUM_MASTERS-1:0][ADDR_WIDTH-1:0]  s_axi_awaddr,
    input  logic [NUM_MASTERS-1:0][7:0]             s_axi_awlen,
    output logic [NUM_MASTERS-1:0]                  s_axi_awready,
    
    input  logic [NUM_MASTERS-1:0]                  s_axi_wvalid,
    input  logic [NUM_MASTERS-1:0][DATA_WIDTH-1:0]  s_axi_wdata,
    input  logic [NUM_MASTERS-1:0]                  s_axi_wlast,
    output logic [NUM_MASTERS-1:0]                  s_axi_wready,
    
    output logic [NUM_MASTERS-1:0]                  s_axi_bvalid,
    input  logic [NUM_MASTERS-1:0]                  s_axi_bready,
    
    // External DDR4 Physical Interface (To PCB Pads)
    output logic                  ddr4_ck_p,
    output logic                  ddr4_ck_n,
    output logic                  ddr4_cke,
    output logic                  ddr4_cs_n,
    output logic                  ddr4_ras_n,
    output logic                  ddr4_cas_n,
    output logic                  ddr4_we_n,
    output logic [1:0]            ddr4_bg,
    output logic [1:0]            ddr4_ba,
    output logic [15:0]           ddr4_a,
    inout  wire  [63:0]           ddr4_dq,
    inout  wire  [7:0]            ddr4_dqs_p,
    inout  wire  [7:0]            ddr4_dqs_n,
    output logic [7:0]            ddr4_dm
);

    // =========================================================================
    // INTERNAL WIRING (The Glue Logic)
    // =========================================================================
    
    // 1. Arbiter -> MPU
    logic                  arb_arvalid, arb_arready, arb_rvalid, arb_rlast, arb_rready;
    logic                  arb_awvalid, arb_awready, arb_wvalid, arb_wlast, arb_wready;
    logic                  arb_bvalid, arb_bready;
    logic [ADDR_WIDTH-1:0] arb_araddr, arb_awaddr;
    logic [7:0]            arb_arlen, arb_awlen;
    logic [DATA_WIDTH-1:0] arb_rdata, arb_wdata;
    
    // 2. MPU -> L2 Cache
    logic                  mpu_arvalid, mpu_arready, mpu_rvalid, mpu_rlast, mpu_rready;
    logic                  mpu_awvalid, mpu_awready, mpu_wvalid, mpu_wlast, mpu_wready;
    logic                  mpu_bvalid, mpu_bready;
    logic [ADDR_WIDTH-1:0] mpu_araddr, mpu_awaddr;
    logic [7:0]            mpu_arlen, mpu_awlen;
    logic [DATA_WIDTH-1:0] mpu_rdata, mpu_wdata;
    
    // 3. L2 Cache -> L3 Cache
    logic                  l2_arvalid, l2_arready, l2_rvalid, l2_rlast, l2_rready;
    logic                  l2_awvalid, l2_awready, l2_wvalid, l2_wlast, l2_wready;
    logic                  l2_bvalid, l2_bready;
    logic [ADDR_WIDTH-1:0] l2_araddr, l2_awaddr;
    logic [7:0]            l2_arlen, l2_awlen;
    logic [DATA_WIDTH-1:0] l2_rdata, l2_wdata;
    
    // 4. L3 Cache -> DDR4 Controller
    logic                  l3_arvalid, l3_arready, l3_rvalid, l3_rlast, l3_rready;
    logic                  l3_awvalid, l3_awready, l3_wvalid, l3_wlast, l3_wready;
    logic                  l3_bvalid, l3_bready;
    logic [ADDR_WIDTH-1:0] l3_araddr, l3_awaddr;
    logic [7:0]            l3_arlen, l3_awlen;
    logic [DATA_WIDTH-1:0] l3_rdata, l3_wdata;
    
    // Memory Exception Wire
    logic                  mpu_fault;

    // =========================================================================
    // MODULE INSTANTIATIONS
    // =========================================================================

    // 1. Memory Arbiter (4 AXI Slaves -> 1 AXI Master)
    memory_arbiter #(
        .NUM_MASTERS(NUM_MASTERS),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_memory_arbiter (
        .clk(clk),
        .rst_n(rst_n),
        // Slaves (From NoC)
        .s_axi_arvalid(s_axi_arvalid), .s_axi_araddr(s_axi_araddr), .s_axi_arlen(s_axi_arlen), .s_axi_arready(s_axi_arready),
        .s_axi_rvalid(s_axi_rvalid), .s_axi_rdata(s_axi_rdata), .s_axi_rlast(s_axi_rlast), .s_axi_rready(s_axi_rready),
        .s_axi_awvalid(s_axi_awvalid), .s_axi_awaddr(s_axi_awaddr), .s_axi_awlen(s_axi_awlen), .s_axi_awready(s_axi_awready),
        .s_axi_wvalid(s_axi_wvalid), .s_axi_wdata(s_axi_wdata), .s_axi_wlast(s_axi_wlast), .s_axi_wready(s_axi_wready),
        .s_axi_bvalid(s_axi_bvalid), .s_axi_bready(s_axi_bready),
        // Master (To MPU)
        .m_axi_arvalid(arb_arvalid), .m_axi_araddr(arb_araddr), .m_axi_arlen(arb_arlen), .m_axi_arready(arb_arready),
        .m_axi_rvalid(arb_rvalid), .m_axi_rdata(arb_rdata), .m_axi_rlast(arb_rlast), .m_axi_rready(arb_rready),
        .m_axi_awvalid(arb_awvalid), .m_axi_awaddr(arb_awaddr), .m_axi_awlen(arb_awlen), .m_axi_awready(arb_awready),
        .m_axi_wvalid(arb_wvalid), .m_axi_wdata(arb_wdata), .m_axi_wlast(arb_wlast), .m_axi_wready(arb_wready),
        .m_axi_bvalid(arb_bvalid), .m_axi_bready(arb_bready)
    );

    // 2. Memory Protection Unit (MPU)
    memory_protection_unit #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_mpu (
        .clk(clk),
        .rst_n(rst_n),
        // Slave (From Arbiter)
        .s_axi_arvalid(arb_arvalid), .s_axi_araddr(arb_araddr), .s_axi_arlen(arb_arlen), .s_axi_arready(arb_arready),
        .s_axi_rvalid(arb_rvalid), .s_axi_rdata(arb_rdata), .s_axi_rlast(arb_rlast), .s_axi_rready(arb_rready),
        .s_axi_awvalid(arb_awvalid), .s_axi_awaddr(arb_awaddr), .s_axi_awlen(arb_awlen), .s_axi_awready(arb_awready),
        .s_axi_wvalid(arb_wvalid), .s_axi_wdata(arb_wdata), .s_axi_wlast(arb_wlast), .s_axi_wready(arb_wready),
        .s_axi_bvalid(arb_bvalid), .s_axi_bready(arb_bready),
        // Master (To L2 Cache)
        .m_axi_arvalid(mpu_arvalid), .m_axi_araddr(mpu_araddr), .m_axi_arlen(mpu_arlen), .m_axi_arready(mpu_arready),
        .m_axi_rvalid(mpu_rvalid), .m_axi_rdata(mpu_rdata), .m_axi_rlast(mpu_rlast), .m_axi_rready(mpu_rready),
        .m_axi_awvalid(mpu_awvalid), .m_axi_awaddr(mpu_awaddr), .m_axi_awlen(mpu_awlen), .m_axi_awready(mpu_awready),
        .m_axi_wvalid(mpu_wvalid), .m_axi_wdata(mpu_wdata), .m_axi_wlast(mpu_wlast), .m_axi_wready(mpu_wready),
        .m_axi_bvalid(mpu_bvalid), .m_axi_bready(mpu_bready),
        .mpu_fault(mpu_fault)
    );

    // 3. L2 Cache Controller
    l2_cache_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_l2_cache (
        .clk(clk),
        .rst_n(rst_n),
        // Slave (From MPU)
        .s_axi_arvalid(mpu_arvalid), .s_axi_araddr(mpu_araddr), .s_axi_arlen(mpu_arlen), .s_axi_arready(mpu_arready),
        .s_axi_rvalid(mpu_rvalid), .s_axi_rdata(mpu_rdata), .s_axi_rlast(mpu_rlast), .s_axi_rready(mpu_rready),
        .s_axi_awvalid(mpu_awvalid), .s_axi_awaddr(mpu_awaddr), .s_axi_awlen(mpu_awlen), .s_axi_awready(mpu_awready),
        .s_axi_wvalid(mpu_wvalid), .s_axi_wdata(mpu_wdata), .s_axi_wlast(mpu_wlast), .s_axi_wready(mpu_wready),
        .s_axi_bvalid(mpu_bvalid), .s_axi_bready(mpu_bready),
        // Master (To L3 Cache)
        .m_axi_arvalid(l2_arvalid), .m_axi_araddr(l2_araddr), .m_axi_arlen(l2_arlen), .m_axi_arready(l2_arready),
        .m_axi_rvalid(l2_rvalid), .m_axi_rdata(l2_rdata), .m_axi_rlast(l2_rlast), .m_axi_rready(l2_rready),
        .m_axi_awvalid(l2_awvalid), .m_axi_awaddr(l2_awaddr), .m_axi_awlen(l2_awlen), .m_axi_awready(l2_awready),
        .m_axi_wvalid(l2_wvalid), .m_axi_wdata(l2_wdata), .m_axi_wlast(l2_wlast), .m_axi_wready(l2_wready),
        .m_axi_bvalid(l2_bvalid), .m_axi_bready(l2_bready)
    );

    // 4. L3 Cache Controller
    l3_cache_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_l3_cache (
        .clk(clk),
        .rst_n(rst_n),
        // Slave (From L2)
        .s_axi_arvalid(l2_arvalid), .s_axi_araddr(l2_araddr), .s_axi_arlen(l2_arlen), .s_axi_arready(l2_arready),
        .s_axi_rvalid(l2_rvalid), .s_axi_rdata(l2_rdata), .s_axi_rlast(l2_rlast), .s_axi_rready(l2_rready),
        .s_axi_awvalid(l2_awvalid), .s_axi_awaddr(l2_awaddr), .s_axi_awlen(l2_awlen), .s_axi_awready(l2_awready),
        .s_axi_wvalid(l2_wvalid), .s_axi_wdata(l2_wdata), .s_axi_wlast(l2_wlast), .s_axi_wready(l2_wready),
        .s_axi_bvalid(l2_bvalid), .s_axi_bready(l2_bready),
        // Master (To DDR4)
        .m_axi_arvalid(l3_arvalid), .m_axi_araddr(l3_araddr), .m_axi_arlen(l3_arlen), .m_axi_arready(l3_arready),
        .m_axi_rvalid(l3_rvalid), .m_axi_rdata(l3_rdata), .m_axi_rlast(l3_rlast), .m_axi_rready(l3_rready),
        .m_axi_awvalid(l3_awvalid), .m_axi_awaddr(l3_awaddr), .m_axi_awlen(l3_awlen), .m_axi_awready(l3_awready),
        .m_axi_wvalid(l3_wvalid), .m_axi_wdata(l3_wdata), .m_axi_wlast(l3_wlast), .m_axi_wready(l3_wready),
        .m_axi_bvalid(l3_bvalid), .m_axi_bready(l3_bready)
    );

    // 5. DDR4 Memory Controller
    ddr4_mem_ctrl #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_ddr4_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        // Slave (From L3)
        .s_axi_arvalid(l3_arvalid), .s_axi_araddr(l3_araddr), .s_axi_arlen(l3_arlen), .s_axi_arready(l3_arready),
        .s_axi_rvalid(l3_rvalid), .s_axi_rdata(l3_rdata), .s_axi_rlast(l3_rlast), .s_axi_rready(l3_rready),
        .s_axi_awvalid(l3_awvalid), .s_axi_awaddr(l3_awaddr), .s_axi_awlen(l3_awlen), .s_axi_awready(l3_awready),
        .s_axi_wvalid(l3_wvalid), .s_axi_wdata(l3_wdata), .s_axi_wlast(l3_wlast), .s_axi_wready(l3_wready),
        .s_axi_bvalid(l3_bvalid), .s_axi_bready(l3_bready),
        // DDR4 External Interface
        .ddr4_ck_p(ddr4_ck_p),
        .ddr4_ck_n(ddr4_ck_n),
        .ddr4_cke(ddr4_cke),
        .ddr4_cs_n(ddr4_cs_n),
        .ddr4_ras_n(ddr4_ras_n),
        .ddr4_cas_n(ddr4_cas_n),
        .ddr4_we_n(ddr4_we_n),
        .ddr4_bg(ddr4_bg),
        .ddr4_ba(ddr4_ba),
        .ddr4_a(ddr4_a),
        .ddr4_dq(ddr4_dq),
        .ddr4_dqs_p(ddr4_dqs_p),
        .ddr4_dqs_n(ddr4_dqs_n),
        .ddr4_dm(ddr4_dm)
    );

    // Note: The L2/L3 data and tag SRAM arrays are internally instantiated inside
    // l2_cache_ctrl and l3_cache_ctrl respectively to ensure tight critical path timing.
    // The MESI coherency directory is attached to the snooping bus of the Arbiter.

endmodule
