`include "uart_rx.v"
module uart_rx_tb;

reg     i_Clock             = 0;
reg     i_RX_Serial         = 1'd1;
wire    o_RX_DV;
wire    [7:0] o_RX_Byte;
reg     [7:0] test          = 0;

uart_rx #(.CLKS_PER_BIT(4)) uut (
    .i_Clock,
    .i_RX_Serial,
    .o_RX_DV,
    .o_RX_Byte);

initial begin
    $dumpfile("uart_rx.vcd");
    $dumpvars;
    #21 i_RX_Serial = 1'd1; // idle
    #13 i_RX_Serial = 1'd0; // start
    #8 i_RX_Serial = 1'd1; // 0
    #8 i_RX_Serial = 1'd0; // 1
    #8 i_RX_Serial = 1'd1; // 2
    #8 i_RX_Serial = 1'd0; // 3
    #8 i_RX_Serial = 1'd1; // 4
    #8 i_RX_Serial = 1'd0; // 5
    #8 i_RX_Serial = 1'd1; // 6
    #8 i_RX_Serial = 1'd0; // 7
    #8 i_RX_Serial = 1'd1; // stop
    #8 i_RX_Serial = 1'd1; // idle
    #13;
    if (o_RX_Byte != 8'h55)
            $display("*** fail,  expected 0x55");

    #20 i_RX_Serial = 1'd1; // idle
    #13 i_RX_Serial = 1'd0; // start
    #8 i_RX_Serial = 1'd1; // 0
    #8 i_RX_Serial = 1'd0; // 1
    #8 i_RX_Serial = 1'd1; // 2
    #8 i_RX_Serial = 1'd0; // 3
    #8 i_RX_Serial = 1'd1; // 4
    #8 i_RX_Serial = 1'd0; // 5
    #8 i_RX_Serial = 1'd1; // 6
    #8 i_RX_Serial = 1'd0; // 7
    #8 i_RX_Serial = 1'd1; // stop
    #8 i_RX_Serial = 1'd1; // idle
    #13;
    if (o_RX_Byte != 8'h55)
            $display("*** fail,  expected 0x55");
    
    #15
    for (test = "A"; test < "z"; test = test + 1) begin
        #20 i_RX_Serial = 1'd1; // idle
        #13 i_RX_Serial = 1'd0; // start
        #8 i_RX_Serial = test[0]; // 0
        #8 i_RX_Serial = test[1]; // 1
        #8 i_RX_Serial = test[2]; // 2
        #8 i_RX_Serial = test[3]; // 3
        #8 i_RX_Serial = test[4]; // 4
        #8 i_RX_Serial = test[5]; // 5
        #8 i_RX_Serial = test[6]; // 6
        #8 i_RX_Serial = test[7]; // 7
        #8 i_RX_Serial = 1'd1; // stop
        #8 i_RX_Serial = 1'd1; // idle
        #13;
        if (o_RX_Byte != test)
            $display("*** fail:%c %c data=%b, should be %b",test, o_RX_Byte, o_RX_Byte, test);
        #11;
    end
    $finish;
end // initial

always begin
    #1 i_Clock = !i_Clock;
end // always
endmodule
