`timescale 1ns/1ps
module peripheral_spi #(
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
    output logic                  spi_sck,
    output logic                  spi_mosi,
    input  logic                  spi_miso,
    output logic                  spi_cs_n,
    
    // Interrupt out
    output logic                  spi_irq
);

    // Simplified SPI Master
    // 0x00: TX/RX Data
    // 0x04: Status (Bit 0: Busy)
    // 0x08: Control (Bit 0: Enable, Bit 1: CS, Bit[15:8]: Divisor)
    
    logic [7:0]  ctrl_div;
    logic        ctrl_en, ctrl_cs;
    logic        busy;
    
    assign pready = 1'b1;
    assign pslverr = 1'b0;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ctrl_div <= '0;
            ctrl_en <= 1'b0;
            ctrl_cs <= 1'b1; // Active low default to 1
        end else if (psel && penable && pwrite) begin
            if (paddr[7:0] == 8'h08) begin
                ctrl_en <= pwdata[0];
                ctrl_cs <= pwdata[1];
                ctrl_div <= pwdata[15:8];
            end
        end
    end
    
    always_comb begin
        prdata = '0;
        if (psel && !pwrite) begin
            case (paddr[7:0])
                8'h00: prdata = 32'h0; // Read RX mock
                8'h04: prdata = {31'h0, busy};
                8'h08: prdata = {16'h0, ctrl_div, 6'h0, ctrl_cs, ctrl_en};
            endcase
        end
    end
    
    assign spi_cs_n = ctrl_cs;
    assign spi_sck  = 1'b0; // Clock gate off
    assign spi_mosi = 1'b0;
    assign spi_irq  = 1'b0;
    assign busy     = 1'b0;

endmodule
