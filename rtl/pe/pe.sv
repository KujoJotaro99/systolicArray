`timescale 1ns/1ps

module pe #(
    parameter WIDTH_P = 8
) (
    pe_if #(.WIDTH_P(WIDTH_P)) pe_vif
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
    always_ff @(posedge pe_vif.clk_i) begin
        if (!pe_vif.rstn_i) begin
            weight_q <= '0;
        end else if (pe_vif.load_i) begin
            weight_q <= pe_vif.weight_i;
        end
    end

    // multiply
    always_ff @(posedge pe_vif.clk_i) begin
        if (!pe_vif.rstn_i) begin
            a_q <= '0;
            b_q <= '0;
            product_q <= '0;
        end else begin
            if (pe_vif.input_en_i) begin
                a_q <= pe_vif.a_i;
                b_q <= pe_vif.b_i;
            end

            if (pe_vif.mul_en_i) begin
                product_q <= product_w;
            end
        end
    end

    // add
    always_ff @(posedge pe_vif.clk_i) begin
        if (!pe_vif.rstn_i) begin
            pe_vif.c_o <= '0;
            pe_vif.d_o <= '0;
        end else if (pe_vif.add_en_i) begin
            pe_vif.c_o <= a_q;
            pe_vif.d_o <= sum_w;
        end
    end

endmodule
