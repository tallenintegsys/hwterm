`include "termbuffer.v"
`include "uart_rx.v"
`include "uart_tx.v"

module hwterm_top (
  input   CLK,      //12MHz oscillator
  output  D1,       // TXing
  output  D5,       // RXing  
  output  PMOD9,    // TX
  input   PMOD10);  // RX

assign D1 = TX_Active;
assign D5 = RX_dv;
assign PMOD9 = tx;
assign rx = PMOD10;

reg rst = 0;
wire [7:0] TX_Byte;
wire TX_dv;
wire [7:0] RX_Byte;
wire RX_dv;
wire rx;
wire tx;
wire TX_Active;
wire TX_Done;

termbuffer termbuffer0 (
    .clk(CLK),
    .rst(rst),
    .o_serial(TX_Byte),	// serial out
    .o_serial_v(TX_dv),
    .i_serial(RX_Byte),  // serial in
    .i_serial_v(RX_dv));

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
