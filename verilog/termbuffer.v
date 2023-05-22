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
reg [1:0] refresh_state = REFRESH1;

localparam CMD_WAIT = 0;
localparam CMD_RESPOND1 = 1;
localparam CMD_RESPONDM = 1;
reg [1:0] cmd_state = CMD_WAIT;

// pointers
reg	[9:0]   cursor_ptr = 10'd288;
reg	[9:0]   buffer_ptr = 10'd0;

// test buffer
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
    end else begin
        case (cmd_state)
        CMD_WAIT: begin
            o_serial_v <= 0;
            if (i_serial_v) begin
                case (i_serial)
                "j": begin //down
                    cursor_ptr <= cursor_ptr + 10'd40;
                    tb_addr <= cursor_ptr;
                    tb_wen <= 0;
                    cmd_state <= CMD_RESPOND1;
                end
                "k": begin //up
                    cursor_ptr <= cursor_ptr - 10'd40;
                    tb_addr <= cursor_ptr;
                    tb_wen <= 0;
                    cmd_state <= CMD_RESPOND1;
                end
                "h": begin //left
                    cursor_ptr <= cursor_ptr - 10'd1;
                    tb_addr <= cursor_ptr;
                    tb_wen <= 0;
                    cmd_state <= CMD_RESPOND1;
                end
                "l": begin //right
                    cursor_ptr <= cursor_ptr + 10'd1;
                    tb_addr <= cursor_ptr;
                    tb_wen <= 0;
                    cmd_state <= CMD_RESPOND1;
                end
                " ": begin //right
                    cmd_state <= CMD_RESPONDM;
                end
                default: begin
                        //do nothing
                end
                endcase
            end // if
        end
        CMD_RESPOND1: begin
            o_serial <= tb_rdata;
            o_serial_v <= 1;
            cmd_state <= CMD_WAIT;
        end
        CMD_RESPONDM: begin
            case (refresh_state)
            REFRESH1: begin
                buffer_ptr <= 0;
                refresh_state <= REFRESH2;
            end
            REFRESH2: begin
                tb_addr <= buffer_ptr;
                buffer_ptr <= buffer_ptr + 1;
                tb_wen <= 0;
                if (buffer_ptr == 10'd1023)
                    refresh_state <= REFRESH3;
            end
            REFRESH3: begin
                refresh_state <= REFRESH1;
                cmd_state <= CMD_WAIT;
            end
            default:
                refresh_state <= REFRESH1;
            endcase
        end
        endcase
    end // if
end // always

endmodule
