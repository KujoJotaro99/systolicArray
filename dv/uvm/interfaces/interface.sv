// interface collection

interface pe_intf(input logic [0:0] clk_i);
    logic [0:0] rstn_i;
    logic [0:0] load_i;
    logic [0:0] advance_i;
    logic [0:0] valid_i;
    logic [0:0] valid_o;

    logic signed [7:0] a_i;
   	logic signed [18:0] b_i;
   	logic signed [7:0] weight_i;
   	logic signed [7:0] c_o;
   	logic signed [18:0] d_o;

endinterface
