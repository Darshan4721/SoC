`timescale 1ns/1ps
module gpu_rasterizer #(
    parameter DATA_WIDTH = 256
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // In from Geometry Engine (Transformed Triangles)
    input  logic                  rast_tvalid,
    input  logic [DATA_WIDTH-1:0] rast_tdata,
    output logic                  rast_tready,
    
    // Screen Resolution Limits
    input  logic [15:0]           screen_width,
    input  logic [15:0]           screen_height,
    
    // Out to Shader Core (Pixel Fragments)
    output logic                  frag_tvalid,
    output logic [127:0]          frag_tdata, // X, Y, Z, U, V interpolated
    input  logic                  frag_tready
);

    // Bounding Box and Edge Equation Evaluation
    // This state machine locks onto a triangle and iterates over its bounding box,
    // emitting pixel fragments that pass the edge-function tests.
    
    typedef enum logic [1:0] {
        STATE_FETCH,
        STATE_RASTERIZE
    } rast_state_t;
    
    rast_state_t state;
    
    logic [15:0] current_x, current_y;
    logic [15:0] max_x, max_y;
    
    // Backpressure logic: ready for new triangle when idle/fetching
    assign rast_tready = (state == STATE_FETCH);
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_FETCH;
            current_x <= '0;
            current_y <= '0;
            max_x <= '0;
            max_y <= '0;
            frag_tvalid <= 1'b0;
            frag_tdata <= '0;
        end else begin
            // Clear valid on handshake
            if (frag_tvalid && frag_tready) frag_tvalid <= 1'b0;
            
            case (state)
                STATE_FETCH: begin
                    if (rast_tvalid) begin
                        // Load Triangle Bounding Box (Simulated extraction)
                        current_x <= rast_tdata[15:0];
                        current_y <= rast_tdata[31:16];
                        max_x     <= rast_tdata[47:32];
                        max_y     <= rast_tdata[63:48];
                        state     <= STATE_RASTERIZE;
                    end
                end
                STATE_RASTERIZE: begin
                    if (!frag_tvalid || frag_tready) begin
                        frag_tvalid <= 1'b1;
                        frag_tdata <= {64'h0, current_y, current_x}; // Mock fragment data
                        
                        if (current_x == max_x && current_y == max_y) begin
                            state <= STATE_FETCH; // Triangle done
                        end else if (current_x == max_x) begin
                            current_x <= rast_tdata[15:0]; // Reset to min_x
                            current_y <= current_y + 1'b1;
                        end else begin
                            current_x <= current_x + 1'b1;
                        end
                    end
                end
            endcase
        end
    end

endmodule
