`timescale 1ns/1ps
module axi_to_apb_bridge #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // AXI-Lite Slave Interface
    input  logic                  s_axi_awvalid,
    input  logic [ADDR_WIDTH-1:0] s_axi_awaddr,
    output logic                  s_axi_awready,
    
    input  logic                  s_axi_wvalid,
    input  logic [DATA_WIDTH-1:0] s_axi_wdata,
    input  logic [3:0]            s_axi_wstrb,
    output logic                  s_axi_wready,
    
    output logic                  s_axi_bvalid,
    output logic [1:0]            s_axi_bresp,
    input  logic                  s_axi_bready,
    
    input  logic                  s_axi_arvalid,
    input  logic [ADDR_WIDTH-1:0] s_axi_araddr,
    output logic                  s_axi_arready,
    
    output logic                  s_axi_rvalid,
    output logic [DATA_WIDTH-1:0] s_axi_rdata,
    output logic [1:0]            s_axi_rresp,
    input  logic                  s_axi_rready,
    
    // APB Master Interface
    output logic [ADDR_WIDTH-1:0] m_apb_paddr,
    output logic                  m_apb_psel,
    output logic                  m_apb_penable,
    output logic                  m_apb_pwrite,
    output logic [DATA_WIDTH-1:0] m_apb_pwdata,
    input  logic                  m_apb_pready,
    input  logic [DATA_WIDTH-1:0] m_apb_prdata,
    input  logic                  m_apb_pslverr
);

    typedef enum logic [2:0] {
        IDLE,
        READ_SETUP,
        READ_ACCESS,
        WRITE_SETUP,
        WRITE_ACCESS,
        RESP
    } apb_state_t;
    
    apb_state_t state, next_state;
    
    // Registers to latch AXI requests
    logic [ADDR_WIDTH-1:0] r_addr;
    logic [DATA_WIDTH-1:0] r_wdata;
    logic r_is_write;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            r_addr <= '0;
            r_wdata <= '0;
            r_is_write <= 1'b0;
        end else begin
            state <= next_state;
            
            if (state == IDLE) begin
                if (s_axi_arvalid) begin
                    r_addr <= s_axi_araddr;
                    r_is_write <= 1'b0;
                end else if (s_axi_awvalid && s_axi_wvalid) begin
                    r_addr <= s_axi_awaddr;
                    r_wdata <= s_axi_wdata;
                    r_is_write <= 1'b1;
                end
            end
        end
    end
    
    always_comb begin
        next_state = state;
        s_axi_awready = 1'b0;
        s_axi_wready  = 1'b0;
        s_axi_arready = 1'b0;
        s_axi_bvalid  = 1'b0;
        s_axi_rvalid  = 1'b0;
        
        m_apb_psel    = 1'b0;
        m_apb_penable = 1'b0;
        
        // APB continuous assignments
        m_apb_paddr  = r_addr;
        m_apb_pwdata = r_wdata;
        m_apb_pwrite = r_is_write;
        s_axi_bresp  = m_apb_pslverr ? 2'b10 : 2'b00; // SLVERR or OKAY
        s_axi_rresp  = m_apb_pslverr ? 2'b10 : 2'b00;
        s_axi_rdata  = m_apb_prdata;
        
        case (state)
            IDLE: begin
                if (s_axi_arvalid) begin
                    s_axi_arready = 1'b1;
                    next_state = READ_SETUP;
                end else if (s_axi_awvalid && s_axi_wvalid) begin
                    s_axi_awready = 1'b1;
                    s_axi_wready  = 1'b1;
                    next_state = WRITE_SETUP;
                end
            end
            
            READ_SETUP: begin
                m_apb_psel = 1'b1;
                next_state = READ_ACCESS;
            end
            
            READ_ACCESS: begin
                m_apb_psel = 1'b1;
                m_apb_penable = 1'b1;
                if (m_apb_pready) begin
                    next_state = RESP;
                end
            end
            
            WRITE_SETUP: begin
                m_apb_psel = 1'b1;
                next_state = WRITE_ACCESS;
            end
            
            WRITE_ACCESS: begin
                m_apb_psel = 1'b1;
                m_apb_penable = 1'b1;
                if (m_apb_pready) begin
                    next_state = RESP;
                end
            end
            
            RESP: begin
                if (r_is_write) begin
                    s_axi_bvalid = 1'b1;
                    if (s_axi_bready) next_state = IDLE;
                end else begin
                    s_axi_rvalid = 1'b1;
                    if (s_axi_rready) next_state = IDLE;
                end
            end
            
            default: next_state = IDLE;
        endcase
    end

endmodule
