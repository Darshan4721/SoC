`timescale 1ns/1ps

module soc_top #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256,
    parameter PCIE_DATA_WIDTH = 256,
    parameter NUM_CORES = 4,
    parameter NUM_MASTERS = 11, // 8 Cores, 1 GPU, 1 NPU, 1 Vector
    parameter NUM_SLAVES = 2,
    parameter DDR4_DQ_WIDTH = 64,
    parameter DDR4_DQS_WIDTH = 8,
    parameter DDR4_ADDR_WIDTH = 16,
    parameter DDR4_BA_WIDTH = 2,
    parameter DDR4_BG_WIDTH = 2,
    parameter PCIE_PIPE_WIDTH = 32
) (
    input  logic                          ref_clk,
    input  logic                          por_n,
    
    output logic                          ddr4_ck_p,
    output logic                          ddr4_ck_n,
    output logic                          ddr4_cke,
    output logic                          ddr4_cs_n,
    output logic                          ddr4_ras_n,
    output logic                          ddr4_cas_n,
    output logic                          ddr4_we_n,
    output logic [DDR4_BG_WIDTH-1:0]      ddr4_bg,
    output logic [DDR4_BA_WIDTH-1:0]      ddr4_ba,
    output logic [DDR4_ADDR_WIDTH-1:0]    ddr4_a,
    inout  wire  [DDR4_DQ_WIDTH-1:0]      ddr4_dq,
    inout  wire  [DDR4_DQS_WIDTH-1:0]     ddr4_dqs_p,
    inout  wire  [DDR4_DQS_WIDTH-1:0]     ddr4_dqs_n,
    output logic [DDR4_DQS_WIDTH-1:0]     ddr4_dm,
    
    output logic [PCIE_PIPE_WIDTH-1:0]    pipe_tx_data,
    output logic [(PCIE_PIPE_WIDTH/8)-1:0] pipe_tx_datak,
    input  logic [PCIE_PIPE_WIDTH-1:0]    pipe_rx_data,
    input  logic [(PCIE_PIPE_WIDTH/8)-1:0] pipe_rx_datak,
    
    output logic                          uart_tx_pad,
    input  logic                          uart_rx_pad,
    output logic                          spi_sck,
    output logic                          spi_mosi,
    input  logic                          spi_miso,
    output logic                          spi_cs_n,
    output logic                          i2c_scl_o,
    output logic                          i2c_sda_o,
    input  logic                          i2c_scl_i,
    input  logic                          i2c_sda_i
);

    // =========================================================================
    // GLOBAL WIRING & GLUE
    // =========================================================================
    logic sys_clk;
    logic rst_n_noc, rst_n_mem, rst_n_periph, rst_n_accel, rst_n_core;
    logic system_ready;
    
    logic [7:0] ext_io_irq;
    logic [3:0] meip;
    logic mtime_irq;
    assign ext_io_irq = {7'b0, uart_rx_pad}; // Mock IO interrupt source
    
    // -------------------------------------------------------------------------
    // NoC Matrix Wires
    // -------------------------------------------------------------------------
    logic [NUM_MASTERS-1:0]                 m_axi_arvalid, m_axi_arready, m_axi_rvalid, m_axi_rlast, m_axi_rready;
    logic [NUM_MASTERS-1:0]                 m_axi_awvalid, m_axi_awready, m_axi_wvalid, m_axi_wlast, m_axi_wready;
    logic [NUM_MASTERS-1:0]                 m_axi_bvalid, m_axi_bready;
    logic [NUM_MASTERS-1:0][ADDR_WIDTH-1:0] m_axi_araddr, m_axi_awaddr;
    logic [NUM_MASTERS-1:0][7:0]            m_axi_arlen, m_axi_awlen;
    logic [NUM_MASTERS-1:0][DATA_WIDTH-1:0] m_axi_rdata, m_axi_wdata;
    
    logic [NUM_SLAVES-1:0]                 s_axi_arvalid, s_axi_arready, s_axi_rvalid, s_axi_rlast, s_axi_rready;
    logic [NUM_SLAVES-1:0]                 s_axi_awvalid, s_axi_awready, s_axi_wvalid, s_axi_wlast, s_axi_wready;
    logic [NUM_SLAVES-1:0]                 s_axi_bvalid, s_axi_bready;
    logic [NUM_SLAVES-1:0][ADDR_WIDTH-1:0] s_axi_araddr, s_axi_awaddr;
    logic [NUM_SLAVES-1:0][7:0]            s_axi_arlen, s_axi_awlen;
    logic [NUM_SLAVES-1:0][DATA_WIDTH-1:0] s_axi_rdata, s_axi_wdata;

    // =========================================================================
    // 1. SYSTEM CONTROLLER
    // =========================================================================
    sys_ctrl_unit i_sys_ctrl (
        .ref_clk(ref_clk),
        .por_n(por_n),
        .sys_clk(sys_clk),
        .rst_n_noc(rst_n_noc),
        .rst_n_mem(rst_n_mem),
        .rst_n_periph(rst_n_periph),
        .rst_n_accel(rst_n_accel),
        .rst_n_core(rst_n_core),
        .system_ready(system_ready),
        .ext_io_irq(ext_io_irq),
        .meip(meip)
    );

    // =========================================================================
    // 2. NETWORK ON CHIP (NoC) ROUTER
    // =========================================================================
    noc_router #(
        .NUM_MASTERS(NUM_MASTERS),
        .NUM_SLAVES(NUM_SLAVES),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_noc_router (
        .clk(sys_clk),
        .rst_n(rst_n_noc),
        .s_axi_arvalid(m_axi_arvalid), .s_axi_araddr(m_axi_araddr), .s_axi_arlen(m_axi_arlen), .s_axi_arready(m_axi_arready),
        .s_axi_rvalid(m_axi_rvalid), .s_axi_rdata(m_axi_rdata), .s_axi_rlast(m_axi_rlast), .s_axi_rready(m_axi_rready),
        .s_axi_awvalid(m_axi_awvalid), .s_axi_awaddr(m_axi_awaddr), .s_axi_awlen(m_axi_awlen), .s_axi_awready(m_axi_awready),
        .s_axi_wvalid(m_axi_wvalid), .s_axi_wdata(m_axi_wdata), .s_axi_wlast(m_axi_wlast), .s_axi_wready(m_axi_wready),
        .s_axi_bvalid(m_axi_bvalid), .s_axi_bready(m_axi_bready),
        
        .m_axi_arvalid(s_axi_arvalid), .m_axi_araddr(s_axi_araddr), .m_axi_arlen(s_axi_arlen), .m_axi_arready(s_axi_arready),
        .m_axi_rvalid(s_axi_rvalid), .m_axi_rdata(s_axi_rdata), .m_axi_rlast(s_axi_rlast), .m_axi_rready(s_axi_rready),
        .m_axi_awvalid(s_axi_awvalid), .m_axi_awaddr(s_axi_awaddr), .m_axi_awlen(s_axi_awlen), .m_axi_awready(s_axi_awready),
        .m_axi_wvalid(s_axi_wvalid), .m_axi_wdata(s_axi_wdata), .m_axi_wlast(s_axi_wlast), .m_axi_wready(s_axi_wready),
        .m_axi_bvalid(s_axi_bvalid), .m_axi_bready(s_axi_bready)
    );

    // =========================================================================
    // 3. QUAD-CORE CLUSTER (Masters 0-7)
    // =========================================================================
    generate
        for (genvar i = 0; i < NUM_CORES; i++) begin : core_inst
            
            // Explicit Padding: Core uses 64-bit/256-bit data, NoC is 256-bit
            logic [255:0] icache_rdata_pad;
            logic [255:0] dcache_rdata_pad;
            assign icache_rdata_pad = m_axi_rdata[i*2];
            assign dcache_rdata_pad = m_axi_rdata[i*2+1];
            
            logic [255:0] dcache_wdata_pad;
            assign m_axi_wdata[i*2+1] = dcache_wdata_pad;
            assign m_axi_wdata[i*2] = '0; // I-Cache doesn't write
            
            rv64_core_top #(
                .PC_WIDTH(64),
                .ADDR_WIDTH(64),
                .DATA_WIDTH(256), // Matches NoC
                .INSTR_WIDTH(32)
            ) i_core (
                .clk(sys_clk),
                .rst_n(rst_n_core),
                .timer_irq(mtime_irq),
                .ext_irq(meip[i]),
                .soft_irq(1'b0),
                
                // I-Cache -> NoC Port i*2
                .m_axi_icache_arvalid(m_axi_arvalid[i*2]), .m_axi_icache_araddr(m_axi_araddr[i*2]),
                .m_axi_icache_arlen(m_axi_arlen[i*2]),     .m_axi_icache_arready(m_axi_arready[i*2]),
                .m_axi_icache_rvalid(m_axi_rvalid[i*2]),   .m_axi_icache_rdata(icache_rdata_pad),
                .m_axi_icache_rlast(m_axi_rlast[i*2]),     .m_axi_icache_rready(m_axi_rready[i*2]),
                
                // D-Cache -> NoC Port i*2+1
                .m_axi_dcache_arvalid(m_axi_arvalid[i*2+1]), .m_axi_dcache_araddr(m_axi_araddr[i*2+1]),
                .m_axi_dcache_arlen(m_axi_arlen[i*2+1]),     .m_axi_dcache_arready(m_axi_arready[i*2+1]),
                .m_axi_dcache_rvalid(m_axi_rvalid[i*2+1]),   .m_axi_dcache_rdata(dcache_rdata_pad),
                .m_axi_dcache_rlast(m_axi_rlast[i*2+1]),     .m_axi_dcache_rready(m_axi_rready[i*2+1]),
                .m_axi_dcache_awvalid(m_axi_awvalid[i*2+1]), .m_axi_dcache_awaddr(m_axi_awaddr[i*2+1]),
                .m_axi_dcache_awlen(m_axi_awlen[i*2+1]),     .m_axi_dcache_awready(m_axi_awready[i*2+1]),
                .m_axi_dcache_wvalid(m_axi_wvalid[i*2+1]),   .m_axi_dcache_wdata(dcache_wdata_pad),
                .m_axi_dcache_wlast(m_axi_wlast[i*2+1]),     .m_axi_dcache_wready(m_axi_wready[i*2+1]),
                .m_axi_dcache_bvalid(m_axi_bvalid[i*2+1]),   .m_axi_dcache_bready(m_axi_bready[i*2+1])
            );
        end
    endgenerate

    // =========================================================================
    // 4. ACCELERATORS (Masters 8, 9, 10)
    // =========================================================================
    // Master 8: GPU
    logic [31:0] gpu_araddr, gpu_awaddr, gpu_rdata, gpu_wdata;
    assign m_axi_araddr[8] = {32'b0, gpu_araddr};
    assign m_axi_awaddr[8] = {32'b0, gpu_awaddr};
    assign gpu_rdata = m_axi_rdata[8][31:0];
    assign m_axi_wdata[8] = {224'b0, gpu_wdata};
    assign m_axi_arlen[8] = 8'd0;
    assign m_axi_awlen[8] = 8'd0;
    assign m_axi_wlast[8] = 1'b1;

    gpu_subsystem_top i_gpu (
        .clk(sys_clk), .rst_n(rst_n_accel),
        .m_axi_arvalid(m_axi_arvalid[8]), .m_axi_araddr(gpu_araddr), .m_axi_arlen(), .m_axi_arready(m_axi_arready[8]),
        .m_axi_rvalid(m_axi_rvalid[8]),   .m_axi_rdata(gpu_rdata),   .m_axi_rlast(m_axi_rlast[8]), .m_axi_rready(m_axi_rready[8]),
        .m_axi_awvalid(m_axi_awvalid[8]), .m_axi_awaddr(gpu_awaddr), .m_axi_awready(m_axi_awready[8]),
        .m_axi_wvalid(m_axi_wvalid[8]),   .m_axi_wdata(gpu_wdata),   .m_axi_wready(m_axi_wready[8]),
        // Ties for unused
        .s_axi_awvalid(1'b0), .s_axi_awaddr('0), .s_axi_awready(), .s_axi_wvalid(1'b0), .s_axi_wdata('0),
        .s_axi_wstrb('0), .s_axi_wready(), .s_axi_bvalid(), .s_axi_bresp(), .s_axi_bready(1'b1), .s_axi_arvalid(1'b0), .s_axi_araddr('0),
        .s_axi_arready(), .s_axi_rvalid(), .s_axi_rdata(), .s_axi_rresp(), .s_axi_rready(1'b1)
    );

    // Master 9: NPU
    npu_subsystem_top i_npu (
        .clk(sys_clk), .rst_n(rst_n_accel),
        .m_axi_arvalid(m_axi_arvalid[9]), .m_axi_araddr(m_axi_araddr[9]), .m_axi_arlen(m_axi_arlen[9]), .m_axi_arready(m_axi_arready[9]),
        .m_axi_rvalid(m_axi_rvalid[9]),   .m_axi_rdata(m_axi_rdata[9]),   .m_axi_rlast(m_axi_rlast[9]),   .m_axi_rready(m_axi_rready[9]),
        // NPU specific ties
        .s_axi_awvalid(1'b0), .s_axi_awaddr('0), .s_axi_awready(), .s_axi_wvalid(1'b0), .s_axi_wdata('0), .s_axi_wready(),
        .s_axi_wstrb('0), .s_axi_bvalid(), .s_axi_bresp(), .s_axi_bready(1'b1), .s_axi_arvalid(1'b0), .s_axi_araddr('0), .s_axi_arready(),
        .s_axi_rvalid(), .s_axi_rdata(), .s_axi_rresp(), .s_axi_rready(1'b1), 
        .act_in_valid(1'b0), .act_in_data('0), .act_in_ready(), .act_out_valid(), .act_out_data(), .act_out_ready(1'b1)
    );
    
    assign m_axi_awvalid[9] = 1'b0;
    assign m_axi_awaddr[9] = '0;
    assign m_axi_awlen[9] = '0;
    assign m_axi_wvalid[9] = 1'b0;
    assign m_axi_wdata[9] = '0;
    assign m_axi_wlast[9] = 1'b0;
    assign m_axi_bready[9] = 1'b1;

    // Master 10: Vector (Adapting memory port to AXI)
    logic                  vec_mem_req_val, vec_mem_is_store, vec_mem_req_rdy;
    logic                  vec_mem_rsp_val;
    logic [63:0]           vec_mem_addr;
    logic [255:0]          vec_mem_wdata, vec_mem_rdata;

    vector_subsystem_top #(
        .ADDR_WIDTH(64),
        .ELEM_WIDTH(256)
    ) i_vector (
        .clk(sys_clk), .rst_n(rst_n_accel),
        .flush(1'b0), .dispatch_val(1'b0), .dispatch_instr('0), .dispatch_vd('0), .dispatch_vs1('0), .dispatch_vs2('0), .dispatch_vm('0),
        .queue_ready(),
        .mem_req_val(vec_mem_req_val), .mem_is_store(vec_mem_is_store), .mem_addr(vec_mem_addr), .mem_wdata(vec_mem_wdata),
        .mem_req_rdy(vec_mem_req_rdy), .mem_rsp_val(vec_mem_rsp_val), .mem_rdata(vec_mem_rdata)
    );

    assign m_axi_arvalid[10] = vec_mem_req_val && !vec_mem_is_store;
    assign m_axi_araddr[10]  = vec_mem_addr;
    assign m_axi_arlen[10]   = 8'h0; 
    assign m_axi_rready[10]  = 1'b1;
    
    assign m_axi_awvalid[10] = vec_mem_req_val && vec_mem_is_store;
    assign m_axi_awaddr[10]  = vec_mem_addr;
    assign m_axi_awlen[10]   = 8'h0;
    assign m_axi_wvalid[10]  = vec_mem_req_val && vec_mem_is_store;
    assign m_axi_wdata[10]   = vec_mem_wdata;
    assign m_axi_wlast[10]   = 1'b1;
    assign m_axi_bready[10]  = 1'b1;

    assign vec_mem_req_rdy = vec_mem_is_store ? m_axi_awready[10] : m_axi_arready[10];
    assign vec_mem_rsp_val = vec_mem_is_store ? m_axi_bvalid[10] : m_axi_rvalid[10];
    assign vec_mem_rdata   = m_axi_rdata[10];

    // =========================================================================
    // 5. SLAVES (Memory & IO)
    // =========================================================================
    // Slave 0: DDR4 Memory Controller
    memory_subsystem_top #(
        .NUM_MASTERS(1),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_memory_subsystem (
        .clk(sys_clk), .rst_n(rst_n_mem),
        .s_axi_arvalid(s_axi_arvalid[0]), .s_axi_araddr(s_axi_araddr[0]), .s_axi_arlen(s_axi_arlen[0]), .s_axi_arready(s_axi_arready[0]),
        .s_axi_rvalid(s_axi_rvalid[0]),   .s_axi_rdata(s_axi_rdata[0]),   .s_axi_rlast(s_axi_rlast[0]), .s_axi_rready(s_axi_rready[0]),
        .s_axi_awvalid(s_axi_awvalid[0]), .s_axi_awaddr(s_axi_awaddr[0]), .s_axi_awlen(s_axi_awlen[0]), .s_axi_awready(s_axi_awready[0]),
        .s_axi_wvalid(s_axi_wvalid[0]),   .s_axi_wdata(s_axi_wdata[0]),   .s_axi_wlast(s_axi_wlast[0]), .s_axi_wready(s_axi_wready[0]),
        .s_axi_bvalid(s_axi_bvalid[0]),   .s_axi_bready(s_axi_bready[0]),
        .ddr4_ck_p(ddr4_ck_p), .ddr4_ck_n(ddr4_ck_n), .ddr4_cke(ddr4_cke), .ddr4_cs_n(ddr4_cs_n),
        .ddr4_ras_n(ddr4_ras_n), .ddr4_cas_n(ddr4_cas_n), .ddr4_we_n(ddr4_we_n), .ddr4_bg(ddr4_bg),
        .ddr4_ba(ddr4_ba), .ddr4_a(ddr4_a), .ddr4_dq(ddr4_dq), .ddr4_dqs_p(ddr4_dqs_p),
        .ddr4_dqs_n(ddr4_dqs_n), .ddr4_dm(ddr4_dm)
    );

    // Slave 1: IO Subsystem
    logic [31:0] io_s_axi_rdata;
    assign s_axi_rdata[1] = {224'b0, io_s_axi_rdata};
    assign s_axi_rlast[1] = 1'b1;

    io_subsystem_top i_io_subsystem (
        .clk(sys_clk), .rst_n(rst_n_periph),
        .s_axi_arvalid(s_axi_arvalid[1]), .s_axi_araddr(s_axi_araddr[1][31:0]), .s_axi_arready(s_axi_arready[1]),
        .s_axi_rvalid(s_axi_rvalid[1]),   .s_axi_rdata(io_s_axi_rdata),   .s_axi_rresp(), .s_axi_rready(s_axi_rready[1]),
        .s_axi_awvalid(s_axi_awvalid[1]), .s_axi_awaddr(s_axi_awaddr[1][31:0]), .s_axi_awready(s_axi_awready[1]),
        .s_axi_wvalid(s_axi_wvalid[1]),   .s_axi_wdata(s_axi_wdata[1][31:0]),   .s_axi_wstrb(4'hf), .s_axi_wready(s_axi_wready[1]),
        .s_axi_bvalid(s_axi_bvalid[1]),   .s_axi_bresp(), .s_axi_bready(s_axi_bready[1]),
        .meip(), .mtime_irq(mtime_irq), // meip left unconnected here since PLIC handles it
        .uart_tx_pad(uart_tx_pad), .uart_rx_pad(uart_rx_pad),
        .spi_sck(spi_sck), .spi_mosi(spi_mosi), .spi_miso(spi_miso), .spi_cs_n(spi_cs_n),
        .i2c_scl_o(i2c_scl_o), .i2c_sda_o(i2c_sda_o), .i2c_scl_i(i2c_scl_i), .i2c_sda_i(i2c_sda_i),
        .pipe_tx_data(pipe_tx_data), .pipe_tx_datak(pipe_tx_datak), .pipe_rx_data(pipe_rx_data), .pipe_rx_datak(pipe_rx_datak),
        .m_axi_pcie_arvalid(), .m_axi_pcie_araddr(), .m_axi_pcie_arready(1'b1),
        .m_axi_pcie_rvalid(1'b0), .m_axi_pcie_rdata('0), .m_axi_pcie_rready(),
        .m_axi_pcie_awvalid(), .m_axi_pcie_awaddr(), .m_axi_pcie_awready(1'b1),
        .m_axi_pcie_wvalid(), .m_axi_pcie_wdata(), .m_axi_pcie_wready(1'b1)
    );

endmodule
