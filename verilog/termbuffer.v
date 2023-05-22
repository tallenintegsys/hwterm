`include "buffer.v"

module termbuffer (
	input	            clk,
	input	            rst,
	output reg [7:0]    o_serial,	// serial out
    output reg          o_serial_v,
	input [7:0]         i_serial,  // serial in
	input	            i_serial_v);

localparam REFRESH1 = 2'd1;
localparam REFRESH2 = 2'd2;
localparam REFRESH3 = 2'd3;

reg	[9:0]   cursor_ptr = 10'd288;
reg         refresh = 0;
reg [1:0]   refresh_state = REFRESH1;
reg	[9:0]   buffer_ptr = 10'd0;
reg         tb_wen = 0;
reg [9:0]   tb_addr = 0;
reg [7:0]   tb_wdata = 0;
wire [7:0]  tb_rdata;

buffer text_buffer0 (
    .clk(clk),
    .wen(tb_wen),
    .addr(tb_addr),
    .wdata(tb_wdata),
    .rdata(tb_rdata));

always @(posedge clk) begin
	if (rst) begin
        cursor_ptr <= 0;
    end else if (o_serial_v) begin
        o_serial_v <= 0;
    end else if (ready) begin
        o_serial <= tb_rdata;
        o_serial_v <= 1;
        ready <= 0;
    end else if (refresh) begin
        case (refresh_state)
        REFRESH1: begin
            buffer_ptr <= 0;
            refresh_state <= REFRESH2;
        end
        REFRESH2: begin
            buffer_ptr <= buffer_ptr + 1;
            tb_addr <= buffer_ptr;
            tb_wen <= 0;
            if (buffer_ptr == 10'd1023)
                refresh_state <= REFRESH3;
        end
        REFRESH3: begin
            refresh <= 0;
            refresh_state <= REFRESH1;
        end
        default:
            refresh_state <= REFRESH1;
        endcase
    end else if (i_serial_v) begin
        case (i_serial)
        "j": begin //down
            cursor_ptr <= cursor_ptr + 10'd40;
            tb_addr <= cursor_ptr;
            tb_wen <= 0;
        end
        "k": begin //up
            cursor_ptr <= cursor_ptr - 10'd40;
            tb_addr <= cursor_ptr;
            tb_wen <= 0;
        end
        "h": begin //left
            cursor_ptr <= cursor_ptr - 10'd1;
            tb_addr <= cursor_ptr;
            tb_wen <= 0;
        end
        "l": begin //right
            cursor_ptr <= cursor_ptr + 10'd1;
            tb_addr <= cursor_ptr;
            tb_wen <= 0;
        end
        " ": begin //right
            //refresh <= 1'd1;
        end
        default: begin
                //do nothing
        end
        endcase
        ready <= 1;
    end // if
end // always

endmodule
