`timescale 1ns/1ps
module load_store_queue #(
    parameter DEPTH = 32,
    parameter PHYS_REG_WIDTH = 7
) (
    input  logic clk,
    input  logic rst_n,
    input  logic flush, // Flush on branch mispredict
    
    // Dispatch Interface
    input  logic                      dispatch_val,
    input  logic                      is_store,
    input  logic [PHYS_REG_WIDTH-1:0] dispatch_rd,
    input  logic [PHYS_REG_WIDTH-1:0] dispatch_rs1,
    input  logic [PHYS_REG_WIDTH-1:0] dispatch_rs2,
    input  logic [11:0]               dispatch_imm,
    output logic                      lsq_ready,
    
    // CDB Wakeup Interface
    input  logic [3:0]                      cdb_val,
    input  logic [3:0][PHYS_REG_WIDTH-1:0]  cdb_rd,
    
    // Issue Interface to AGU
    output logic                      agu_req_val,
    output logic                      agu_is_store,
    output logic [PHYS_REG_WIDTH-1:0] agu_rs1,
    output logic [PHYS_REG_WIDTH-1:0] agu_rs2,
    output logic [11:0]               agu_imm,
    output logic [PHYS_REG_WIDTH-1:0] agu_rd,
    input  logic                      agu_req_rdy
);

    // Instruction Queue elements
    logic                      valid_array   [0:DEPTH-1];
    logic                      is_store_arr  [0:DEPTH-1];
    logic [PHYS_REG_WIDTH-1:0] rd_array      [0:DEPTH-1];
    logic [PHYS_REG_WIDTH-1:0] rs1_array     [0:DEPTH-1];
    logic [PHYS_REG_WIDTH-1:0] rs2_array     [0:DEPTH-1];
    logic [11:0]               imm_array     [0:DEPTH-1];
    logic                      rs1_rdy_arr   [0:DEPTH-1];
    logic                      rs2_rdy_arr   [0:DEPTH-1];
    
    logic [$clog2(DEPTH)-1:0] tail;
    logic [$clog2(DEPTH):0] count;
    
    assign lsq_ready = (count < DEPTH);
    
    logic [$clog2(DEPTH)-1:0] issue_idx;
    logic                     found_ready;
    
    // In LSQ, memory ordering requires we typically issue loads and stores in order,
    // or allow out-of-order loads with dynamic conflict checking. For this baseline, 
    // we issue the oldest instruction whose address operands are ready.
    always_comb begin
        found_ready = 1'b0;
        issue_idx = '0;
        for (int i = 0; i < DEPTH; i++) begin
            if (valid_array[i] && rs1_rdy_arr[i] && (rs2_rdy_arr[i] || !is_store_arr[i]) && !found_ready) begin
                found_ready = 1'b1;
                issue_idx = i[$clog2(DEPTH)-1:0];
            end
        end
        agu_req_val  = found_ready;
        agu_is_store = found_ready ? is_store_arr[issue_idx] : 1'b0;
        agu_rs1      = found_ready ? rs1_array[issue_idx] : '0;
        agu_rs2      = found_ready ? rs2_array[issue_idx] : '0;
        agu_imm      = found_ready ? imm_array[issue_idx] : '0;
        agu_rd       = found_ready ? rd_array[issue_idx]  : '0;
    end
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<DEPTH; i++) valid_array[i] <= 1'b0;
            tail <= '0; count <= '0;
        end else if (flush) begin
            for (int i=0; i<DEPTH; i++) valid_array[i] <= 1'b0;
            tail <= '0; count <= '0;
        end else begin
            // Wakeup Logic
            for (int i = 0; i < DEPTH; i++) begin
                if (valid_array[i]) begin
                    for (int c = 0; c < 4; c++) begin
                        if (cdb_val[c] && cdb_rd[c] == rs1_array[i]) rs1_rdy_arr[i] <= 1'b1;
                        if (cdb_val[c] && cdb_rd[c] == rs2_array[i]) rs2_rdy_arr[i] <= 1'b1;
                    end
                end
            end
            
            // Dispatch (Allocate)
            if (dispatch_val && lsq_ready) begin
                valid_array[tail]  <= 1'b1;
                is_store_arr[tail] <= is_store;
                rd_array[tail]     <= dispatch_rd;
                rs1_array[tail]    <= dispatch_rs1;
                rs2_array[tail]    <= dispatch_rs2;
                imm_array[tail]    <= dispatch_imm;
                
                // Assume operands are not ready at dispatch unless bypassed (simplified here to 0)
                rs1_rdy_arr[tail]  <= 1'b0; 
                rs2_rdy_arr[tail]  <= 1'b0;
                
                tail <= tail + 1'b1;
                if (!(agu_req_val && agu_req_rdy)) count <= count + 1'b1;
            end
            
            // Issue (Deallocate)
            if (agu_req_val && agu_req_rdy) begin
                valid_array[issue_idx] <= 1'b0;
                if (!dispatch_val) count <= count - 1'b1;
            end
        end
    end
endmodule
