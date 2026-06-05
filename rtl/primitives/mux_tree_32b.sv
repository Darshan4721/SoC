`timescale 1ns/1ps

module mux_tree_32b #(
    parameter DATA_WIDTH = 32
) (
    input  logic [32*DATA_WIDTH-1:0] data_in,
    input  logic [4:0]               sel,
    output logic [DATA_WIDTH-1:0]    data_out
);
    logic [DATA_WIDTH-1:0] data_array [0:31];

    generate
        for (genvar i = 0; i < 32; i++) begin : gen_array
            assign data_array[i] = data_in[i*DATA_WIDTH +: DATA_WIDTH];
        end
    endgenerate

    assign data_out = data_array[sel];
endmodule
