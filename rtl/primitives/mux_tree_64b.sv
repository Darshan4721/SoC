`timescale 1ns/1ps

module mux_tree_64b #(
    parameter DATA_WIDTH = 32
) (
    input  logic [64*DATA_WIDTH-1:0] data_in,
    input  logic [5:0]               sel,
    output logic [DATA_WIDTH-1:0]    data_out
);
    logic [DATA_WIDTH-1:0] data_array [0:63];

    generate
        for (genvar i = 0; i < 64; i++) begin : gen_array
            assign data_array[i] = data_in[i*DATA_WIDTH +: DATA_WIDTH];
        end
    endgenerate

    assign data_out = data_array[sel];
endmodule
