`timescale 1ns/1ps
module peripheral_timer #(
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
    
    // RV64 Machine Timer Interrupts
    output logic                  mtime_irq
);

    // RISC-V CLINT compliant mtime and mtimecmp registers (64-bit)
    // APB is 32-bit, so they are accessed in two 32-bit halves.
    // 0x00: mtime_lo
    // 0x04: mtime_hi
    // 0x08: mtimecmp_lo
    // 0x0C: mtimecmp_hi
    
    logic [63:0] mtime;
    logic [63:0] mtimecmp;
    
    assign pready = 1'b1;
    assign pslverr = 1'b0;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mtime <= 64'h0;
            mtimecmp <= 64'hFFFF_FFFF_FFFF_FFFF;
        end else begin
            // Timer increments every clock (or via divided pre-scaler)
            mtime <= mtime + 1'b1;
            
            // APB Write
            if (psel && penable && pwrite) begin
                case (paddr[7:0])
                    8'h00: mtime[31:0]  <= pwdata;
                    8'h04: mtime[63:32] <= pwdata;
                    8'h08: mtimecmp[31:0]  <= pwdata;
                    8'h0C: mtimecmp[63:32] <= pwdata;
                endcase
            end
        end
    end
    
    always_comb begin
        prdata = '0;
        if (psel && !pwrite) begin
            case (paddr[7:0])
                8'h00: prdata = mtime[31:0];
                8'h04: prdata = mtime[63:32];
                8'h08: prdata = mtimecmp[31:0];
                8'h0C: prdata = mtimecmp[63:32];
            endcase
        end
    end
    
    assign mtime_irq = (mtime >= mtimecmp);

endmodule
