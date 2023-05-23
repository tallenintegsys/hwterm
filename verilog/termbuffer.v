`include "buffer.v"

module termbuffer (
	input	            clk,
	input	            rst,
	output reg [7:0]    o_serial,	// serial out
    output reg          o_serial_v,
	input [7:0]         i_serial,  // serial in
	input	            i_serial_v);

// text buffer
reg  tb_wen = 0;
reg  [9:0]tb_addr = 0;
reg  [7:0]tb_wdata = 0;
wire [7:0]tb_rdata;

buffer text_buffer0 (
    .clk(clk),
    .wen(tb_wen),
    .addr(tb_addr),
    .wdata(tb_wdata),
    .rdata(tb_rdata));

reg	 [9:0]cursor_ptr = 10'd0;
reg  refresh = 0;
reg  [2:0]send = 0;

always @(posedge clk) begin
        #1;
	if (rst) begin
        cursor_ptr <= 0;
        o_serial_v <= 0;
        o_serial <= 0;
    end else if (send != 0) begin // process output
        case (send)
        1: begin
            o_serial <= tb_rdata;
            o_serial_v <= 1;
            send <= 2;
        end
        2: begin
            o_serial_v <= 0;
            send <= 0;
        end
        endcase
    end else if (i_serial_v) begin
        case (i_serial)
        "j": begin //down
            cursor_ptr <= cursor_ptr + 10'd40;
            tb_addr <= cursor_ptr;
        end
        "k": begin //up
            cursor_ptr <= cursor_ptr - 10'd40;
            tb_addr <= cursor_ptr;
        end
        "h": begin //left
            cursor_ptr <= cursor_ptr - 10'd1;
            tb_addr <= cursor_ptr;
        end
        "l": begin //right
            cursor_ptr <= cursor_ptr + 10'd1;
            tb_addr <= cursor_ptr;
        end
        " ": begin //right
        //XXX TBD
        end
        default: begin
                //do nothing
        end
        endcase
        send <= 1;
    end // if
end // always
endmodule
