module buffer (
    input clk, ren, wen,
	input [9:0] raddr,
    input [9:0] waddr,
    input [7:0] wdata,
    output reg [7:0] rdata);

reg [7:0] mem [1023:0];
initial begin
    `include "buffer_contents.vh"
end

always @(posedge clk) begin
    if (ren) rdata <= mem[raddr];
end

always @(posedge clk) begin
    if (wen) mem[waddr] <= wdata;
end
endmodule
