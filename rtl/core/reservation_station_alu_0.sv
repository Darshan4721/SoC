`timescale 1ns/1ps
module reservation_station_alu_0 #(
    parameter DEPTH = 8,
    parameter PHYS_REG_WIDTH = 7
) (
    input  logic clk,
    input  logic rst_n,
    input  logic flush, // Branch mispredict flush
    
    // Dispatch Interface
    input  logic                      dispatch_val,
    input  logic [PHYS_REG_WIDTH-1:0] dispatch_rd,
    input  logic [PHYS_REG_WIDTH-1:0] dispatch_rs1,
    input  logic [PHYS_REG_WIDTH-1:0] dispatch_rs2,
    input  logic                      rs1_ready, // from scoreboard/ROB
    input  logic                      rs2_ready,
    output logic                      rs_ready, // backpressure
    
    // Common Data Bus (CDB) Snooping for Wakeup
    input  logic [3:0]                      cdb_val,
    input  logic [3:0][PHYS_REG_WIDTH-1:0]  cdb_rd,
    
    // Issue Interface (to Execution Unit)
    output logic                      issue_val,
    output logic [PHYS_REG_WIDTH-1:0] issue_rd,
    output logic [PHYS_REG_WIDTH-1:0] issue_rs1,
    output logic [PHYS_REG_WIDTH-1:0] issue_rs2
);

    // Instruction Queue elements
    logic                      valid_array [0:DEPTH-1];
    logic [PHYS_REG_WIDTH-1:0] rd_array    [0:DEPTH-1];
    logic [PHYS_REG_WIDTH-1:0] rs1_array   [0:DEPTH-1];
    logic [PHYS_REG_WIDTH-1:0] rs2_array   [0:DEPTH-1];
    logic                      rs1_rdy_arr [0:DEPTH-1];
    logic                      rs2_rdy_arr [0:DEPTH-1];
    
    // Simplified pointers for FIFO-based Issue (In true OoO, this is a CAM matrix)
    logic [$clog2(DEPTH)-1:0] tail;
    logic [$clog2(DEPTH):0] count;
    
    assign rs_ready = (count < DEPTH);
    
    // Find the oldest ready instruction (Select Logic)
    logic [$clog2(DEPTH)-1:0] issue_idx;
    logic                     found_ready;
    
    always_comb begin
        found_ready = 1'b0;
        issue_idx = '0;
        for (int i = 0; i < DEPTH; i++) begin
            if (valid_array[i] && rs1_rdy_arr[i] && rs2_rdy_arr[i] && !found_ready) begin
                found_ready = 1'b1;
                issue_idx = i[$clog2(DEPTH)-1:0];
            end
        end
        
        issue_val = found_ready;
        issue_rd  = found_ready ? rd_array[issue_idx] : '0;
        issue_rs1 = found_ready ? rs1_array[issue_idx] : '0;
        issue_rs2 = found_ready ? rs2_array[issue_idx] : '0;
    end
    
    // Update Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<DEPTH; i++) valid_array[i] <= 1'b0;
            tail <= '0;
            count <= '0;
        end else if (flush) begin
            for (int i=0; i<DEPTH; i++) valid_array[i] <= 1'b0;
            tail <= '0;
            count <= '0;
        end else begin
            // Wakeup Logic (Snooping CDB)
            for (int i = 0; i < DEPTH; i++) begin
                if (valid_array[i]) begin
                    for (int c = 0; c < 4; c++) begin
                        if (cdb_val[c] && cdb_rd[c] == rs1_array[i]) rs1_rdy_arr[i] <= 1'b1;
                        if (cdb_val[c] && cdb_rd[c] == rs2_array[i]) rs2_rdy_arr[i] <= 1'b1;
                    end
                end
            end
            
            // Dispatch (Allocate)
            if (dispatch_val && rs_ready) begin
                valid_array[tail] <= 1'b1;
                rd_array[tail]    <= dispatch_rd;
                rs1_array[tail]   <= dispatch_rs1;
                rs2_array[tail]   <= dispatch_rs2;
                rs1_rdy_arr[tail] <= rs1_ready;
                rs2_rdy_arr[tail] <= rs2_ready;
                
                // Wakeup matching in the same cycle as dispatch
                for (int c = 0; c < 4; c++) begin
                    if (cdb_val[c] && cdb_rd[c] == dispatch_rs1) rs1_rdy_arr[tail] <= 1'b1;
                    if (cdb_val[c] && cdb_rd[c] == dispatch_rs2) rs2_rdy_arr[tail] <= 1'b1;
                end
                
                tail <= tail + 1'b1;
                if (!issue_val) count <= count + 1'b1;
            end
            
            // Issue (Deallocate)
            if (issue_val) begin
                valid_array[issue_idx] <= 1'b0; // Invalidate the issued entry
                if (!dispatch_val) count <= count - 1'b1;
            end
        end
    end

endmodule
