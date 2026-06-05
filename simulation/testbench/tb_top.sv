`timescale 1ns/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
import soc_tb_pkg::*;

module tb_top;

    // 1. Clock and Reset Generation
    logic ref_clk;
    logic por_n;
    
    initial begin
        ref_clk = 0;
        forever #10 ref_clk = ~ref_clk; // 50MHz reference clock
    end
    
    initial begin
        por_n = 0;
        #100;
        por_n = 1; // Release reset after 100ns
    end

    // 2. Physical SoC Wires
    // DDR4 Interface
    logic        ddr4_ck_p, ddr4_ck_n;
    logic        ddr4_cke;
    logic        ddr4_cs_n, ddr4_ras_n, ddr4_cas_n, ddr4_we_n;
    logic [1:0]  ddr4_bg, ddr4_ba;
    logic [13:0] ddr4_a;
    wire  [63:0] ddr4_dq;
    wire  [7:0]  ddr4_dqs_p, ddr4_dqs_n;
    logic [7:0]  ddr4_dm;
    
    // Peripherals
    logic uart_tx, uart_rx;
    logic spi_sck, spi_mosi, spi_miso, spi_cs_n;
    logic i2c_scl_o, i2c_sda_o, i2c_scl_i, i2c_sda_i;
    
    logic [31:0] pipe_tx_data, pipe_rx_data;
    logic [3:0]  pipe_tx_datak, pipe_rx_datak;

    // Tie-offs for inputs
    assign uart_rx = 1'b1;
    assign spi_miso = 1'b0;
    assign i2c_scl_i = i2c_scl_o;
    assign i2c_sda_i = i2c_sda_o;
    assign pipe_rx_data = '0;
    assign pipe_rx_datak = '0;

    // 3. DUT Instantiation
    soc_top dut (
        .ref_clk(ref_clk),
        .por_n(por_n),
        
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
        .ddr4_dm(ddr4_dm),
        
        .uart_tx_pad(uart_tx),
        .uart_rx_pad(uart_rx),
        .spi_sck(spi_sck),
        .spi_mosi(spi_mosi),
        .spi_miso(spi_miso),
        .spi_cs_n(spi_cs_n),
        .i2c_scl_o(i2c_scl_o),
        .i2c_sda_o(i2c_sda_o),
        .i2c_scl_i(i2c_scl_i),
        .i2c_sda_i(i2c_sda_i),
        
        .pipe_tx_data(pipe_tx_data),
        .pipe_tx_datak(pipe_tx_datak),
        .pipe_rx_data(pipe_rx_data),
        .pipe_rx_datak(pipe_rx_datak)
    );

    // 4. DDR4 Behavioral Stub
    ddr4_behavioral_stub i_ddr4_mem (
        .ck_p(ddr4_ck_p), .ck_n(ddr4_ck_n), .cke(ddr4_cke),
        .cs_n(ddr4_cs_n), .ras_n(ddr4_ras_n), .cas_n(ddr4_cas_n), .we_n(ddr4_we_n),
        .bg(ddr4_bg), .ba(ddr4_ba), .a(ddr4_a),
        .dq(ddr4_dq), .dqs_p(ddr4_dqs_p), .dqs_n(ddr4_dqs_n), .dm(ddr4_dm)
    );

    // 5. Start UVM Test
    initial begin
        // Pass virtual interfaces to config DB here later if needed
        run_test("soc_base_test");
    end

    // 6. Waveform Dumping (NCSIM/XCELIUM)
    initial begin
        $shm_open("waves.shm");
        $shm_probe("ACMT");
    end

endmodule
