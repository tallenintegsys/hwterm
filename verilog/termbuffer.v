module termbuffer (
	input	            clk,
	input	            rst,
	output reg [7:0]    o_byte,	// serial out
    output reg          o_byte_v,
	input				i_tx_active,
	input				i_tx_done,
	input [7:0]         i_byte,  // serial in
	input	            i_byte_v);

localparam CMD_NONE = 0;
localparam CMD_CURSOR = 1;
localparam CMD_REFRESH = 2;
localparam CMD_TAB = 3;
localparam CMD_ECHO = 4;
reg [2:0] cmd = CMD_REFRESH;

localparam CURSOR0 = 0;
localparam CURSOR1 = 1;
localparam CURSOR2 = 2;
reg [1:0] cursor = CURSOR0;

localparam REFRESH0 = 0;
localparam REFRESH1 = 1;
reg refresh = REFRESH0;

localparam TAB0 = 0;
localparam TAB1 = 1;
localparam TAB2 = 2;
localparam TAB3 = 3;
localparam TAB4 = 4;
localparam TAB5 = 5;
localparam TAB6 = 6;
localparam TAB7 = 7;
localparam TAB8 = 8;
localparam TAB9 = 9;
localparam TAB10 = 10;
localparam TAB11 = 11;
reg [3:0] tab = TAB0;

localparam ECHO0 = 0;
localparam ECHO1 = 1;
localparam ECHO2 = 2;
localparam ECHO3 = 3;
reg [1:0] echo = ECHO0;

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

reg	 [9:0]cursor_ptr = 10'd288;
reg  [2:0]send = 0;

always @(posedge clk) begin
        /* verilator lint_off STMTDLY */
        #1;
        /* verilator lint_on STMTDLY */
	if (rst) begin
        cursor_ptr <= 0;
        o_byte_v <= 0;
        o_byte <= 0;
    end else if (cmd == CMD_CURSOR) begin
        case (cursor)
        CURSOR0: begin
            o_byte <= tb_rdata;
            o_byte_v <= 1;
            cursor <= CURSOR1;
        end
        CURSOR1: begin
            o_byte_v <= 0;
            cursor <= CURSOR2;
        end
        CURSOR2: begin
            cmd <= CMD_NONE;
            cursor <= CURSOR0;
        end
        default:
            cursor <= CURSOR0;
        endcase
    end else if (cmd == CMD_REFRESH) begin
        case (refresh)
		REFRESH0: begin
			o_byte <= tb_rdata;
			o_byte_v <= 1;
			refresh <= REFRESH1;
		end
		REFRESH1: begin
			o_byte_v <= 0;
			if (i_tx_done) begin
                tb_addr <= tb_addr + 1;
				refresh <= REFRESH0;
				if (tb_addr == 0) cmd <= CMD_NONE;
			end
		end
		endcase
    end else if (cmd == CMD_TAB) begin
        case (tab)
        TAB0: begin
            o_byte <= "\033";
            o_byte_v <= 1;
            tab <= TAB1;
        end
        TAB1: begin
            o_byte_v <= 0;
            if (i_tx_done) tab <= TAB2;
        end
        TAB2: begin
            o_byte <= "[";
            o_byte_v <= 1;
            tab <= TAB3;
        end
        TAB3: begin
            o_byte_v <= 0;
            if (i_tx_done) tab <= TAB4;
        end
        TAB4: begin
            o_byte <= "\033";
            o_byte_v <= 1;
            tab <= TAB5;
        end
        TAB5: begin
            o_byte_v <= 0;
            if (i_tx_done) tab <= TAB6;
        end
        TAB6: begin
            o_byte <= "\033";
            o_byte_v <= 1;
            tab <= TAB7;
        end
        TAB7: begin
            o_byte_v <= 0;
            if (i_tx_done) tab <= TAB8;
        end
        TAB8: begin
            o_byte <= "\033";
            o_byte_v <= 1;
            tab <= TAB9;
        end
        TAB9: begin
            o_byte_v <= 0;
            if (i_tx_done) tab <= TAB10;
        end
        TAB10: begin
            o_byte <= "\033";
            o_byte_v <= 1;
            tab <= TAB11;
        end
        TAB11: begin
            o_byte_v <= 0;
            if (i_tx_done) tab <= TAB2;
        end
        endcase
    end else if (cmd == CMD_ECHO) begin
        case (echo)
        ECHO0: begin
			if (i_byte_v) begin
				o_byte <= i_byte;
				o_byte_v <= 1;
				echo <= ECHO1;
			end
        end
		ECHO1: begin
			o_byte_v <= 0;
			if (i_tx_done) echo <= ECHO0;
		end
		default:
			echo <= ECHO0;
		endcase
    end else if (i_byte_v) begin
        case (i_byte)
        "j": begin //down
            cursor_ptr <= cursor_ptr + 10'd40;
            tb_addr <= cursor_ptr;
            cmd <= CMD_CURSOR;
        end
        "k": begin //up
            cursor_ptr <= cursor_ptr - 10'd40;
            tb_addr <= cursor_ptr;
            cmd <= CMD_CURSOR;
        end
        "h": begin //left
            cursor_ptr <= cursor_ptr - 10'd1;
            tb_addr <= cursor_ptr;
            cmd <= CMD_CURSOR;
        end
        "l": begin //right
            cursor_ptr <= cursor_ptr + 10'd1;
            tb_addr <= cursor_ptr;
            cmd <= CMD_CURSOR;
        end
        " ": begin //space
            tb_addr <= 0;
            cmd <= CMD_REFRESH;
        end
        default: begin
                //do nothing
        end
        endcase
    end // if
end // always
endmodule
