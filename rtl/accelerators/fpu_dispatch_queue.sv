`timescale 1ns/1ps
module fpu_dispatch_queue #(
    parameter DEPTH = 16,
    parameter FREG_WIDTH = 5 // 32 floating point registers (f0-f31)
) (
    input  logic clk,
    input  logic rst_n,
    input  logic flush, // For branch mispredict
    
    // Core Dispatch Interface
    input  logic                  dispatch_val,
    input  logic [31:0]           dispatch_instr,
    input  logic [FREG_WIDTH-1:0] dispatch_fd,
    input  logic [FREG_WIDTH-1:0] dispatch_fs1,
    input  logic [FREG_WIDTH-1:0] dispatch_fs2,
    input  logic [FREG_WIDTH-1:0] dispatch_fs3, // Required for FMA
    output logic                  queue_ready,
    
    // Issue to FPU Datapath
    output logic                  issue_val,
    output logic [31:0]           issue_instr,
    output logic [FREG_WIDTH-1:0] issue_fd,
    output logic [FREG_WIDTH-1:0] issue_fs1,
    output logic [FREG_WIDTH-1:0] issue_fs2,
    output logic [FREG_WIDTH-1:0] issue_fs3,
    input  logic                  issue_ready
);

    // Queue Arrays
    logic                  valid_arr [0:DEPTH-1];
    logic [31:0]           instr_arr [0:DEPTH-1];
    logic [FREG_WIDTH-1:0] fd_arr    [0:DEPTH-1];
    logic [FREG_WIDTH-1:0] fs1_arr   [0:DEPTH-1];
    logic [FREG_WIDTH-1:0] fs2_arr   [0:DEPTH-1];
    logic [FREG_WIDTH-1:0] fs3_arr   [0:DEPTH-1];
    
    logic [$clog2(DEPTH)-1:0] head;
    logic [$clog2(DEPTH)-1:0] tail;
    logic [$clog2(DEPTH):0]   count;
    
    assign queue_ready = (count < DEPTH);
    
    assign issue_val   = (count > 0);
    assign issue_instr = instr_arr[head];
    assign issue_fd    = fd_arr[head];
    assign issue_fs1   = fs1_arr[head];
    assign issue_fs2   = fs2_arr[head];
    assign issue_fs3   = fs3_arr[head];
    
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
                fd_arr[tail]    <= dispatch_fd;
                fs1_arr[tail]   <= dispatch_fs1;
                fs2_arr[tail]   <= dispatch_fs2;
                fs3_arr[tail]   <= dispatch_fs3;
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
