module termbuffer (
	input	            clk,
	input	            rst,
	output reg [7:0]    o_serial,	// serial out
    output reg          o_serial_v,
	input [7:0]         i_serial,  // serial in
	input	            i_serial_v);

localparam REFRESH0 = 2'd0;
localparam REFRESH1 = 2'd1;
localparam REFRESH2 = 2'd2;
localparam REFRESH3 = 2'd3;
reg [1:0] refresh_state = REFRESH1;

localparam CMD_S0 = 1'd0;
localparam CMD_S1 = 1'd1;
reg        cmd_state = 0;

reg [7:0]  buffer [0:1023];	// BRAM
reg [9:0]  buffer_addr = 0;
reg [7:0]  buffer_data = 0;
initial begin
`include "buffer.v"
end

reg	[9:0]   cursor_ptr = 0;
reg         refresh = 0;
reg	[9:0]   refresh_ptr = 0;

always @(posedge clk) begin
	if (rst) begin
        cursor_ptr <= 0;
    end else if (o_serial_v) begin
        o_serial_v <= 0;
    end else if (refresh) begin
        case (refresh_state)
            REFRESH0: begin
                refresh_ptr <= 0;
                refresh_state <= REFRESH1;
            end // REFRESH0
            REFRESH1: begin
                refresh_ptr <= refresh_ptr + 1;
                buffer_addr <= refresh_ptr;
                buffer_data <= buffer[buffer_addr];
                refresh_state <= REFRESH2;
            end // REFRESH1
            REFRESH2: begin
                o_serial <= buffer_data;
                o_serial_v <= 1;
                if (refresh_ptr != 10'd1023)
                    refresh_state <= REFRESH1;
                else
                    refresh_state <= REFRESH3;
            end // REFRESH2
            REFRESH3: begin
                refresh <= 0;
                refresh_state <= REFRESH0;
            end // REFRESH3
        endcase // refresh_state
    end else if (i_serial_v) begin
        case (cmd_state)
            CMD_S0: begin
                case (i_serial)
                    "j": begin //down
                        cursor_ptr <= cursor_ptr + 10'd40;
                        buffer_addr <= cursor_ptr;
                        buffer_data <= buffer[buffer_addr];
                    end // j
                    "k": begin //up
                        cursor_ptr <= cursor_ptr - 10'd40;
                        buffer_addr <= cursor_ptr;
                        buffer_data <= buffer[buffer_addr];
                    end // k
                    "h": begin //left
                        cursor_ptr <= cursor_ptr - 10'd1;
                        buffer_addr <= cursor_ptr;
                        buffer_data <= buffer[buffer_addr];
                    end // h
                    "l": begin //right
                        cursor_ptr <= cursor_ptr + 10'd1;
                        buffer_addr <= cursor_ptr;
                        buffer_data <= buffer[buffer_addr];
                    end // l
                    " ": begin //right
                        refresh <= 1'd1;
                    end // ""
                    default: begin
                            //do nothing
                    end //default
                endcase //i_serial
                cmd_state <= CMD_S1;
            end // CMD_S0
            CMD_S1: begin
                o_serial <= buffer_data;
                o_serial_v <= 1;
                cmd_state <= CMD_S0;
            end // CMD_S1
        endcase // cmd_state
    end // if
end // always

endmodule
