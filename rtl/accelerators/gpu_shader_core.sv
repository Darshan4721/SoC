`timescale 1ns/1ps
module gpu_shader_core #(
    parameter FRAG_WIDTH = 128,
    parameter PIX_WIDTH = 64
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // In from Rasterizer (Fragments)
    input  logic                  frag_tvalid,
    input  logic [FRAG_WIDTH-1:0] frag_tdata,
    output logic                  frag_tready,
    
    // Texture Fetch Interface (To Texture L1)
    output logic                  tex_req_val,
    output logic [31:0]           tex_req_uv, // U, V coordinates
    input  logic                  tex_req_rdy,
    input  logic                  tex_rsp_val,
    input  logic [31:0]           tex_rsp_color, // RGBA
    
    // Out to ROP (Colored Pixels)
    output logic                  pixel_tvalid,
    output logic [PIX_WIDTH-1:0]  pixel_tdata, // X, Y, Z, RGBA
    input  logic                  pixel_tready
);

    // Fragment Shader (Pixel Shader)
    // 1. Accepts fragment
    // 2. Requests texture sample
    // 3. Applies lighting/color (Simulated)
    // 4. Sends to ROP
    
    typedef enum logic [1:0] {
        STATE_IDLE,
        STATE_WAIT_TEX
    } shader_state_t;
    
    shader_state_t state;
    logic [FRAG_WIDTH-1:0] saved_frag;
    
    assign frag_tready = (state == STATE_IDLE);
    
    assign tex_req_val = (state == STATE_IDLE && frag_tvalid);
    assign tex_req_uv  = frag_tdata[63:32]; // Mock UV extraction
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
            saved_frag <= '0;
            pixel_tvalid <= 1'b0;
            pixel_tdata <= '0;
        end else begin
            if (pixel_tvalid && pixel_tready) pixel_tvalid <= 1'b0;
            
            case (state)
                STATE_IDLE: begin
                    if (frag_tvalid && tex_req_rdy) begin
                        saved_frag <= frag_tdata;
                        state <= STATE_WAIT_TEX;
                    end
                end
                STATE_WAIT_TEX: begin
                    if (tex_rsp_val && (!pixel_tvalid || pixel_tready)) begin
                        pixel_tvalid <= 1'b1;
                        // Assemble final pixel: X, Y, Depth(Z), Color(RGBA)
                        pixel_tdata <= {saved_frag[31:0], saved_frag[127:96], tex_rsp_color}; 
                        state <= STATE_IDLE;
                    end
                end
            endcase
        end
    end

endmodule
