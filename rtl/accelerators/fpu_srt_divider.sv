`timescale 1ns/1ps
module fpu_srt_divider #(
    parameter DATA_WIDTH = 64
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Issue Interface
    input  logic                  issue_val,
    input  logic [31:0]           opcode,
    input  logic [DATA_WIDTH-1:0] fs1_data, // Dividend
    input  logic [DATA_WIDTH-1:0] fs2_data, // Divisor
    output logic                  issue_ready,
    
    // Result Interface
    output logic                  res_val,
    output logic [DATA_WIDTH-1:0] res_data,
    output logic [4:0]            fflags,
    input  logic                  res_ready
);

    // Iterative SRT Radix-4 Divider
    // Computes 2 bits of quotient per clock cycle.
    // For 53-bit mantissa (DP), requires ~28 cycles.
    
    typedef enum logic [1:0] {
        STATE_IDLE,
        STATE_DIVIDE,
        STATE_NORMALIZE
    } div_state_t;
    
    div_state_t current_state, next_state;
    
    logic [5:0] iter_count;
    logic [DATA_WIDTH-1:0] q_reg;
    
    assign issue_ready = (current_state == STATE_IDLE);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= STATE_IDLE;
            iter_count <= '0;
            res_val <= 1'b0;
            q_reg <= '0;
            fflags <= '0;
        end else begin
            current_state <= next_state;
            
            // Clear result valid if handshaked
            if (res_val && res_ready) res_val <= 1'b0;
            
            case (current_state)
                STATE_IDLE: begin
                    if (issue_val && issue_ready) begin
                        iter_count <= 6'd28; // 28 iterations for Radix-4 DP
                        // Simulated extraction
                        q_reg <= fs1_data ^ fs2_data; // Mock seeding
                    end
                end
                
                STATE_DIVIDE: begin
                    iter_count <= iter_count - 1'b1;
                    // Mock SRT iterative step
                    q_reg <= {q_reg[DATA_WIDTH-3:0], 2'b01}; 
                end
                
                STATE_NORMALIZE: begin
                    res_val <= 1'b1;
                    res_data <= q_reg; // Final quotient
                    fflags <= 5'b00000;
                end
            endcase
        end
    end
    
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            STATE_IDLE: begin
                if (issue_val && issue_ready) next_state = STATE_DIVIDE;
            end
            STATE_DIVIDE: begin
                if (iter_count == 0) next_state = STATE_NORMALIZE;
            end
            STATE_NORMALIZE: begin
                if (res_ready) next_state = STATE_IDLE;
            end
            default: next_state = STATE_IDLE;
        endcase
    end

endmodule
