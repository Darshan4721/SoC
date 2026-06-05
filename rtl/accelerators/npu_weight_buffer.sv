`timescale 1ns/1ps
module npu_weight_buffer #(
    parameter DATA_WIDTH = 256,
    parameter DEPTH = 1024 // Large local SRAM for weights
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // AXI-Stream Write Interface (From DMA Controller)
    input  logic                  s_axis_tvalid,
    input  logic [DATA_WIDTH-1:0] s_axis_tdata,
    output logic                  s_axis_tready,
    
    // Read Interface (To Systolic Array)
    input  logic                  read_req,
    input  logic [$clog2(DEPTH)-1:0] read_addr,
    output logic [DATA_WIDTH-1:0] read_data
);

    // Deep SRAM array for storing NN Weights
    logic [DATA_WIDTH-1:0] weight_ram [0:DEPTH-1];
    
    logic [$clog2(DEPTH)-1:0] write_ptr;
    
    assign s_axis_tready = (write_ptr < DEPTH); // Ready until buffer fills up
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_ptr <= '0;
        end else begin
            if (s_axis_tvalid && s_axis_tready) begin
                weight_ram[write_ptr] <= s_axis_tdata;
                write_ptr <= write_ptr + 1'b1;
            end
            
            // Allow wrap-around reset for continuous streaming batches
            // (Normally controlled by an AXI-Lite command register, simplified here)
            if (write_ptr == DEPTH && !s_axis_tvalid) begin
                write_ptr <= '0;
            end
        end
    end
    
    // Read Port (Synchronous read)
    always_ff @(posedge clk) begin
        if (read_req) begin
            read_data <= weight_ram[read_addr];
        end
    end

endmodule
