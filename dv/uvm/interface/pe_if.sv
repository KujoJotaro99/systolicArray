interface pe_if #(
	parameter WIDTH_P = 8
) (
	input logic [0:0] clk_i
);

	logic [0:0] rstn_i;
	logic [0:0] load_i;
	logic [0:0] input_en_i;
	logic [0:0] mul_en_i;
	logic [0:0] add_en_i;

	logic signed [WIDTH_P-1:0] a_i;
	logic signed [(2*WIDTH_P)+2:0] b_i;
	logic signed [WIDTH_P-1:0] weight_i;

	logic signed [WIDTH_P-1:0] c_o;
	logic signed [(2*WIDTH_P)+2:0] d_o;

endinterface
