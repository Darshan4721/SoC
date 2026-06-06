`timescale 1ns/1ps

module noc_router #(
    parameter NUM_MASTERS = 10,
    parameter NUM_SLAVES = 2,
    parameter ADDR_WIDTH = 64,
    parameter DATA_WIDTH = 256
) (
    input  logic clk,
    input  logic rst_n,
    
    // Incoming Masters Array (10 Masters)
    input  logic [NUM_MASTERS-1:0]                  s_axi_arvalid,
    input  logic [NUM_MASTERS-1:0][ADDR_WIDTH-1:0]  s_axi_araddr,
    input  logic [NUM_MASTERS-1:0][7:0]             s_axi_arlen,
    output logic [NUM_MASTERS-1:0]                  s_axi_arready,
    
    output logic [NUM_MASTERS-1:0]                  s_axi_rvalid,
    output logic [NUM_MASTERS-1:0][DATA_WIDTH-1:0]  s_axi_rdata,
    output logic [NUM_MASTERS-1:0]                  s_axi_rlast,
    input  logic [NUM_MASTERS-1:0]                  s_axi_rready,
    
    input  logic [NUM_MASTERS-1:0]                  s_axi_awvalid,
    input  logic [NUM_MASTERS-1:0][ADDR_WIDTH-1:0]  s_axi_awaddr,
    input  logic [NUM_MASTERS-1:0][7:0]             s_axi_awlen,
    output logic [NUM_MASTERS-1:0]                  s_axi_awready,
    
    input  logic [NUM_MASTERS-1:0]                  s_axi_wvalid,
    input  logic [NUM_MASTERS-1:0][DATA_WIDTH-1:0]  s_axi_wdata,
    input  logic [NUM_MASTERS-1:0]                  s_axi_wlast,
    output logic [NUM_MASTERS-1:0]                  s_axi_wready,
    
    output logic [NUM_MASTERS-1:0]                  s_axi_bvalid,
    input  logic [NUM_MASTERS-1:0]                  s_axi_bready,
    
    // Outgoing Slaves Array (2 Slaves)
    output logic [NUM_SLAVES-1:0]                   m_axi_arvalid,
    output logic [NUM_SLAVES-1:0][ADDR_WIDTH-1:0]   m_axi_araddr,
    output logic [NUM_SLAVES-1:0][7:0]              m_axi_arlen,
    input  logic [NUM_SLAVES-1:0]                   m_axi_arready,
    
    input  logic [NUM_SLAVES-1:0]                   m_axi_rvalid,
    input  logic [NUM_SLAVES-1:0][DATA_WIDTH-1:0]   m_axi_rdata,
    input  logic [NUM_SLAVES-1:0]                   m_axi_rlast,
    output logic [NUM_SLAVES-1:0]                   m_axi_rready,
    
    output logic [NUM_SLAVES-1:0]                   m_axi_awvalid,
    output logic [NUM_SLAVES-1:0][ADDR_WIDTH-1:0]   m_axi_awaddr,
    output logic [NUM_SLAVES-1:0][7:0]              m_axi_awlen,
    input  logic [NUM_SLAVES-1:0]                   m_axi_awready,
    
    output logic [NUM_SLAVES-1:0]                   m_axi_wvalid,
    output logic [NUM_SLAVES-1:0][DATA_WIDTH-1:0]   m_axi_wdata,
    output logic [NUM_SLAVES-1:0]                   m_axi_wlast,
    input  logic [NUM_SLAVES-1:0]                   m_axi_wready,
    
    input  logic [NUM_SLAVES-1:0]                   m_axi_bvalid,
    output logic [NUM_SLAVES-1:0]                   m_axi_bready
);

    // ==========================================
    // Internal NoC Wires
    // ==========================================
    logic [NUM_MASTERS-1:0][255:0] flit_master_out;
    logic [NUM_MASTERS-1:0]        flit_master_val;
    logic [NUM_MASTERS-1:0]        credit_to_master;
    
    logic [NUM_MASTERS-1:0]        vc_grant;
    logic [NUM_MASTERS-1:0][1:0]   vc_id;
    logic [NUM_MASTERS-1:0]        alloc_credit_out;
    
    // Slaves flit wiring (Reverse path for read data)
    logic [NUM_SLAVES-1:0][255:0]  flit_slave_out;
    logic [NUM_SLAVES-1:0]         flit_slave_val;
    logic [NUM_SLAVES-1:0]         credit_to_slave;

    // ==========================================
    // Master Interfaces (10x Network Interfaces + 10x VC Allocators)
    // ==========================================
    genvar i;
    generate
        for (i = 0; i < NUM_MASTERS; i++) begin : gen_masters
            // 1. Network Interface (Converts Master AXI -> NoC Flits)
            noc_network_interface i_ni_master (
                .clk(clk),
                .rst_n(rst_n),
                
                .axi_awaddr(s_axi_awaddr[i][63:0]),
                .axi_wdata(s_axi_wdata[i]),
                .axi_awvalid(s_axi_awvalid[i]),
                .axi_wvalid(s_axi_wvalid[i]),
                .axi_awready(s_axi_awready[i]),
                .axi_wready(s_axi_wready[i]),
                
                .flit_out(flit_master_out[i]),
                .flit_out_val(flit_master_val[i]),
                .credit_in(credit_to_master[i])
            );
            
            // 2. VC Allocator (Arbitrates the flits for this Master)
            noc_vc_allocator i_vc_alloc (
                .clk(clk),
                .rst_n(rst_n),
                
                .req_in(flit_master_val[i]),
                .dest_id(flit_master_out[i][1:0]), // Route based on lower bits of flit
                
                .grant_out(vc_grant[i]),
                .vc_id(vc_id[i]),
                
                .credit_in(1'b1), // Tied to 1 for dummy router fabric
                .credit_out(alloc_credit_out[i])
            );
            
            // Link VC Allocator credit back to NI
            assign credit_to_master[i] = alloc_credit_out[i];
            
            // Tie off unused read channels for master
            assign s_axi_arready[i] = 1'b0;
            assign s_axi_rvalid[i]  = 1'b0;
            assign s_axi_rdata[i]   = '0;
            assign s_axi_rlast[i]   = 1'b0;
            assign s_axi_bvalid[i]  = 1'b0;
        end
    endgenerate

    // ==========================================
    // Slave Interfaces (2x Network Interfaces)
    // ==========================================
    genvar j;
    generate
        for (j = 0; j < NUM_SLAVES; j++) begin : gen_slaves
            // 3. Network Interface (Converts Slave AXI -> NoC Flits for read returns)
            noc_network_interface i_ni_slave (
                .clk(clk),
                .rst_n(rst_n),
                
                // For slave NI, we tie the AXI writes to 0 since it generates read responses
                .axi_awaddr(64'd0),
                .axi_wdata(256'd0),
                .axi_awvalid(1'b0),
                .axi_wvalid(1'b0),
                .axi_awready(),
                .axi_wready(),
                
                .flit_out(flit_slave_out[j]),
                .flit_out_val(flit_slave_val[j]),
                .credit_in(1'b1) // Dummy credit
            );
            
            // Tie off unused write channels for slaves
            assign m_axi_arvalid[j] = 1'b0;
            assign m_axi_araddr[j]  = '0;
            assign m_axi_arlen[j]   = '0;
            
            assign m_axi_awvalid[j] = 1'b0;
            assign m_axi_awaddr[j]  = '0;
            assign m_axi_awlen[j]   = '0;
            
            assign m_axi_wvalid[j]  = 1'b0;
            assign m_axi_wdata[j]   = '0;
            assign m_axi_wlast[j]   = 1'b0;
            
            assign m_axi_rready[j]  = 1'b0;
            assign m_axi_bready[j]  = 1'b0;
        end
    endgenerate

endmodule
