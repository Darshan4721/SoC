`timescale 1ns/1ps

module tb_rv64_core_top();

    // =========================================================================
    // Clocks and Resets
    // =========================================================================
    logic clk;
    logic rst_n;
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    initial begin
        rst_n = 0;
        #20 rst_n = 1;
    end

    // =========================================================================
    // Core Interfaces
    // =========================================================================
    // Interrupts
    logic timer_irq = 0;
    logic ext_irq = 0;
    logic soft_irq = 0;

    // I-Cache AXI
    logic                  m_axi_icache_arvalid;
    logic [63:0]           m_axi_icache_araddr;
    logic [7:0]            m_axi_icache_arlen;
    logic                  m_axi_icache_arready;
    logic                  m_axi_icache_rvalid;
    logic [255:0]          m_axi_icache_rdata;
    logic                  m_axi_icache_rlast;
    logic                  m_axi_icache_rready;

    // D-Cache AXI
    logic                  m_axi_dcache_arvalid;
    logic [63:0]           m_axi_dcache_araddr;
    logic [7:0]            m_axi_dcache_arlen;
    logic                  m_axi_dcache_arready;
    logic                  m_axi_dcache_rvalid;
    logic [255:0]          m_axi_dcache_rdata;
    logic                  m_axi_dcache_rlast;
    logic                  m_axi_dcache_rready;
    logic                  m_axi_dcache_awvalid;
    logic [63:0]           m_axi_dcache_awaddr;
    logic [7:0]            m_axi_dcache_awlen;
    logic                  m_axi_dcache_awready;
    logic                  m_axi_dcache_wvalid;
    logic [255:0]          m_axi_dcache_wdata;
    logic                  m_axi_dcache_wlast;
    logic                  m_axi_dcache_wready;
    logic                  m_axi_dcache_bvalid;
    logic                  m_axi_dcache_bready;

    // =========================================================================
    // Core Instantiation
    // =========================================================================
    rv64_core_top #(
        .PC_WIDTH(64),
        .ADDR_WIDTH(64),
        .DATA_WIDTH(256),
        .INSTR_WIDTH(32),
        .ARCH_REG_WIDTH(5),
        .PHYS_REG_WIDTH(7)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .timer_irq(timer_irq),
        .ext_irq(ext_irq),
        .soft_irq(soft_irq),
        
        .m_axi_icache_arvalid(m_axi_icache_arvalid),
        .m_axi_icache_araddr(m_axi_icache_araddr),
        .m_axi_icache_arlen(m_axi_icache_arlen),
        .m_axi_icache_arready(m_axi_icache_arready),
        .m_axi_icache_rvalid(m_axi_icache_rvalid),
        .m_axi_icache_rdata(m_axi_icache_rdata),
        .m_axi_icache_rlast(m_axi_icache_rlast),
        .m_axi_icache_rready(m_axi_icache_rready),
        
        .m_axi_dcache_arvalid(m_axi_dcache_arvalid),
        .m_axi_dcache_araddr(m_axi_dcache_araddr),
        .m_axi_dcache_arlen(m_axi_dcache_arlen),
        .m_axi_dcache_arready(m_axi_dcache_arready),
        .m_axi_dcache_rvalid(m_axi_dcache_rvalid),
        .m_axi_dcache_rdata(m_axi_dcache_rdata),
        .m_axi_dcache_rlast(m_axi_dcache_rlast),
        .m_axi_dcache_rready(m_axi_dcache_rready),
        
        .m_axi_dcache_awvalid(m_axi_dcache_awvalid),
        .m_axi_dcache_awaddr(m_axi_dcache_awaddr),
        .m_axi_dcache_awlen(m_axi_dcache_awlen),
        .m_axi_dcache_awready(m_axi_dcache_awready),
        .m_axi_dcache_wvalid(m_axi_dcache_wvalid),
        .m_axi_dcache_wdata(m_axi_dcache_wdata),
        .m_axi_dcache_wlast(m_axi_dcache_wlast),
        .m_axi_dcache_wready(m_axi_dcache_wready),
        
        .m_axi_dcache_bvalid(m_axi_dcache_bvalid),
        .m_axi_dcache_bready(m_axi_dcache_bready)
    );

    // =========================================================================
    // Instruction Memory Stub
    // =========================================================================
    dummy_axi_memory #(
        .ADDR_WIDTH(64),
        .DATA_WIDTH(256),
        .MEM_SIZE(65536)
    ) i_imem (
        .clk(clk),
        .rst_n(rst_n),
        .s_axi_arvalid(m_axi_icache_arvalid),
        .s_axi_araddr(m_axi_icache_araddr),
        .s_axi_arlen(m_axi_icache_arlen),
        .s_axi_arready(m_axi_icache_arready),
        .s_axi_rvalid(m_axi_icache_rvalid),
        .s_axi_rdata(m_axi_icache_rdata),
        .s_axi_rlast(m_axi_icache_rlast),
        .s_axi_rready(m_axi_icache_rready),
        
        // Write channels unused for I-Cache
        .s_axi_awvalid(1'b0),
        .s_axi_awaddr(64'h0),
        .s_axi_awlen(8'h0),
        .s_axi_awready(),
        .s_axi_wvalid(1'b0),
        .s_axi_wdata(256'h0),
        .s_axi_wlast(1'b0),
        .s_axi_wready(),
        .s_axi_bvalid(),
        .s_axi_bready(1'b1)
    );

    // =========================================================================
    // Data Memory Stub
    // =========================================================================
    dummy_axi_memory #(
        .ADDR_WIDTH(64),
        .DATA_WIDTH(256),
        .MEM_SIZE(65536)
    ) i_dmem (
        .clk(clk),
        .rst_n(rst_n),
        .s_axi_arvalid(m_axi_dcache_arvalid),
        .s_axi_araddr(m_axi_dcache_araddr),
        .s_axi_arlen(m_axi_dcache_arlen),
        .s_axi_arready(m_axi_dcache_arready),
        .s_axi_rvalid(m_axi_dcache_rvalid),
        .s_axi_rdata(m_axi_dcache_rdata),
        .s_axi_rlast(m_axi_dcache_rlast),
        .s_axi_rready(m_axi_dcache_rready),
        
        .s_axi_awvalid(m_axi_dcache_awvalid),
        .s_axi_awaddr(m_axi_dcache_awaddr),
        .s_axi_awlen(m_axi_dcache_awlen),
        .s_axi_awready(m_axi_dcache_awready),
        .s_axi_wvalid(m_axi_dcache_wvalid),
        .s_axi_wdata(m_axi_dcache_wdata),
        .s_axi_wlast(m_axi_dcache_wlast),
        .s_axi_wready(m_axi_dcache_wready),
        .s_axi_bvalid(m_axi_dcache_bvalid),
        .s_axi_bready(m_axi_dcache_bready)
    );

    // =========================================================================
    // VCD Dumping
    // =========================================================================
    initial begin
        $dumpfile("rv64_core.vcd");
        $dumpvars(0, tb_rv64_core_top);
        
        #10000;
        $display("Simulation timeout reached. Terminating.");
        $finish;
    end

endmodule
