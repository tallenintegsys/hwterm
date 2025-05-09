module hwterm_top (
  input   CLK,      //12MHz oscillator
  output  D1,
  output  D2,
  output  D3,
  output  D4,
  output  D5,
  input   TR3,
  input   TR4,
  input   TR5,
  input   TR6,
  input   TR7,
  input   TR8,
  input   TR9,
  input   TR10,
  output  TX,   // TX
  input   RX);  // RX

assign D1 = TX_dv;
assign D2 = TX_Active;
assign D3 = TX_Done;
assign D4 = ~tx;
assign D5 = ~RX;
assign TX = tx;
assign rx = RX;
assign div = {TR3,TR4,TR5,TR6,TR7,TR8,TR9,TR10};

reg rst = 0;
wire [7:0] TX_Byte;
wire TX_dv;
wire [7:0] RX_Byte;
wire RX_dv;
wire rx;
wire tx;
wire TX_Active;
wire TX_Done;
wire [7:0]div;

termbuffer termbuffer0 (
    .clk(CLK),
    .rst(rst),
	.div(div),
    .o_byte(TX_Byte),	// byte out
    .o_byte_v(TX_dv),
	.i_tx_active(TX_Active),
	.i_tx_done(TX_Done),
    .i_byte(RX_Byte),  // byte in
    .i_byte_v(RX_dv));

uart_rx #(.CLKS_PER_BIT(12000000/115200)) uart_rx0 (
    .i_Clock(CLK),
    .i_RX_Serial(rx),
    .o_RX_DV(RX_dv),
    .o_RX_Byte(RX_Byte));

uart_tx #(.CLKS_PER_BIT(12000000/115200)) uart_tx0 (
    .i_Clock(CLK),
    .i_TX_DV(TX_dv),
    .i_TX_Byte(TX_Byte),
    .o_TX_Active(TX_Active),
    .o_TX_Serial(tx),
    .o_TX_Done(TX_Done));

endmodule
