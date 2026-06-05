`timescale 1ns/1ps
module mesi_coherency_directory #(
    parameter ADDR_WIDTH = 64
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // NoC/Bus Monitor Interface
    input  logic                  bus_write_req,
    input  logic [ADDR_WIDTH-1:0] bus_addr,
    
    // Core Snoop Interface
    output logic                  snoop_req,
    input  logic                  snoop_ack,
    output logic                  grant_access
);

    typedef enum logic [1:0] {
        STATE_IDLE,
        STATE_SNOOP_BROADCAST,
        STATE_WAIT_ACK
    } directory_state_t;
    
    directory_state_t current_state, next_state;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) current_state <= STATE_IDLE;
        else        current_state <= next_state;
    end
    
    always_comb begin
        next_state = current_state;
        snoop_req = 1'b0;
        grant_access = 1'b0;
        
        case (current_state)
            STATE_IDLE: begin
                // Monitor bus for exclusive write requests to shared cache lines
                if (bus_write_req) begin
                    next_state = STATE_SNOOP_BROADCAST;
                end else begin
                    grant_access = 1'b1; // Bus is free
                end
            end
            
            STATE_SNOOP_BROADCAST: begin
                snoop_req = 1'b1;
                next_state = STATE_WAIT_ACK;
            end
            
            STATE_WAIT_ACK: begin
                snoop_req = 1'b1;
                // Wait for all remote L2 caches to invalidate or writeback
                if (snoop_ack) begin
                    grant_access = 1'b1;
                    next_state = STATE_IDLE;
                end
            end
            
            default: next_state = STATE_IDLE;
        endcase
    end

endmodule
