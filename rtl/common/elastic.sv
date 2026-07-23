`timescale 1ns/1ps

module elastic #(
    parameter WIDTH_P = 8
) (
    // meta interface
    input logic [0:0] clk_i,
    input logic [0:0] rstn_i,

    input logic [0:0] valid_i,
    output logic [0:0] ready_o,
    output logic [0:0] valid_o,
    input logic [0:0] ready_i
);

    logic [0:0] valid_q;

    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            valid_q <= 1'b0;
        end else if (ready_o) begin
            valid_q <= valid_i;
        end
    end

    assign ready_o = ~valid_o | ready_i;
    assign valid_o = valid_q;

endmodule