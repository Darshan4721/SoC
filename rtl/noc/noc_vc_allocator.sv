`timescale 1ns/1ps
module noc_vc_allocator #(
    parameter NUM_VCS = 4
) (
    input  logic clk,
    input  logic rst_n,
    
    // Flit Input
    input  logic         req_in,
    input  logic [1:0]   dest_id,
    
    // VC Output
    output logic         grant_out,
    output logic [1:0]   vc_id,
    
    // Flow Control
    input  logic         credit_in,
    output logic         credit_out
);

    typedef enum logic [2:0] {
        STATE_IDLE,
        STATE_VC_REQ,
        STATE_ARBITRATE,
        STATE_VC_GRANT,
        STATE_FLIT_FWD,
        STATE_STALL
    } state_t;
    
    state_t current_state, next_state;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= STATE_IDLE;
        else        current_state <= next_state;
    end
    
    always_comb begin
        next_state = current_state;
        grant_out = 1'b0;
        credit_out = 1'b0;
        vc_id = '0;
        
        case (current_state)
            STATE_IDLE: begin
                if (req_in) next_state = STATE_VC_REQ;
            end
            
            STATE_VC_REQ: begin
                next_state = STATE_ARBITRATE;
            end
            
            STATE_ARBITRATE: begin
                // Round robin arbitration placeholder
                next_state = STATE_VC_GRANT;
            end
            
            STATE_VC_GRANT: begin
                grant_out = 1'b1;
                vc_id = dest_id; // Map dest to VC
                next_state = STATE_FLIT_FWD;
            end
            
            STATE_FLIT_FWD: begin
                credit_out = 1'b1;
                if (!credit_in) next_state = STATE_STALL;
                else if (!req_in) next_state = STATE_IDLE;
            end
            
            STATE_STALL: begin
                // ready=0 equivalent
                if (credit_in) next_state = STATE_FLIT_FWD;
            end
            
            default: next_state = STATE_IDLE;
        endcase
    end

endmodule
