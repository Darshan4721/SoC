`timescale 1ns/1ps
module vector_dispatch_queue #(
    parameter DEPTH = 16,
    parameter VREG_WIDTH = 5 // 32 vector registers (v0-v31)
) (
    input  logic clk,
    input  logic rst_n,
    input  logic flush, // For branch mispredict
    
    // Core Dispatch Interface
    input  logic                  dispatch_val,
    input  logic [31:0]           dispatch_instr,
    input  logic [VREG_WIDTH-1:0] dispatch_vd,
    input  logic [VREG_WIDTH-1:0] dispatch_vs1,
    input  logic [VREG_WIDTH-1:0] dispatch_vs2,
    input  logic                  dispatch_vm, // Mask enable
    output logic                  queue_ready,
    
    // Issue to Vector Lanes
    output logic                  issue_val,
    output logic [31:0]           issue_instr,
    output logic [VREG_WIDTH-1:0] issue_vd,
    output logic [VREG_WIDTH-1:0] issue_vs1,
    output logic [VREG_WIDTH-1:0] issue_vs2,
    output logic                  issue_vm,
    input  logic                  issue_ready
);

    // Queue Arrays
    logic                  valid_arr [0:DEPTH-1];
    logic [31:0]           instr_arr [0:DEPTH-1];
    logic [VREG_WIDTH-1:0] vd_arr    [0:DEPTH-1];
    logic [VREG_WIDTH-1:0] vs1_arr   [0:DEPTH-1];
    logic [VREG_WIDTH-1:0] vs2_arr   [0:DEPTH-1];
    logic                  vm_arr    [0:DEPTH-1];
    
    logic [$clog2(DEPTH)-1:0] head;
    logic [$clog2(DEPTH)-1:0] tail;
    logic [$clog2(DEPTH):0]   count;
    
    assign queue_ready = (count < DEPTH);
    
    assign issue_val   = valid_arr[head] && (count > 0);
    assign issue_instr = instr_arr[head];
    assign issue_vd    = vd_arr[head];
    assign issue_vs1   = vs1_arr[head];
    assign issue_vs2   = vs2_arr[head];
    assign issue_vm    = vm_arr[head];
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<DEPTH; i++) valid_arr[i] <= 1'b0;
            head <= '0;
            tail <= '0;
            count <= '0;
        end else if (flush) begin
            for (int i=0; i<DEPTH; i++) valid_arr[i] <= 1'b0;
            head <= '0;
            tail <= '0;
            count <= '0;
        end else begin
            // Allocate
            if (dispatch_val && queue_ready) begin
                valid_arr[tail] <= 1'b1;
                instr_arr[tail] <= dispatch_instr;
                vd_arr[tail]    <= dispatch_vd;
                vs1_arr[tail]   <= dispatch_vs1;
                vs2_arr[tail]   <= dispatch_vs2;
                vm_arr[tail]    <= dispatch_vm;
                tail <= (tail + 1'b1) % DEPTH;
            end
            
            // Deallocate
            if (issue_val && issue_ready) begin
                valid_arr[head] <= 1'b0;
                head <= (head + 1'b1) % DEPTH;
            end
            
            // Count tracking
            if ((dispatch_val && queue_ready) && !(issue_val && issue_ready))
                count <= count + 1'b1;
            else if (!(dispatch_val && queue_ready) && (issue_val && issue_ready))
                count <= count - 1'b1;
        end
    end

endmodule
