`timescale 1ns/1ps
module npu_dma_controller #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // AXI-Lite Control (From Core)
    input  logic                  ctrl_start,
    input  logic [ADDR_WIDTH-1:0] ctrl_src_addr,
    input  logic [ADDR_WIDTH-1:0] ctrl_dst_addr,
    input  logic [31:0]           ctrl_transfer_len,
    output logic                  ctrl_done,
    
    // AXI-Full Master to Memory Arbiter
    output logic                  m_axi_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_araddr,
    output logic [7:0]            m_axi_arlen, // Burst length
    input  logic                  m_axi_arready,
    
    input  logic                  m_axi_rvalid,
    input  logic [DATA_WIDTH-1:0] m_axi_rdata,
    input  logic                  m_axi_rlast,
    output logic                  m_axi_rready,
    
    // AXI-Stream Output to NPU (Weight Buffer / Activations)
    output logic                  m_axis_tvalid,
    output logic [DATA_WIDTH-1:0] m_axis_tdata,
    input  logic                  m_axis_tready
);

    typedef enum logic [1:0] {
        STATE_IDLE,
        STATE_REQ_READ,
        STATE_STREAMING
    } dma_state_t;
    
    dma_state_t current_state, next_state;
    
    logic [31:0] remaining_len;
    logic [ADDR_WIDTH-1:0] current_addr;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= STATE_IDLE;
            remaining_len <= '0;
            current_addr  <= '0;
        end else begin
            current_state <= next_state;
            
            // Address and Length Tracking
            if (current_state == STATE_IDLE && ctrl_start) begin
                remaining_len <= ctrl_transfer_len;
                current_addr  <= ctrl_src_addr;
            end else if (current_state == STATE_STREAMING && m_axi_rvalid && m_axis_tready) begin
                remaining_len <= remaining_len - 1'b1;
                current_addr  <= current_addr + (DATA_WIDTH/8); // Byte addressable
            end
        end
    end
    
    assign ctrl_done = (current_state == STATE_IDLE && remaining_len == 0 && !ctrl_start);
    
    always_comb begin
        next_state = current_state;
        m_axi_arvalid = 1'b0;
        m_axis_tvalid = 1'b0;
        m_axi_rready  = 1'b0;
        
        m_axi_araddr = current_addr;
        m_axi_arlen  = 8'hFF; // 256 beats per burst (simplified maximum)
        m_axis_tdata = m_axi_rdata;
        
        case (current_state)
            STATE_IDLE: begin
                if (ctrl_start) begin
                    next_state = STATE_REQ_READ;
                end
            end
            
            STATE_REQ_READ: begin
                m_axi_arvalid = 1'b1;
                // Wait for Arbiter to accept the AXI Read Address channel
                if (m_axi_arready) begin
                    next_state = STATE_STREAMING;
                end
            end
            
            STATE_STREAMING: begin
                // Pass-through AXI read data directly to AXI stream out
                m_axis_tvalid = m_axi_rvalid;
                m_axi_rready  = m_axis_tready;
                
                if (m_axi_rlast && m_axi_rvalid && m_axis_tready) begin
                    if (remaining_len <= 1) begin
                        next_state = STATE_IDLE; // Transfer complete
                    end else begin
                        next_state = STATE_REQ_READ; // Need another burst
                    end
                end
            end
            
            default: next_state = STATE_IDLE;
        endcase
    end

endmodule
