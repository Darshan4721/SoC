`timescale 1ns/1ps
module gpu_rop_pipeline #(
    parameter PIX_WIDTH = 64,
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Interface from Shader Core (Pixels)
    input  logic                  pixel_tvalid,
    input  logic [PIX_WIDTH-1:0]  pixel_tdata, // X, Y, Z, RGBA
    output logic                  pixel_tready,
    
    // Frame Buffer Base Address
    input  logic [ADDR_WIDTH-1:0] fb_base_addr,
    
    // AXI Master Interface (To Frame Buffer in DDR)
    output logic                  m_axi_awvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_awaddr,
    input  logic                  m_axi_awready,
    
    output logic                  m_axi_wvalid,
    output logic [DATA_WIDTH-1:0] m_axi_wdata,
    input  logic                  m_axi_wready
);

    // Raster Operations Pipeline (ROP)
    // Applies Depth Testing (Z-Buffer) and Alpha Blending.
    // For this structural representation, we bypass Z-testing and perform direct AXI writes
    // by packing 4x 64-bit pixels into a 256-bit AXI Write burst.
    
    logic [1:0] pack_cnt;
    logic [DATA_WIDTH-1:0] pack_buffer;
    
    typedef enum logic [1:0] {
        STATE_GATHER,
        STATE_AW,
        STATE_W
    } rop_state_t;
    
    rop_state_t state;
    
    assign pixel_tready = (state == STATE_GATHER);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_GATHER;
            pack_cnt <= '0;
            pack_buffer <= '0;
            m_axi_awvalid <= 1'b0;
            m_axi_wvalid <= 1'b0;
        end else begin
            case (state)
                STATE_GATHER: begin
                    if (pixel_tvalid && pixel_tready) begin
                        pack_buffer[pack_cnt * PIX_WIDTH +: PIX_WIDTH] <= pixel_tdata;
                        if (pack_cnt == 2'b11) begin // Gathered 4 pixels
                            pack_cnt <= '0;
                            m_axi_awvalid <= 1'b1;
                            // Calculate address based on X,Y (mock)
                            m_axi_awaddr <= fb_base_addr + {48'h0, pixel_tdata[31:16]}; 
                            state <= STATE_AW;
                        end else begin
                            pack_cnt <= pack_cnt + 1'b1;
                        end
                    end
                end
                STATE_AW: begin
                    if (m_axi_awready) begin
                        m_axi_awvalid <= 1'b0;
                        m_axi_wvalid <= 1'b1;
                        m_axi_wdata <= pack_buffer;
                        state <= STATE_W;
                    end
                end
                STATE_W: begin
                    if (m_axi_wready) begin
                        m_axi_wvalid <= 1'b0;
                        state <= STATE_GATHER; // Done writing, gather more pixels
                    end
                end
            endcase
        end
    end

endmodule
