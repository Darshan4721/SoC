`timescale 1ns/1ps
module branch_prediction_unit #(
    parameter ADDR_WIDTH = 64,
    parameter BTB_ENTRIES = 256
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Fetch Stage Interface (Prediction)
    input  logic [ADDR_WIDTH-1:0] current_pc,
    output logic                  predicted_taken,
    output logic [ADDR_WIDTH-1:0] predicted_target,
    
    // Execution Stage Interface (Update)
    input  logic                  update_en,
    input  logic [ADDR_WIDTH-1:0] update_pc,
    input  logic                  update_taken,
    input  logic [ADDR_WIDTH-1:0] update_target
);

    // Branch Target Buffer (BTB) - tag array and target array
    logic [ADDR_WIDTH-1:0] btb_tag    [0:BTB_ENTRIES-1];
    logic [ADDR_WIDTH-1:0] btb_target [0:BTB_ENTRIES-1];
    logic                  btb_valid  [0:BTB_ENTRIES-1];
    
    // Branch History Table (BHT) - 2-bit saturating counters
    logic [1:0] bht_counter [0:BTB_ENTRIES-1];
    
    logic [$clog2(BTB_ENTRIES)-1:0] fetch_idx;
    logic [$clog2(BTB_ENTRIES)-1:0] update_idx;
    
    assign fetch_idx  = current_pc[$clog2(BTB_ENTRIES)+1:2];
    assign update_idx = update_pc[$clog2(BTB_ENTRIES)+1:2];
    
    // Prediction Logic (Combinatorial)
    always_comb begin
        if (btb_valid[fetch_idx] && (btb_tag[fetch_idx] == current_pc)) begin
            predicted_target = btb_target[fetch_idx];
            // Predict taken if counter is weakly (10) or strongly (11) taken
            predicted_taken = bht_counter[fetch_idx][1];
        end else begin
            predicted_target = '0;
            predicted_taken = 1'b0;
        end
    end
    
    // Update Logic (Sequential)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<BTB_ENTRIES; i++) begin
                btb_valid[i] <= 1'b0;
                bht_counter[i] <= 2'b01; // Weakly not-taken
            end
        end else if (update_en) begin
            btb_valid[update_idx]  <= 1'b1;
            btb_tag[update_idx]    <= update_pc;
            btb_target[update_idx] <= update_target;
            
            // 2-bit Saturating Counter Update
            if (update_taken) begin
                if (bht_counter[update_idx] != 2'b11)
                    bht_counter[update_idx] <= bht_counter[update_idx] + 1'b1;
            end else begin
                if (bht_counter[update_idx] != 2'b00)
                    bht_counter[update_idx] <= bht_counter[update_idx] - 1'b1;
            end
        end
    end

endmodule
