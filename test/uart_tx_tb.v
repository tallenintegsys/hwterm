`include "uart_tx.v"
module uart_tx_tb;

reg     i_Clock = 0;
reg     i_TX_DV;
reg     [7:0]i_TX_Byte;
wire    o_TX_Active;
wire    o_TX_Serial;
wire    o_TX_Done;
reg     [9:0]data = 0;
reg     [7:0]test = 0;

integer i = 0;

uart_tx #(.CLKS_PER_BIT(4)) uut (
    .i_Clock,
    .i_TX_DV,
    .i_TX_Byte,
    .o_TX_Active,
    .o_TX_Serial,
    .o_TX_Done);

initial begin
    $dumpfile("uart_tx.vcd");
    $dumpvars; //(0, uut);
    //$dumpoff;
    i_TX_Byte <= 0;
    i_TX_DV <= 0;
    #15
    for (test = "A"; test < "z"; test = test + 1) begin
            i_TX_Byte <= test;
            i_TX_DV <= 1'b1;
            #2
            i_TX_DV <= 0;
            for (i = 0; i < 10; i=i+1) begin
                    #8 data <= {o_TX_Serial, data[9:1]};
            end
            #4
            if (data[8:1] != test)
                    $display("*** fail:%c %c data=%b, should be %b",test[7:0], data[8:1], data[8:1], test);
            #11;
    end
    $finish;
end

always begin
    #1 i_Clock = !i_Clock;
end
endmodule
