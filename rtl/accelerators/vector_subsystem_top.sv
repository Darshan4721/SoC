`timescale 1ns/1ps
module vector_subsystem_top #(
    parameter VLEN = 512,
    parameter VREGS = 32,
    parameter ADDR_WIDTH = 64,
    parameter ELEM_WIDTH = 32
) (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  flush,
    
    // Core Dispatch Interface
    input  logic                  dispatch_val,
    input  logic [31:0]           dispatch_instr,
    input  logic [4:0]            dispatch_vd,
    input  logic [4:0]            dispatch_vs1,
    input  logic [4:0]            dispatch_vs2,
    input  logic                  dispatch_vm,
    output logic                  queue_ready,
    
    // Memory Gather/Scatter Interface (To NoC / L2 Cache)
    output logic                  mem_req_val,
    output logic                  mem_is_store,
    output logic [ADDR_WIDTH-1:0] mem_addr,
    output logic [ELEM_WIDTH-1:0] mem_wdata,
    input  logic                  mem_req_rdy,
    input  logic                  mem_rsp_val,
    input  logic [ELEM_WIDTH-1:0] mem_rdata
);

    // =========================================================================
    // INTERNAL WIRING (The Glue Logic)
    // =========================================================================
    
    // 1. Dispatch Queue -> Execution
    logic        issue_val;
    logic [31:0] issue_instr;
    logic [4:0]  issue_vd, issue_vs1, issue_vs2;
    logic        issue_vm;
    logic        issue_ready;
    
    // 2. Regfile Read Buses
    logic [VLEN-1:0] vs1_data, vs2_data, v0_mask_data;
    
    // 3. Lane Outputs
    logic         lane0_val, lane1_val, lane2_val, lane3_val;
    logic [127:0] lane0_res, lane1_res, lane2_res, lane3_res;
    logic         lane_ready;
    
    // 4. Gather/Scatter Outputs
    logic            gs_wb_val;
    logic [VLEN-1:0] gs_wb_data;
    logic            gs_ready;
    
    // 5. Mask Logic Outputs
    logic              mask_val;
    logic [VLEN/8-1:0] mask_byte_en;
    
    // 6. Writeback Bus (To Regfile)
    logic            write_req;
    logic [4:0]      write_addr;
    logic [VLEN-1:0] write_data;

    // =========================================================================
    // SIMPLE GLUE PROTOCOL LOGIC
    // =========================================================================
    
    // Structural Decode: Identify if the instruction is a memory op or ALU op
    // Simplified: bit 6 of RVV opcode (e.g. 7'b0000111 is vector load/store)
    logic is_mem_op;
    assign is_mem_op = (issue_instr[6:0] == 7'h07) || (issue_instr[6:0] == 7'h27);
    
    // Issue ready logic
    assign issue_ready = is_mem_op ? gs_ready : lane_ready;
    
    // Lane coordination (all lanes execute in lockstep)
    assign lane_ready = 1'b1; // Simplified: assuming 1 cycle throughput or synchronous accept
    
    // Writeback arbitration (Mem vs ALU)
    // In a real out-of-order vector unit, this uses a completion buffer. 
    // Structurally tying off for synchronous simulation:
    assign write_req  = lane0_val || gs_wb_val;
    assign write_addr = issue_vd; // Note: In pipelined execution, vd must be passed down pipeline.
    assign write_data = is_mem_op ? gs_wb_data : {lane3_res, lane2_res, lane1_res, lane0_res};

    // =========================================================================
    // MODULE INSTANTIATIONS
    // =========================================================================

    // 1. Vector Dispatch Queue
    vector_dispatch_queue #(
        .DEPTH(16),
        .VREG_WIDTH(5)
    ) i_queue (
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush),
        .dispatch_val(dispatch_val),
        .dispatch_instr(dispatch_instr),
        .dispatch_vd(dispatch_vd),
        .dispatch_vs1(dispatch_vs1),
        .dispatch_vs2(dispatch_vs2),
        .dispatch_vm(dispatch_vm),
        .queue_ready(queue_ready),
        .issue_val(issue_val),
        .issue_instr(issue_instr),
        .issue_vd(issue_vd),
        .issue_vs1(issue_vs1),
        .issue_vs2(issue_vs2),
        .issue_vm(issue_vm),
        .issue_ready(issue_ready)
    );

    // 2. Vector Register File (512-bit)
    vector_regfile_512b #(
        .VLEN(VLEN),
        .VREGS(VREGS)
    ) i_regfile (
        .clk(clk),
        .rst_n(rst_n),
        .read_req_1(issue_val),
        .read_addr_1(issue_vs1),
        .read_data_1(vs1_data),
        .read_req_2(issue_val),
        .read_addr_2(issue_vs2),
        .read_data_2(vs2_data),
        .read_req_v0(issue_val),
        .read_data_v0(v0_mask_data),
        .write_req(write_req),
        .write_addr(write_addr),
        .write_data(write_data),
        .write_byte_enable(mask_byte_en)
    );

    // 3. Vector Mask Logic
    vector_mask_logic #(
        .VLEN(VLEN)
    ) i_mask_logic (
        .clk(clk),
        .rst_n(rst_n),
        .cmd_val(issue_val),
        .opcode(issue_instr),
        .v0_mask_in(v0_mask_data[VLEN/8-1:0]),
        .cmd_ready(), // Ignored in strict lockstep
        .mask_val(mask_val),
        .mask_out(mask_byte_en),
        .mask_ready(1'b1)
    );

    // 4. Vector Lanes (4x 128-bit)
    vector_lane_0 #( .LANE_WIDTH(128) ) i_lane_0 (
        .clk(clk), .rst_n(rst_n),
        .exec_val(issue_val && !is_mem_op), .opcode(issue_instr),
        .vs1_data(vs1_data[127:0]), .vs2_data(vs2_data[127:0]), .mask_data(mask_byte_en[15:0]),
        .exec_ready(), .res_val(lane0_val), .res_data(lane0_res), .res_ready(1'b1)
    );

    vector_lane_1 #( .LANE_WIDTH(128) ) i_lane_1 (
        .clk(clk), .rst_n(rst_n),
        .exec_val(issue_val && !is_mem_op), .opcode(issue_instr),
        .vs1_data(vs1_data[255:128]), .vs2_data(vs2_data[255:128]), .mask_data(mask_byte_en[31:16]),
        .exec_ready(), .res_val(lane1_val), .res_data(lane1_res), .res_ready(1'b1)
    );

    vector_lane_2 #( .LANE_WIDTH(128) ) i_lane_2 (
        .clk(clk), .rst_n(rst_n),
        .exec_val(issue_val && !is_mem_op), .opcode(issue_instr),
        .vs1_data(vs1_data[383:256]), .vs2_data(vs2_data[383:256]), .mask_data(mask_byte_en[47:32]),
        .exec_ready(), .res_val(lane2_val), .res_data(lane2_res), .res_ready(1'b1)
    );

    vector_lane_3 #( .LANE_WIDTH(128) ) i_lane_3 (
        .clk(clk), .rst_n(rst_n),
        .exec_val(issue_val && !is_mem_op), .opcode(issue_instr),
        .vs1_data(vs1_data[511:384]), .vs2_data(vs2_data[511:384]), .mask_data(mask_byte_en[63:48]),
        .exec_ready(), .res_val(lane3_val), .res_data(lane3_res), .res_ready(1'b1)
    );

    // 5. Gather/Scatter Memory Unit
    vector_gather_scatter_unit #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .VLEN(VLEN),
        .ELEM_WIDTH(ELEM_WIDTH)
    ) i_gs_unit (
        .clk(clk),
        .rst_n(rst_n),
        .cmd_val(issue_val && is_mem_op),
        .is_scatter(issue_instr[5]), // Simplified RVV decode
        .base_addr(vs1_data[ADDR_WIDTH-1:0]), // Scalar base addr assumed in vs1 low bits
        .index_vector(vs2_data),
        .data_vector(vs1_data), // For stores
        .mask_vector(mask_byte_en),
        .cmd_ready(gs_ready),
        .mem_req_val(mem_req_val),
        .mem_is_store(mem_is_store),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_req_rdy(mem_req_rdy),
        .mem_rsp_val(mem_rsp_val),
        .mem_rdata(mem_rdata),
        .wb_val(gs_wb_val),
        .wb_data(gs_wb_data),
        .wb_ready(1'b1)
    );

endmodule
