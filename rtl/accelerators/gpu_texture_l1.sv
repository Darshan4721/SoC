`timescale 1ns/1ps
module gpu_texture_l1 #(
    parameter CACHE_SIZE = 4096, // 4KB texture cache
    parameter LINE_SIZE = 256    // 256-bit cache line
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Interface from Shader Core
    input  logic                  tex_req_val,
    input  logic [31:0]           tex_req_uv,
    output logic                  tex_req_rdy,
    output logic                  tex_rsp_val,
    output logic [31:0]           tex_rsp_color,
    
    // AXI Master to DDR Arbiter (Miss Handling)
    output logic                  m_axi_arvalid,
    output logic [63:0]           m_axi_araddr,
    input  logic                  m_axi_arready,
    input  logic                  m_axi_rvalid,
    input  logic [LINE_SIZE-1:0]  m_axi_rdata,
    output logic                  m_axi_rready
);

    // Simplified Direct-Mapped Texture Cache
    localparam LINES = CACHE_SIZE / (LINE_SIZE/8);
    
    logic [LINE_SIZE-1:0] cache_data [0:LINES-1];
    logic [43:0]          cache_tags [0:LINES-1];
    logic                 cache_valid[0:LINES-1];
    
    logic [$clog2(LINES)-1:0] index;
    logic [43:0] tag;
    
    assign index = tex_req_uv[$clog2(LINES)-1:0];
    assign tag   = tex_req_uv[31:32-44]; // Simplified tag from UV hash
    
    logic hit;
    assign hit = cache_valid[index] && (cache_tags[index] == tag);
    
    typedef enum logic {
        STATE_IDLE,
        STATE_MISS
    } tex_state_t;
    
    tex_state_t state;
    
    assign tex_req_rdy = (state == STATE_IDLE) && hit;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
            tex_rsp_val <= 1'b0;
            tex_rsp_color <= '0;
            m_axi_arvalid <= 1'b0;
            m_axi_rready <= 1'b0;
            for (int i=0; i<LINES; i++) cache_valid[i] <= 1'b0;
        end else begin
            tex_rsp_val <= 1'b0;
            
            case (state)
                STATE_IDLE: begin
                    if (tex_req_val) begin
                        if (hit) begin
                            tex_rsp_val <= 1'b1;
                            tex_rsp_color <= cache_data[index][31:0]; // Simplified pixel extraction
                        end else begin
                            m_axi_arvalid <= 1'b1;
                            m_axi_araddr <= {tag, index, 5'b0}; // Reconstruct physical addr
                            state <= STATE_MISS;
                        end
                    end
                end
                STATE_MISS: begin
                    if (m_axi_arready) m_axi_arvalid <= 1'b0; // Address accepted
                    
                    m_axi_rready <= 1'b1;
                    if (m_axi_rvalid) begin
                        m_axi_rready <= 1'b0;
                        cache_valid[index] <= 1'b1;
                        cache_tags[index] <= tag;
                        cache_data[index] <= m_axi_rdata;
                        
                        tex_rsp_val <= 1'b1;
                        tex_rsp_color <= m_axi_rdata[31:0]; // Provide the bypassed data
                        state <= STATE_IDLE;
                    end
                end
            endcase
        end
    end

endmodule
