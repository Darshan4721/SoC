`timescale 1ns/1ps
module plic_interrupt_controller #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter NUM_SOURCES = 32 // 32 peripheral interrupt sources
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
    
    // Incoming IRQs from peripherals
    input  logic [NUM_SOURCES-1:0] irq_sources,
    
    // Out to Core
    output logic                  meip // Machine External Interrupt Pending
);

    // PLIC (Platform-Level Interrupt Controller)
    // Aggregates, masks, and priorities interrupts.
    // Structural simplification: A single 32-bit Enable Register and a 32-bit Pending Register.
    
    logic [NUM_SOURCES-1:0] enable_reg;
    logic [NUM_SOURCES-1:0] pending_reg;
    
    assign pready = 1'b1;
    assign pslverr = 1'b0;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            enable_reg <= '0;
            pending_reg <= '0;
        end else begin
            // Latch incoming edge/level interrupts
            pending_reg <= pending_reg | irq_sources;
            
            // APB Write
            if (psel && penable && pwrite) begin
                if (paddr[7:0] == 8'h00) begin
                    enable_reg <= pwdata;
                end else if (paddr[7:0] == 8'h04) begin
                    // Write 1 to clear pending
                    pending_reg <= pending_reg & ~pwdata;
                end
            end
        end
    end
    
    always_comb begin
        prdata = '0;
        if (psel && !pwrite) begin
            if (paddr[7:0] == 8'h00) prdata = enable_reg;
            if (paddr[7:0] == 8'h04) prdata = pending_reg;
        end
    end
    
    // Fire meip if any enabled interrupt is pending
    assign meip = |(pending_reg & enable_reg);

endmodule
