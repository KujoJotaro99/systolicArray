`timescale 1ns/1ps

module pe #(
    parameter WIDTH_P = 8
) (
    // meta interface
    input logic [0:0] clk_i,
    input logic [0:0] rstn_i,
    input logic [0:0] load_i,

    input logic [0:0] valid_i,
    input logic [0:0] ready_i,
    output logic [0:0] valid_o,
    output logic [0:0] ready_o,

    // input stream
    input logic signed [WIDTH_P-1:0] a_i,
    input logic signed [(2*WIDTH_P):0] b_i,
    input logic signed [WIDTH_P-1:0] weight_i,

    // output stream
    output logic signed [WIDTH_P-1:0] c_o,
    output logic signed [(2*WIDTH_P):0] d_o
);

    logic signed [WIDTH_P-1:0] weight_q;
    logic signed [WIDTH_P-1:0] a_q;
    logic signed [(2*WIDTH_P):0] b_q;
    logic signed [(2*WIDTH_P)-1:0] product_l;
    logic signed [(2*WIDTH_P)-1:0] product_q;
    logic signed [(2*WIDTH_P):0] sum_l;

    logic [0:0] valid_q;
    logic [0:0] ready_q;

    elastic elastic_mult_inst (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .valid_i(valid_i && !load_i),
        .ready_o(ready_o),
        .valid_o(valid_q),
        .ready_i(ready_q)
    );

    elastic elastic_add_inst (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .valid_i(valid_q),
        .ready_o(ready_q),
        .valid_o(valid_o),
        .ready_i(ready_i)
    );

    always_comb begin
        // mult
        product_l = a_i * weight_q;
        //add
        sum_l = {product_q[(2*WIDTH_P)-1], product_q} + b_q;
    end

    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            weight_q <= '0;
        end else if (load_i) begin
            weight_q <= weight_i;
        end
    end

    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            a_q <= '0;
            b_q <= '0;
            product_q <= '0;
        end else if (valid_i && ready_o && !load_i) begin
            // acc = (streamed operand * local weight) + stream partial
            // align partial sum delay
            a_q <= a_i;
            b_q <= b_i;
            product_q <= product_l;
        end
    end

    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            c_o <= '0;
            d_o <= '0;
        end else if (valid_q && ready_q) begin
            c_o <= a_q;
            d_o <= sum_l;
        end
    end

endmodule