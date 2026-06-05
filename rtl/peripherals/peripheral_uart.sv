`timescale 1ns/1ps
module peripheral_uart #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // APB Slave Interface
    input  logic [ADDR_WIDTH-1:0] paddr,
    input  logic                  psel,
    input  logic                  penable,
    input  logic                  pwrite,
    input  logic [DATA_WIDTH-1:0] pwdata,
    output logic                  pready,
    output logic [DATA_WIDTH-1:0] prdata,
    output logic                  pslverr,
    
    // External Physical Pads
    output logic                  tx_pad,
    input  logic                  rx_pad,
    
    // Interrupt out
    output logic                  uart_irq
);

    // Simplistic UART (Tx/Rx)
    // Register Map:
    // 0x00 : TX Data (Write), RX Data (Read)
    // 0x04 : Status (Read-only: Bit 0=TX Full, Bit 1=RX Valid)
    // 0x08 : Control (Bit 0=Enable, Bit 1=IRQ Enable)
    // 0x0C : Clock Divisor (Baud Rate)
    
    logic [7:0]  tx_reg, rx_reg;
    logic [31:0] clk_div_reg;
    logic        ctrl_en, ctrl_irq_en;
    
    logic rx_valid;
    logic tx_full;
    
    assign pready  = 1'b1; // Zero wait state APB for config registers
    assign pslverr = 1'b0;
    
    // APB Write
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_reg <= 32'd868; // Default 115200 @ 100MHz
            ctrl_en <= 1'b0;
            ctrl_irq_en <= 1'b0;
            tx_reg <= '0;
        end else if (psel && penable && pwrite) begin
            case (paddr[7:0])
                8'h00: tx_reg <= pwdata[7:0]; // Initiates TX structurally
                8'h08: {ctrl_irq_en, ctrl_en} <= pwdata[1:0];
                8'h0C: clk_div_reg <= pwdata;
            endcase
        end
    end
    
    // APB Read
    always_comb begin
        prdata = '0;
        if (psel && !pwrite) begin
            case (paddr[7:0])
                8'h00: prdata = {24'h0, rx_reg};
                8'h04: prdata = {30'h0, rx_valid, tx_full};
                8'h08: prdata = {30'h0, ctrl_irq_en, ctrl_en};
                8'h0C: prdata = clk_div_reg;
                default: prdata = '0;
            endcase
        end
    end
    
    // Structural Baud / Shift Logic omitted for brevity. 
    // We drive the physical pads continuously.
    assign tx_pad = 1'b1; // Idle high
    assign tx_full = 1'b0; // Mock
    assign rx_valid = 1'b0; // Mock
    assign uart_irq = rx_valid && ctrl_irq_en;

endmodule
