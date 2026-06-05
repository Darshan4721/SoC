`timescale 1ns/1ps
module io_subsystem_top #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter PCIE_ADDR_WIDTH = 64,
    parameter PCIE_DATA_WIDTH = 256
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // AXI-Lite Slave (Config Bus from NoC)
    input  logic                  s_axi_awvalid,
    input  logic [ADDR_WIDTH-1:0] s_axi_awaddr,
    output logic                  s_axi_awready,
    input  logic                  s_axi_wvalid,
    input  logic [DATA_WIDTH-1:0] s_axi_wdata,
    input  logic [3:0]            s_axi_wstrb,
    output logic                  s_axi_wready,
    output logic                  s_axi_bvalid,
    output logic [1:0]            s_axi_bresp,
    input  logic                  s_axi_bready,
    input  logic                  s_axi_arvalid,
    input  logic [ADDR_WIDTH-1:0] s_axi_araddr,
    output logic                  s_axi_arready,
    output logic                  s_axi_rvalid,
    output logic [DATA_WIDTH-1:0] s_axi_rdata,
    output logic [1:0]            s_axi_rresp,
    input  logic                  s_axi_rready,
    
    // AXI-Full Master (PCIe to Memory Bus)
    output logic                       m_axi_pcie_arvalid,
    output logic [PCIE_ADDR_WIDTH-1:0] m_axi_pcie_araddr,
    input  logic                       m_axi_pcie_arready,
    input  logic                       m_axi_pcie_rvalid,
    input  logic [PCIE_DATA_WIDTH-1:0] m_axi_pcie_rdata,
    output logic                       m_axi_pcie_rready,
    output logic                       m_axi_pcie_awvalid,
    output logic [PCIE_ADDR_WIDTH-1:0] m_axi_pcie_awaddr,
    input  logic                       m_axi_pcie_awready,
    output logic                       m_axi_pcie_wvalid,
    output logic [PCIE_DATA_WIDTH-1:0] m_axi_pcie_wdata,
    input  logic                       m_axi_pcie_wready,
    
    // Core Interrupts
    output logic                  meip,      // Machine External Interrupt (From PLIC)
    output logic                  mtime_irq, // Machine Timer Interrupt
    
    // Physical IO Pads
    output logic                  uart_tx_pad,
    input  logic                  uart_rx_pad,
    
    output logic                  spi_sck,
    output logic                  spi_mosi,
    input  logic                  spi_miso,
    output logic                  spi_cs_n,
    
    output logic                  i2c_scl_o,
    output logic                  i2c_sda_o,
    input  logic                  i2c_scl_i,
    input  logic                  i2c_sda_i,
    
    output logic [31:0]           pipe_tx_data,
    output logic [3:0]            pipe_tx_datak,
    input  logic [31:0]           pipe_rx_data,
    input  logic [3:0]            pipe_rx_datak
);

    // =========================================================================
    // INTERNAL WIRING (The Glue Logic)
    // =========================================================================
    
    // 1. Shared APB Bus (From Bridge to Slaves)
    logic [ADDR_WIDTH-1:0] apb_paddr;
    logic                  apb_psel;     // Master select
    logic                  apb_penable;
    logic                  apb_pwrite;
    logic [DATA_WIDTH-1:0] apb_pwdata;
    logic                  apb_pready;   // Muxed read-back
    logic [DATA_WIDTH-1:0] apb_prdata;   // Muxed read-back
    logic                  apb_pslverr;  // Muxed read-back
    
    // 2. Individual Selects & Readbacks
    logic psel_uart, psel_spi, psel_i2c, psel_timer, psel_plic;
    logic pready_uart, pready_spi, pready_i2c, pready_timer, pready_plic;
    logic [DATA_WIDTH-1:0] prdata_uart, prdata_spi, prdata_i2c, prdata_timer, prdata_plic;
    logic pslverr_uart, pslverr_spi, pslverr_i2c, pslverr_timer, pslverr_plic;
    
    // 3. Interrupt Wires to PLIC
    logic uart_irq, spi_irq, i2c_irq, pcie_irq;
    logic [31:0] plic_irq_sources;

    // =========================================================================
    // SIMPLE GLUE PROTOCOL LOGIC (APB Address Decoder & Mux)
    // =========================================================================
    
    // Memory Map:
    // 0x1000_0000 : UART
    // 0x1001_0000 : SPI
    // 0x1002_0000 : I2C
    // 0x1003_0000 : TIMER
    // 0x1004_0000 : PLIC
    
    assign psel_uart  = apb_psel && (apb_paddr[31:16] == 16'h1000);
    assign psel_spi   = apb_psel && (apb_paddr[31:16] == 16'h1001);
    assign psel_i2c   = apb_psel && (apb_paddr[31:16] == 16'h1002);
    assign psel_timer = apb_psel && (apb_paddr[31:16] == 16'h1003);
    assign psel_plic  = apb_psel && (apb_paddr[31:16] == 16'h1004);
    
    always_comb begin
        if (psel_uart) begin
            apb_prdata  = prdata_uart;
            apb_pready  = pready_uart;
            apb_pslverr = pslverr_uart;
        end else if (psel_spi) begin
            apb_prdata  = prdata_spi;
            apb_pready  = pready_spi;
            apb_pslverr = pslverr_spi;
        end else if (psel_i2c) begin
            apb_prdata  = prdata_i2c;
            apb_pready  = pready_i2c;
            apb_pslverr = pslverr_i2c;
        end else if (psel_timer) begin
            apb_prdata  = prdata_timer;
            apb_pready  = pready_timer;
            apb_pslverr = pslverr_timer;
        end else if (psel_plic) begin
            apb_prdata  = prdata_plic;
            apb_pready  = pready_plic;
            apb_pslverr = pslverr_plic;
        end else begin
            apb_prdata  = '0;
            apb_pready  = 1'b1; // Default to ready to prevent bus lockup
            apb_pslverr = apb_psel; // Error if selecting unmapped region
        end
    end
    
    // Bundle the hardware interrupts into the PLIC
    assign plic_irq_sources = {28'h0, pcie_irq, i2c_irq, spi_irq, uart_irq};

    // =========================================================================
    // MODULE INSTANTIATIONS
    // =========================================================================

    axi_to_apb_bridge #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_axi_apb_bridge (
        .clk(clk), .rst_n(rst_n),
        .s_axi_awvalid(s_axi_awvalid), .s_axi_awaddr(s_axi_awaddr), .s_axi_awready(s_axi_awready),
        .s_axi_wvalid(s_axi_wvalid), .s_axi_wdata(s_axi_wdata), .s_axi_wstrb(s_axi_wstrb), .s_axi_wready(s_axi_wready),
        .s_axi_bvalid(s_axi_bvalid), .s_axi_bresp(s_axi_bresp), .s_axi_bready(s_axi_bready),
        .s_axi_arvalid(s_axi_arvalid), .s_axi_araddr(s_axi_araddr), .s_axi_arready(s_axi_arready),
        .s_axi_rvalid(s_axi_rvalid), .s_axi_rdata(s_axi_rdata), .s_axi_rresp(s_axi_rresp), .s_axi_rready(s_axi_rready),
        .m_apb_paddr(apb_paddr), .m_apb_psel(apb_psel), .m_apb_penable(apb_penable),
        .m_apb_pwrite(apb_pwrite), .m_apb_pwdata(apb_pwdata),
        .m_apb_pready(apb_pready), .m_apb_prdata(apb_prdata), .m_apb_pslverr(apb_pslverr)
    );

    peripheral_uart #(
        .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)
    ) i_uart (
        .clk(clk), .rst_n(rst_n),
        .paddr(apb_paddr), .psel(psel_uart), .penable(apb_penable), .pwrite(apb_pwrite), .pwdata(apb_pwdata),
        .pready(pready_uart), .prdata(prdata_uart), .pslverr(pslverr_uart),
        .tx_pad(uart_tx_pad), .rx_pad(uart_rx_pad), .uart_irq(uart_irq)
    );

    peripheral_spi #(
        .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)
    ) i_spi (
        .clk(clk), .rst_n(rst_n),
        .paddr(apb_paddr), .psel(psel_spi), .penable(apb_penable), .pwrite(apb_pwrite), .pwdata(apb_pwdata),
        .pready(pready_spi), .prdata(prdata_spi), .pslverr(pslverr_spi),
        .spi_sck(spi_sck), .spi_mosi(spi_mosi), .spi_miso(spi_miso), .spi_cs_n(spi_cs_n), .spi_irq(spi_irq)
    );

    peripheral_i2c #(
        .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)
    ) i_i2c (
        .clk(clk), .rst_n(rst_n),
        .paddr(apb_paddr), .psel(psel_i2c), .penable(apb_penable), .pwrite(apb_pwrite), .pwdata(apb_pwdata),
        .pready(pready_i2c), .prdata(prdata_i2c), .pslverr(pslverr_i2c),
        .i2c_scl_o(i2c_scl_o), .i2c_sda_o(i2c_sda_o), .i2c_scl_i(i2c_scl_i), .i2c_sda_i(i2c_sda_i), .i2c_irq(i2c_irq)
    );

    peripheral_timer #(
        .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)
    ) i_timer (
        .clk(clk), .rst_n(rst_n),
        .paddr(apb_paddr), .psel(psel_timer), .penable(apb_penable), .pwrite(apb_pwrite), .pwdata(apb_pwdata),
        .pready(pready_timer), .prdata(prdata_timer), .pslverr(pslverr_timer),
        .mtime_irq(mtime_irq)
    );

    plic_interrupt_controller #(
        .ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH), .NUM_SOURCES(32)
    ) i_plic (
        .clk(clk), .rst_n(rst_n),
        .paddr(apb_paddr), .psel(psel_plic), .penable(apb_penable), .pwrite(apb_pwrite), .pwdata(apb_pwdata),
        .pready(pready_plic), .prdata(prdata_plic), .pslverr(pslverr_plic),
        .irq_sources(plic_irq_sources), .meip(meip)
    );

    pcie_root_complex #(
        .ADDR_WIDTH(PCIE_ADDR_WIDTH), .DATA_WIDTH(PCIE_DATA_WIDTH)
    ) i_pcie (
        .clk(clk), .rst_n(rst_n),
        .m_axi_arvalid(m_axi_pcie_arvalid), .m_axi_araddr(m_axi_pcie_araddr), .m_axi_arready(m_axi_pcie_arready),
        .m_axi_rvalid(m_axi_pcie_rvalid), .m_axi_rdata(m_axi_pcie_rdata), .m_axi_rready(m_axi_pcie_rready),
        .m_axi_awvalid(m_axi_pcie_awvalid), .m_axi_awaddr(m_axi_pcie_awaddr), .m_axi_awready(m_axi_pcie_awready),
        .m_axi_wvalid(m_axi_pcie_wvalid), .m_axi_wdata(m_axi_pcie_wdata), .m_axi_wready(m_axi_pcie_wready),
        .pipe_tx_data(pipe_tx_data), .pipe_tx_datak(pipe_tx_datak),
        .pipe_rx_data(pipe_rx_data), .pipe_rx_datak(pipe_rx_datak), .pcie_irq(pcie_irq)
    );

endmodule
