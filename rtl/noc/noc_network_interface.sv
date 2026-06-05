`timescale 1ns/1ps
module noc_network_interface (
    input  logic         clk,
    input  logic         rst_n,
    
    // AXI4-Full Write Channels
    input  logic [63:0]  axi_awaddr,
    input  logic [255:0] axi_wdata,
    input  logic         axi_awvalid,
    input  logic         axi_wvalid,
    output logic         axi_awready,
    output logic         axi_wready,
    
    // NoC Interface
    output logic [255:0] flit_out,
    output logic         flit_out_val,
    input  logic         credit_in
);

    typedef enum logic [1:0] {
        STATE_IDLE,
        STATE_PACK_HEAD,
        STATE_PACK_BODY,
        STATE_WAIT_CREDIT
    } state_t;
    
    state_t current_state, next_state;
    
    // AXI Handshake logic
    assign axi_awready = (current_state == STATE_IDLE) && credit_in;
    assign axi_wready  = (current_state == STATE_PACK_BODY) && credit_in;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= STATE_IDLE;
        end else begin
            current_state <= next_state;
        end
    end
    
    always_comb begin
        next_state = current_state;
        flit_out_val = 1'b0;
        flit_out = '0;
        
        case (current_state)
            STATE_IDLE: begin
                if (axi_awvalid && credit_in) begin
                    flit_out_val = 1'b1;
                    flit_out = {192'd0, axi_awaddr}; // Packetize address into Head Flit
                    if (axi_wvalid) next_state = STATE_PACK_BODY;
                    else next_state = STATE_PACK_BODY;
                end
            end
            
            STATE_PACK_BODY: begin
                if (axi_wvalid && credit_in) begin
                    flit_out_val = 1'b1;
                    flit_out = axi_wdata; // Packetize data into Body Flit
                    next_state = STATE_IDLE;
                end else if (!credit_in) begin
                    next_state = STATE_WAIT_CREDIT;
                end
            end
            
            STATE_WAIT_CREDIT: begin
                if (credit_in) begin
                    next_state = STATE_PACK_BODY;
                end
            end
            
            default: next_state = STATE_IDLE;
        endcase
    end

endmodule
