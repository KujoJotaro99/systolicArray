`timescale 1ns/1ps

module pe #(
    parameter WIDTH_P = 8
) (
    // meta interface
    input logic [0:0] clk_i,
    input logic [0:0] rstn_i,
    input logic [0:0] load_i,
    input logic [0:0] advance_i,
    input logic [0:0] valid_i,
    output logic [0:0] valid_o,
    // input stream
    input logic signed [WIDTH_P-1:0] a_i,
    input logic signed [(2*WIDTH_P)+2:0] b_i,
    input logic signed [WIDTH_P-1:0] weight_i,
    // output stream
    output logic signed [WIDTH_P-1:0] c_o,
    output logic signed [(2*WIDTH_P)+2:0] d_o
);

    logic signed [WIDTH_P-1:0] weight_q;
    logic signed [WIDTH_P-1:0] a_q;
    logic signed [(2*WIDTH_P)+2:0] b_q;
    logic signed [(2*WIDTH_P)-1:0] product_w;
    logic signed [(2*WIDTH_P)-1:0] product_q;
    logic signed [(2*WIDTH_P)+2:0] sum_w;
    logic [0:0] valid_q;

    always_comb begin
        // mult
        product_w = a_i * weight_q;
        //add
        sum_w = {{3{product_q[(2*WIDTH_P)-1]}}, product_q} + b_q;
    end

    // load
    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            weight_q <= '0;
        end else if (load_i) begin
            weight_q <= weight_i;
        end
    end

    // multiply
    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            a_q <= '0;
            b_q <= '0;
            product_q <= '0;
            valid_q <= '0;
        end else if (advance_i) begin
            valid_q <= valid_i && !load_i;
            if (valid_i && !load_i) begin
                // acc = (streamed operand * local weight) + streamed partial
                // align partial sum delay
                a_q <= a_i;
                b_q <= b_i;
                product_q <= product_w;
            end
        end
    end

    // add
    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            c_o <= '0;
            d_o <= '0;
            valid_o <= '0;
        end else if (advance_i) begin
            valid_o <= valid_q;
            if (valid_q) begin
                c_o <= a_q;
                d_o <= sum_w;
            end
        end
    end

endmodule
