`timescale 1ns/1ps

module dummy_axi_memory #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256,
    parameter MEM_SIZE = 65536 // 64KB
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Read Address Channel
    input  logic                  s_axi_arvalid,
    input  logic [ADDR_WIDTH-1:0] s_axi_araddr,
    input  logic [7:0]            s_axi_arlen,
    output logic                  s_axi_arready,
    
    // Read Data Channel
    output logic                  s_axi_rvalid,
    output logic [DATA_WIDTH-1:0] s_axi_rdata,
    output logic                  s_axi_rlast,
    input  logic                  s_axi_rready,
    
    // Write Address Channel
    input  logic                  s_axi_awvalid,
    input  logic [ADDR_WIDTH-1:0] s_axi_awaddr,
    input  logic [7:0]            s_axi_awlen,
    output logic                  s_axi_awready,
    
    // Write Data Channel
    input  logic                  s_axi_wvalid,
    input  logic [DATA_WIDTH-1:0] s_axi_wdata,
    input  logic                  s_axi_wlast,
    output logic                  s_axi_wready,
    
    // Write Response Channel
    output logic                  s_axi_bvalid,
    input  logic                  s_axi_bready
);

    // Memory array
    logic [7:0] mem [0:MEM_SIZE-1];
    
    initial begin
        for (int i=0; i<MEM_SIZE; i++) mem[i] = 8'h00;
        
        // Instruction 1: ADDI x1, x0, 5  (0x00500093)
        mem[0] = 8'h93;
        mem[1] = 8'h00;
        mem[2] = 8'h50;
        mem[3] = 8'h00;
        
        // Instruction 2: ADDI x2, x0, 10 (0x00a00113)
        mem[4] = 8'h13;
        mem[5] = 8'h01;
        mem[6] = 8'ha0;
        mem[7] = 8'h00;
        
        // Instruction 3: ADD x3, x1, x2  (0x002081b3)
        mem[8] = 8'hb3;
        mem[9] = 8'h81;
        mem[10] = 8'h20;
        mem[11] = 8'h00;
        
        // Instruction 4: JAL x0, 0       (0x0000006f) - Infinite Loop
        mem[12] = 8'h6f;
        mem[13] = 8'h00;
        mem[14] = 8'h00;
        mem[15] = 8'h00;
    end
    
    // Read FSM
    typedef enum logic [1:0] {R_IDLE, R_READ} r_state_t;
    r_state_t r_state, r_next;
    
    logic [ADDR_WIDTH-1:0] r_addr_reg;
    logic [7:0]            r_len_reg;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_state <= R_IDLE;
            r_addr_reg <= '0;
            r_len_reg <= '0;
        end else begin
            r_state <= r_next;
            if (s_axi_arvalid && s_axi_arready) begin
                // Map 0x8000_0000 to offset 0
                r_addr_reg <= s_axi_araddr - 64'h8000_0000;
                r_len_reg <= s_axi_arlen;
            end else if (s_axi_rvalid && s_axi_rready) begin
                if (r_len_reg > 0) begin
                    r_addr_reg <= r_addr_reg + (DATA_WIDTH/8);
                    r_len_reg <= r_len_reg - 1'b1;
                end
            end
        end
    end
    
    always_comb begin
        r_next = r_state;
        s_axi_arready = 1'b0;
        s_axi_rvalid = 1'b0;
        s_axi_rlast = 1'b0;
        
        case (r_state)
            R_IDLE: begin
                s_axi_arready = 1'b1;
                if (s_axi_arvalid) r_next = R_READ;
            end
            R_READ: begin
                s_axi_rvalid = 1'b1;
                s_axi_rlast = (r_len_reg == 0);
                if (s_axi_rready && s_axi_rlast) r_next = R_IDLE;
            end
        endcase
    end
    
    // Read Data Assembly
    always_comb begin
        for (int i=0; i<(DATA_WIDTH/8); i++) begin
            if ((r_addr_reg + i) < MEM_SIZE)
                s_axi_rdata[i*8 +: 8] = mem[int'(r_addr_reg + i)];
            else
                s_axi_rdata[i*8 +: 8] = 8'h00;
        end
    end

    // Write FSM (Simplified)
    typedef enum logic [1:0] {W_IDLE, W_WRITE, W_RESP} w_state_t;
    w_state_t w_state, w_next;
    
    logic [ADDR_WIDTH-1:0] w_addr_reg;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_state <= W_IDLE;
            w_addr_reg <= '0;
        end else begin
            w_state <= w_next;
            if (s_axi_awvalid && s_axi_awready) begin
                w_addr_reg <= s_axi_awaddr - 64'h8000_0000;
            end else if (s_axi_wvalid && s_axi_wready) begin
                for (int i=0; i<(DATA_WIDTH/8); i++) begin
                    if ((w_addr_reg + i) < MEM_SIZE)
                        mem[int'(w_addr_reg + i)] <= s_axi_wdata[i*8 +: 8];
                end
                w_addr_reg <= w_addr_reg + (DATA_WIDTH/8);
            end
        end
    end
    
    always_comb begin
        w_next = w_state;
        s_axi_awready = 1'b0;
        s_axi_wready = 1'b0;
        s_axi_bvalid = 1'b0;
        
        case (w_state)
            W_IDLE: begin
                s_axi_awready = 1'b1;
                if (s_axi_awvalid) w_next = W_WRITE;
            end
            W_WRITE: begin
                s_axi_wready = 1'b1;
                if (s_axi_wvalid && s_axi_wlast) w_next = W_RESP;
            end
            W_RESP: begin
                s_axi_bvalid = 1'b1;
                if (s_axi_bready) w_next = W_IDLE;
            end
        endcase
    end

endmodule
