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
    input  logic                      rs1_ready,
    input  logic                      rs2_ready,
    output logic                      rs_ready,
    
    // Register File / Bypass Data
    input  logic [63:0]               dispatch_rs1_data,
    input  logic [63:0]               dispatch_rs2_data,
    
    // Common Data Bus (CDB) Snooping for Wakeup
    input  logic [3:0]                      cdb_val,
    input  logic [3:0][PHYS_REG_WIDTH-1:0]  cdb_rd,
    input  logic [3:0][63:0]                cdb_data,
    
    // Execution Output (to CDB arbitration)
    output logic                      exec_val,
    output logic [PHYS_REG_WIDTH-1:0] exec_rd,
    output logic [63:0]               exec_data
);

    logic                      valid_array [0:DEPTH-1];
    logic [PHYS_REG_WIDTH-1:0] rd_array    [0:DEPTH-1];
    logic [PHYS_REG_WIDTH-1:0] rs1_array   [0:DEPTH-1];
    logic [PHYS_REG_WIDTH-1:0] rs2_array   [0:DEPTH-1];
    logic                      rs1_rdy_arr [0:DEPTH-1];
    logic                      rs2_rdy_arr [0:DEPTH-1];
    logic [63:0]               rs1_val_arr [0:DEPTH-1];
    logic [63:0]               rs2_val_arr [0:DEPTH-1];
    
    logic [$clog2(DEPTH)-1:0] tail;
    logic [$clog2(DEPTH):0] count;
    
    assign rs_ready = (count < DEPTH);
    
    logic [$clog2(DEPTH)-1:0] issue_idx;
    logic                     found_ready;
    
    always_comb begin
        found_ready = 1'b0;
        issue_idx = '0;
        for (int i = DEPTH-1; i >= 0; i--) begin
            if (valid_array[i] && rs1_rdy_arr[i] && rs2_rdy_arr[i]) begin
                found_ready = 1'b1;
                issue_idx = i[$clog2(DEPTH)-1:0];
            end
        end
    end
    
    // Issue logic
    logic issue_val;
    logic [63:0] issue_val1, issue_val2;
    logic [PHYS_REG_WIDTH-1:0] issue_rd;
    assign issue_val = found_ready;
    assign issue_rd = found_ready ? rd_array[issue_idx] : '0;
    assign issue_val1 = found_ready ? rs1_val_arr[issue_idx] : '0;
    assign issue_val2 = found_ready ? rs2_val_arr[issue_idx] : '0;

    // Execution Unit Instance (ALU)
    logic [63:0] alu_out;
    carry_lookahead_adder_64 i_alu0 (
        .a(issue_val1),
        .b(issue_val2),
        .cin(1'b0),
        .sum(alu_out),
        .cout()
    );

    // Simple 1-cycle pipeline for ALU
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            exec_val <= 1'b0;
            exec_rd <= '0;
            exec_data <= '0;
        end else if (flush) begin
            exec_val <= 1'b0;
        end else begin
            exec_val <= issue_val;
            exec_rd <= issue_rd;
            exec_data <= alu_out;
        end
    end

    // RS Update Logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<DEPTH; i++) valid_array[i] <= 1'b0;
            tail <= '0; count <= '0;
        end else if (flush) begin
            for (int i=0; i<DEPTH; i++) valid_array[i] <= 1'b0;
            tail <= '0; count <= '0;
        end else begin
            // Snooping
            for (int i = 0; i < DEPTH; i++) begin
                if (valid_array[i]) begin
                    for (int c = 0; c < 4; c++) begin
                        if (cdb_val[c] && cdb_rd[c] == rs1_array[i]) begin
                            rs1_rdy_arr[i] <= 1'b1;
                            rs1_val_arr[i] <= cdb_data[c];
                        end
                        if (cdb_val[c] && cdb_rd[c] == rs2_array[i]) begin
                            rs2_rdy_arr[i] <= 1'b1;
                            rs2_val_arr[i] <= cdb_data[c];
                        end
                    end
                end
            end
            
            // Allocate
            if (dispatch_val && rs_ready) begin
                valid_array[tail] <= 1'b1;
                rd_array[tail] <= dispatch_rd;
                rs1_array[tail] <= dispatch_rs1;
                rs2_array[tail] <= dispatch_rs2;
                rs1_rdy_arr[tail] <= rs1_ready;
                rs2_rdy_arr[tail] <= rs2_ready;
                rs1_val_arr[tail] <= dispatch_rs1_data;
                rs2_val_arr[tail] <= dispatch_rs2_data;
                
                for (int c = 0; c < 4; c++) begin
                    if (cdb_val[c] && cdb_rd[c] == dispatch_rs1) begin rs1_rdy_arr[tail] <= 1'b1; rs1_val_arr[tail] <= cdb_data[c]; end
                    if (cdb_val[c] && cdb_rd[c] == dispatch_rs2) begin rs2_rdy_arr[tail] <= 1'b1; rs2_val_arr[tail] <= cdb_data[c]; end
                end
                
                tail <= tail + 1'b1;
                if (!issue_val) count <= count + 1'b1;
            end
            
            // Deallocate
            if (issue_val) begin
                valid_array[issue_idx] <= 1'b0;
                if (!dispatch_val) count <= count - 1'b1;
            end
        end
    end
endmodule
