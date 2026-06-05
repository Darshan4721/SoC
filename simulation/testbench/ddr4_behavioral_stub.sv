`timescale 1ns/1ps
module ddr4_behavioral_stub (
    input  logic        ck_p,
    input  logic        ck_n,
    input  logic        cke,
    input  logic        cs_n,
    input  logic        ras_n,
    input  logic        cas_n,
    input  logic        we_n,
    input  logic [1:0]  bg,
    input  logic [1:0]  ba,
    input  logic [13:0] a,
    inout  wire  [63:0] dq,
    inout  wire  [7:0]  dqs_p,
    inout  wire  [7:0]  dqs_n,
    input  logic [7:0]  dm
);

    // This is a highly simplified behavioral stub for DDR4.
    // Its sole purpose is to acknowledge basic commands so the internal 
    // memory controller doesn't hang in initialization loops, and to 
    // prevent X-propagation back into the SoC data lines.
    
    // In a real verification environment, this would be replaced by 
    // a Cadence/Synopsys DDR4 VIP or a Micron memory model.
    
    logic [63:0] read_data_reg;
    logic drive_dq;
    
    assign dq = drive_dq ? read_data_reg : 'z;
    
    // Very simple command decoder
    logic cmd_act, cmd_read, cmd_write, cmd_pre;
    assign cmd_act   = !cs_n && !ras_n &&  cas_n &&  we_n;
    assign cmd_read  = !cs_n &&  ras_n && !cas_n &&  we_n;
    assign cmd_write = !cs_n &&  ras_n && !cas_n && !we_n;
    assign cmd_pre   = !cs_n && !ras_n &&  cas_n && !we_n;
    
    // Mock memory array (only a tiny portion)
    logic [63:0] mem [0:255];
    
    initial begin
        // Initialize memory with dummy instructions (NOPs or simple Jumps)
        // RISC-V NOP: addi x0, x0, 0 (0x00000013)
        for (int i=0; i<256; i++) begin
            mem[i] = {32'h00000013, 32'h00000013};
        end
    end
    
    always @(posedge ck_p) begin
        drive_dq <= 1'b0; // Default to High-Z
        if (cmd_read) begin
            // Simplified Read: Data appears after fixed latency
            // Not modeling full DQS strobes for the stub
            drive_dq <= #10 1'b1;
            read_data_reg <= #10 mem[a[7:0]]; 
        end
        if (cmd_write) begin
            // Simplified Write
            mem[a[7:0]] <= dq;
        end
    end

endmodule
