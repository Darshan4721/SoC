`timescale 1ns/1ps
module fpu_fma_pipeline #(
    parameter DATA_WIDTH = 64 // Double precision IEEE-754
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Issue Interface
    input  logic                  issue_val,
    input  logic [31:0]           opcode,
    input  logic [DATA_WIDTH-1:0] fs1_data, // A
    input  logic [DATA_WIDTH-1:0] fs2_data, // B
    input  logic [DATA_WIDTH-1:0] fs3_data, // C
    output logic                  issue_ready,
    
    // Result Interface
    output logic                  res_val,
    output logic [DATA_WIDTH-1:0] res_data,
    output logic [4:0]            fflags, // IEEE Exception flags: NV, DZ, OF, UF, NX
    input  logic                  res_ready
);

    // =========================================================================
    // FPU FMA PIPELINE
    // Instantiates the structural fp64 and fp32 primitives based on BOM
    // =========================================================================

    logic [63:0] mac64_out;
    logic [31:0] mac32_out;
    
    // Check if the opcode requests a 32-bit (Single) or 64-bit (Double) operation
    // Simplified decode: RV64F/D uses bits 26:25 to denote precision (e.g., 00=Single, 01=Double)
    logic is_double;
    assign is_double = (opcode[26:25] == 2'b01);
    
    // Stall/Backpressure logic
    // FMA IP cores are typically fixed latency. We use a shift register for the valid signal.
    // Assuming 4-cycle latency based on the primitive definitions.
    logic [3:0] valid_shift;
    logic [3:0] is_double_shift; // Track precision through the pipeline
    
    logic stall;
    assign stall = res_val && !res_ready;
    assign issue_ready = !stall;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_shift <= '0;
            is_double_shift <= '0;
            fflags <= '0;
        end else if (!stall) begin
            valid_shift <= {valid_shift[2:0], issue_val};
            is_double_shift <= {is_double_shift[2:0], is_double};
        end
    end
    
    assign res_val = valid_shift[3];
    assign res_data = is_double_shift[3] ? mac64_out : {32'h0, mac32_out};

    // 1. FP64 Fused MAC (Double Precision)
    fp64_fused_mac i_fp64_mac (
        .clk(clk),
        .rst_n(rst_n),
        .a(fs1_data),
        .b(fs2_data),
        .c(fs3_data),
        .out(mac64_out)
    );

    // 2. FP32 Fused MAC (Single Precision)
    fp32_fused_mac i_fp32_mac (
        .clk(clk),
        .rst_n(rst_n),
        .a(fs1_data[31:0]),
        .b(fs2_data[31:0]),
        .c(fs3_data[31:0]),
        .out(mac32_out)
    );

endmodule
