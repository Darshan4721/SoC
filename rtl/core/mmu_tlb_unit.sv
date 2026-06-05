`timescale 1ns/1ps
module mmu_tlb_unit #(
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 64,
    parameter TLB_ENTRIES = 64
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Interface from AGU (Virtual Address)
    input  logic                  tlb_req_val,
    input  logic                  tlb_is_store,
    input  logic [ADDR_WIDTH-1:0] tlb_virt_addr,
    input  logic [DATA_WIDTH-1:0] tlb_store_data,
    input  logic [6:0]            tlb_rd,
    output logic                  tlb_req_rdy,
    
    // Interface to L1 D-Cache / Store Buffer (Physical Address)
    output logic                  phys_req_val,
    output logic                  phys_is_store,
    output logic [ADDR_WIDTH-1:0] phys_addr,
    output logic [DATA_WIDTH-1:0] phys_store_data,
    output logic [6:0]            phys_rd,
    input  logic                  phys_req_rdy,
    
    output logic                  tlb_miss_exception // For Page Faults
);

    // Fully Associative TLB mapping Virtual Page Numbers (VPN) to Physical Page Numbers (PPN)
    logic [26:0] vpn_array [0:TLB_ENTRIES-1]; // Assuming SV39 (27-bit VPN)
    logic [43:0] ppn_array [0:TLB_ENTRIES-1]; // Assuming SV39 (44-bit PPN)
    logic        valid_arr [0:TLB_ENTRIES-1];
    
    logic [26:0] req_vpn;
    logic [11:0] page_offset;
    
    assign req_vpn = tlb_virt_addr[38:12];
    assign page_offset = tlb_virt_addr[11:0];
    
    logic        tlb_hit;
    logic [43:0] hit_ppn;
    
    always_comb begin
        tlb_hit = 1'b0;
        hit_ppn = '0;
        for (int i = 0; i < TLB_ENTRIES; i++) begin
            if (valid_arr[i] && vpn_array[i] == req_vpn) begin
                tlb_hit = 1'b1;
                hit_ppn = ppn_array[i];
            end
        end
    end
    
    assign tlb_miss_exception = tlb_req_val && !tlb_hit;
    
    // Pass-through if hit (If miss, handled by OS Trap, pipeline flushed)
    assign phys_req_val = tlb_req_val && tlb_hit;
    assign phys_is_store = tlb_is_store;
    assign phys_addr = {10'd0, hit_ppn, page_offset}; // Recombine PPN + Offset into 64-bit PA
    assign phys_store_data = tlb_store_data;
    assign phys_rd = tlb_rd;
    
    assign tlb_req_rdy = phys_req_rdy && tlb_hit;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<TLB_ENTRIES; i++) valid_arr[i] <= 1'b0;
            // Note: OS/Hardware Page Table Walker (PTW) logic would populate these entries
        end
    end

endmodule
