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

reg [7:0]   buffer [0:1023];	// BRAM
reg	[9:0]   cursor_ptr = 10'd0;
reg         refresh = 0;
reg [1:0]   refresh_state = REFRESH1;
reg	[9:0]   buffer_ptr = 10'd0;

always @(posedge clk) begin
	if (rst) begin
        cursor_ptr <= 0;
    end else if (o_serial_v) begin
        o_serial_v <= 0;
    end else if (refresh) begin
        case (refresh_state)
        REFRESH1: begin
            buffer_ptr <= 0;
            refresh_state <= REFRESH2;
        end
        REFRESH2: begin
            buffer_ptr <= buffer_ptr + 1;
            o_serial <= buffer[buffer_ptr];
            o_serial_v <= 1;
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
            o_serial <= buffer[cursor_ptr];
            o_serial_v <= 1;
        end
        "k": begin //up
            cursor_ptr <= cursor_ptr - 10'd40;
            o_serial <= buffer[cursor_ptr];
            o_serial_v <= 1;
        end
        "h": begin //left
            cursor_ptr <= cursor_ptr - 10'd1;
            o_serial <= buffer[cursor_ptr];
            o_serial_v <= 1;
        end
        "l": begin //right
            cursor_ptr <= cursor_ptr + 10'd1;
            o_serial <= buffer[cursor_ptr];
            o_serial_v <= 1;
        end
        " ": begin //right
            refresh <= 1'd1;
        end
        default: begin
                //do nothing
        end
        endcase
    end // if
end // always

initial begin
`include "buffer.v"
end
endmodule
