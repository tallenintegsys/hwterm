module termbuffer (
	input	            clk,
	input	            rst,
	output reg [7:0]    o_byte,	// serial out
    output reg          o_byte_v,
    input               i_byte_done,
	input [7:0]         i_byte,  // serial in
	input	            i_byte_v);

localparam CMD_NONE = 0;
localparam CMD_CURSOR = 1;
localparam CMD_REFRESH = 2;
reg [1:0] cmd = CMD_NONE;

localparam CURSOR0 = 0;
localparam CURSOR1 = 1;
localparam CURSOR2 = 2;
reg [1:0] cursor = CURSOR0;

localparam REFRESH0 = 0;
localparam REFRESH1 = 1;
localparam REFRESH2 = 2;
reg [3:0] refresh = REFRESH0;

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
            if (i_byte_done) cursor <= CURSOR2;
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
            if (i_byte_done) refresh <= REFRESH2;
        end
        REFRESH2: begin
            tb_addr <= tb_addr + 1;
            refresh <= REFRESH0;
            if (tb_addr == 271) cmd <= CMD_NONE;
       end
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
