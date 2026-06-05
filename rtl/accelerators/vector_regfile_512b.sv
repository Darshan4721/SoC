`timescale 1ns/1ps
module vector_regfile_512b #(
    parameter VLEN = 512,
    parameter VREGS = 32
) (
    input  logic                  clk,
    input  logic                  rst_n,
    
    // Read Port 1 (vs1)
    input  logic                  read_req_1,
    input  logic [4:0]            read_addr_1,
    output logic [VLEN-1:0]       read_data_1,
    
    // Read Port 2 (vs2)
    input  logic                  read_req_2,
    input  logic [4:0]            read_addr_2,
    output logic [VLEN-1:0]       read_data_2,
    
    // Read Port 3 (Mask v0)
    input  logic                  read_req_v0,
    output logic [VLEN-1:0]       read_data_v0,
    
    // Write Port (vd)
    input  logic                  write_req,
    input  logic [4:0]            write_addr,
    input  logic [VLEN-1:0]       write_data,
    input  logic [VLEN/8-1:0]     write_byte_enable // Byte-level mask
);

    // 32 architectural vector registers, each 512 bits wide.
    logic [VLEN-1:0] vreg_array [0:VREGS-1];
    
    // Asynchronous Read (or simple forward comb) for SIMD width
    always_comb begin
        read_data_1  = read_req_1  ? vreg_array[read_addr_1] : '0;
        read_data_2  = read_req_2  ? vreg_array[read_addr_2] : '0;
        read_data_v0 = read_req_v0 ? vreg_array[0]           : '0; // v0 is the dedicated mask register
    end
    
    // Synchronous Write with byte-enable masking
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i=0; i<VREGS; i++) begin
                vreg_array[i] <= '0;
            end
        end else if (write_req) begin
            for (int byte_idx = 0; byte_idx < VLEN/8; byte_idx++) begin
                if (write_byte_enable[byte_idx]) begin
                    vreg_array[write_addr][byte_idx*8 +: 8] <= write_data[byte_idx*8 +: 8];
                end
            end
        end
    end

endmodule
