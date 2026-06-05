`timescale 1ns/1ps

module skid_buffer #(
    parameter DATA_WIDTH = 32
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    input  logic                  s_valid,
    output logic                  s_ready,
    input  logic [DATA_WIDTH-1:0] s_data,
    
    output logic                  m_valid,
    input  logic                  m_ready,
    output logic [DATA_WIDTH-1:0] m_data
);
    logic [DATA_WIDTH-1:0] skid_data;
    logic                  skid_valid;
    
    assign s_ready = !skid_valid;
    assign m_valid = s_valid || skid_valid;
    assign m_data  = skid_valid ? skid_data : s_data;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            skid_valid <= 1'b0;
            skid_data  <= '0;
        end else begin
            if (s_valid && s_ready && !m_ready) begin
                skid_valid <= 1'b1;
                skid_data  <= s_data;
            end else if (m_ready) begin
                skid_valid <= 1'b0;
            end
        end
    end
endmodule
