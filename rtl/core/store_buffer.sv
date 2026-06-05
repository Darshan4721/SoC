`timescale 1ns/1ps
module store_buffer #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter DEPTH = 16
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Interface from TLB (Physical Address & Data)
    input  logic                  store_val,
    input  logic [ADDR_WIDTH-1:0] store_addr,
    input  logic [DATA_WIDTH-1:0] store_data,
    output logic                  store_rdy,
    
    // Interface from Commit Unit (Retirement trigger)
    input  logic                  commit_store,
    
    // Interface to L1 D-Cache (Write-back)
    output logic                  dcache_req_val,
    output logic [ADDR_WIDTH-1:0] dcache_req_addr,
    output logic [DATA_WIDTH-1:0] dcache_req_data,
    input  logic                  dcache_req_rdy
);

    // Store Buffer Array
    logic                  valid_arr [0:DEPTH-1];
    logic                  commit_arr[0:DEPTH-1]; // 1 if instruction has committed
    logic [ADDR_WIDTH-1:0] addr_arr  [0:DEPTH-1];
    logic [DATA_WIDTH-1:0] data_arr  [0:DEPTH-1];
    
    logic [$clog2(DEPTH)-1:0] alloc_ptr;
    logic [$clog2(DEPTH)-1:0] commit_ptr; // Tracks which entry gets committed next
    logic [$clog2(DEPTH)-1:0] drain_ptr;  // Tracks which entry goes to cache next
    logic [$clog2(DEPTH):0]   count;
    
    assign store_rdy = (count < DEPTH);
    
    // Drain logic (Send to Cache)
    assign dcache_req_val  = valid_arr[drain_ptr] && commit_arr[drain_ptr];
    assign dcache_req_addr = addr_arr[drain_ptr];
    assign dcache_req_data = data_arr[drain_ptr];
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<DEPTH; i++) begin
                valid_arr[i] <= 1'b0;
                commit_arr[i] <= 1'b0;
            end
            alloc_ptr <= '0;
            commit_ptr <= '0;
            drain_ptr <= '0;
            count <= '0;
        end else begin
            // 1. Allocate speculative store
            if (store_val && store_rdy) begin
                valid_arr[alloc_ptr]  <= 1'b1;
                commit_arr[alloc_ptr] <= 1'b0;
                addr_arr[alloc_ptr]   <= store_addr;
                data_arr[alloc_ptr]   <= store_data;
                alloc_ptr <= alloc_ptr + 1'b1;
            end
            
            // 2. Mark store as committed (from ROB)
            if (commit_store) begin
                commit_arr[commit_ptr] <= 1'b1;
                commit_ptr <= commit_ptr + 1'b1;
            end
            
            // 3. Drain committed store to L1 Cache
            if (dcache_req_val && dcache_req_rdy) begin
                valid_arr[drain_ptr] <= 1'b0;
                drain_ptr <= drain_ptr + 1'b1;
            end
            
            // Count tracking
            if ((store_val && store_rdy) && !(dcache_req_val && dcache_req_rdy)) count <= count + 1'b1;
            else if (!(store_val && store_rdy) && (dcache_req_val && dcache_req_rdy)) count <= count - 1'b1;
        end
    end

endmodule
