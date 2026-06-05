`timescale 1ns/1ps
module vector_gather_scatter_unit #(
    parameter ADDR_WIDTH = 64,
    parameter VLEN = 512,
    parameter ELEM_WIDTH = 32 // Assuming 32-bit elements
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Command Interface
    input  logic                  cmd_val,
    input  logic                  is_scatter, // 1 = scatter (store), 0 = gather (load)
    input  logic [ADDR_WIDTH-1:0] base_addr,
    input  logic [VLEN-1:0]       index_vector, // vs2: Array of offsets
    input  logic [VLEN-1:0]       data_vector,  // vs1: Data to store (scatter)
    input  logic [VLEN/8-1:0]     mask_vector,  // v0: Byte masking
    output logic                  cmd_ready,
    
    // Memory Interface (To NoC / L2 Cache / DDR Arbiter)
    output logic                  mem_req_val,
    output logic                  mem_is_store,
    output logic [ADDR_WIDTH-1:0] mem_addr,
    output logic [ELEM_WIDTH-1:0] mem_wdata,
    input  logic                  mem_req_rdy,
    
    input  logic                  mem_rsp_val,
    input  logic [ELEM_WIDTH-1:0] mem_rdata,
    
    // Writeback Interface (To Vector Regfile)
    output logic                  wb_val,
    output logic [VLEN-1:0]       wb_data,
    input  logic                  wb_ready
);

    localparam ELEMS = VLEN / ELEM_WIDTH; // 16 elements
    
    typedef enum logic [1:0] {
        STATE_IDLE,
        STATE_REQ,
        STATE_WAIT_RSP
    } gs_state_t;
    
    gs_state_t current_state, next_state;
    
    logic [$clog2(ELEMS):0] current_elem;
    logic [VLEN-1:0] gathered_data;
    
    // Check if current element is masked out. Mask vector is byte-addressable.
    // Assuming 32-bit elements, we check the lowest byte of the mask for that element.
    logic is_masked;
    assign is_masked = ~mask_vector[current_elem * 4];
    
    assign cmd_ready = (current_state == STATE_IDLE);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= STATE_IDLE;
            current_elem  <= '0;
            gathered_data <= '0;
            wb_val        <= 1'b0;
            wb_data       <= '0;
        end else begin
            current_state <= next_state;
            
            // Default de-assert writeback unless completed
            if (wb_ready) wb_val <= 1'b0;
            
            case (current_state)
                STATE_IDLE: begin
                    if (cmd_val) begin
                        current_elem <= '0;
                        gathered_data <= '0;
                    end
                end
                
                STATE_REQ: begin
                    if (is_masked) begin
                        // Skip masked elements instantly
                        if (current_elem == ELEMS - 1) begin
                            if (!is_scatter) begin
                                wb_val <= 1'b1;
                                wb_data <= gathered_data;
                            end
                        end
                        current_elem <= current_elem + 1'b1;
                    end else if (mem_req_val && mem_req_rdy) begin
                        if (is_scatter) begin
                            // Scatter doesn't wait for read response per se
                            if (current_elem == ELEMS - 1) begin
                                // Done
                            end else begin
                                current_elem <= current_elem + 1'b1;
                            end
                        end
                    end
                end
                
                STATE_WAIT_RSP: begin
                    if (mem_rsp_val) begin
                        gathered_data[current_elem * ELEM_WIDTH +: ELEM_WIDTH] <= mem_rdata;
                        if (current_elem == ELEMS - 1) begin
                            wb_val <= 1'b1;
                            wb_data <= gathered_data | (mem_rdata << (current_elem * ELEM_WIDTH));
                        end else begin
                            current_elem <= current_elem + 1'b1;
                        end
                    end
                end
            endcase
        end
    end
    
    // Comb FSM Outputs
    always_comb begin
        next_state = current_state;
        mem_req_val = 1'b0;
        mem_is_store = is_scatter;
        
        // Element index extraction
        mem_addr  = base_addr + index_vector[current_elem * ELEM_WIDTH +: ELEM_WIDTH];
        mem_wdata = data_vector[current_elem * ELEM_WIDTH +: ELEM_WIDTH];
        
        case (current_state)
            STATE_IDLE: begin
                if (cmd_val) next_state = STATE_REQ;
            end
            STATE_REQ: begin
                if (current_elem == ELEMS) begin
                    next_state = STATE_IDLE;
                end else if (!is_masked) begin
                    mem_req_val = 1'b1;
                    if (mem_req_rdy) begin
                        if (is_scatter) begin
                            if (current_elem == ELEMS - 1) next_state = STATE_IDLE;
                        end else begin
                            next_state = STATE_WAIT_RSP;
                        end
                    end
                end
            end
            STATE_WAIT_RSP: begin
                if (mem_rsp_val) begin
                    if (current_elem == ELEMS - 1) next_state = STATE_IDLE;
                    else next_state = STATE_REQ;
                end
            end
        endcase
    end

endmodule
