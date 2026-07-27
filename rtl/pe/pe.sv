`timescale 1ns/1ps

module pe #(
    parameter WIDTH_P = 8
) (
    // meta interface
    input logic [0:0] clk_i,
    input logic [0:0] rstn_i,
    input logic [0:0] load_i,
    input logic [0:0] input_en_i,
    input logic [0:0] mul_en_i,
    input logic [0:0] add_en_i,
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

    always_comb begin
        // mult
        product_w = a_q * weight_q;
        //add
        sum_w = $signed({{3{product_q[(2*WIDTH_P)-1]}}, product_q}) + b_q;
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
        end else begin
            if (input_en_i) begin
                a_q <= a_i;
                b_q <= b_i;
            end

            if (mul_en_i) begin
                product_q <= product_w;
            end
        end
    end

    // add
    always_ff @(posedge clk_i) begin
        if (!rstn_i) begin
            c_o <= '0;
            d_o <= '0;
        end else if (add_en_i) begin
            c_o <= a_q;
            d_o <= sum_w;
        end
    end

endmodule
