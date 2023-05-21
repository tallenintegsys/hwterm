
module hwterm (
	input	clk48,
	input	rst,

	// serial out
	input	      inc,
	output	reg [7:0] dout,
	output  reg dout_v,
