module buffer (
    input clk, wen,
    input [9:0] addr,
    input [7:0] wdata,
    output reg [7:0] rdata);

reg [7:0] mem [0:1023];
initial begin
    `include "buffer_contents.vh"
end

always @(posedge clk) begin
    if (wen) mem[addr] <= wdata;
    else rdata <= mem[addr];
end
endmodule
