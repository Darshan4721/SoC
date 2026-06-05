`timescale 1ns/1ps

module handshake_synchronizer #(
    parameter DATA_WIDTH = 32
) (
    input  logic                  clk_src,
    input  logic                  rst_src_n,
    input  logic                  req_in,
    output logic                  ack_out,
    input  logic [DATA_WIDTH-1:0] data_in,
    
    input  logic                  clk_dest,
    input  logic                  rst_dest_n,
    output logic                  req_out,
    input  logic                  ack_in,
    output logic [DATA_WIDTH-1:0] data_out
);
    logic req_sync1, req_sync2;
    logic ack_sync1, ack_sync2;
    logic [DATA_WIDTH-1:0] data_reg;
    
    // Source Domain
    always_ff @(posedge clk_src or negedge rst_src_n) begin
        if (!rst_src_n) begin
            ack_sync1 <= 1'b0;
            ack_sync2 <= 1'b0;
            ack_out   <= 1'b0;
            data_reg  <= '0;
        end else begin
            ack_sync1 <= ack_in;
            ack_sync2 <= ack_sync1;
            ack_out   <= ack_sync2;
            if (req_in && !ack_out) data_reg <= data_in;
        end
    end
    
    // Dest Domain
    always_ff @(posedge clk_dest or negedge rst_dest_n) begin
        if (!rst_dest_n) begin
            req_sync1 <= 1'b0;
            req_sync2 <= 1'b0;
            req_out   <= 1'b0;
            data_out  <= '0;
        end else begin
            req_sync1 <= req_in;
            req_sync2 <= req_sync1;
            req_out   <= req_sync2;
            if (req_sync2 && !ack_in) data_out <= data_reg;
        end
    end
endmodule
