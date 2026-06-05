`timescale 1ns/1ps
module gpu_cmd_processor #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // AXI-Lite Control (From Core)
    input  logic                  start_render,
    input  logic [ADDR_WIDTH-1:0] cmd_list_base_addr,
    input  logic [31:0]           cmd_list_size,
    output logic                  render_done,
    
    // AXI Master Interface (To Memory for Command Fetching)
    output logic                  m_axi_arvalid,
    output logic [ADDR_WIDTH-1:0] m_axi_araddr,
    output logic [7:0]            m_axi_arlen,
    input  logic                  m_axi_arready,
    
    input  logic                  m_axi_rvalid,
    input  logic [DATA_WIDTH-1:0] m_axi_rdata,
    input  logic                  m_axi_rlast,
    output logic                  m_axi_rready,
    
    // Stream to Geometry Engine
    output logic                  geom_tvalid,
    output logic [DATA_WIDTH-1:0] geom_tdata,
    input  logic                  geom_tready
);

    typedef enum logic [1:0] {
        STATE_IDLE,
        STATE_REQ,
        STATE_FETCH
    } state_t;
    
    state_t current_state, next_state;
    logic [ADDR_WIDTH-1:0] current_addr;
    logic [31:0] bytes_remaining;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= STATE_IDLE;
            current_addr <= '0;
            bytes_remaining <= '0;
        end else begin
            current_state <= next_state;
            if (current_state == STATE_IDLE && start_render) begin
                current_addr <= cmd_list_base_addr;
                bytes_remaining <= cmd_list_size;
            end else if (current_state == STATE_FETCH && m_axi_rvalid && geom_tready) begin
                current_addr <= current_addr + (DATA_WIDTH/8);
                bytes_remaining <= bytes_remaining - (DATA_WIDTH/8);
            end
        end
    end
    
    assign render_done = (current_state == STATE_IDLE && bytes_remaining == 0 && !start_render);
    
    always_comb begin
        next_state = current_state;
        m_axi_arvalid = 1'b0;
        m_axi_rready = 1'b0;
        geom_tvalid = 1'b0;
        
        m_axi_araddr = current_addr;
        m_axi_arlen = 8'h0F; // 16 burst
        geom_tdata = m_axi_rdata;
        
        case (current_state)
            STATE_IDLE: begin
                if (start_render) next_state = STATE_REQ;
            end
            STATE_REQ: begin
                if (bytes_remaining > 0) begin
                    m_axi_arvalid = 1'b1;
                    if (m_axi_arready) next_state = STATE_FETCH;
                end else begin
                    next_state = STATE_IDLE;
                end
            end
            STATE_FETCH: begin
                // Pass directly to geometry engine
                geom_tvalid = m_axi_rvalid;
                m_axi_rready = geom_tready;
                
                if (m_axi_rlast && m_axi_rvalid && geom_tready) begin
                    if (bytes_remaining <= (DATA_WIDTH/8)) next_state = STATE_IDLE;
                    else next_state = STATE_REQ;
                end
            end
        endcase
    end

endmodule
