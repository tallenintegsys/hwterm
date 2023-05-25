module termbuffer_tb;

reg         clk             = 0;
reg         rst             = 0;
wire [7:0]  o_byte;
wire        o_byte_v;
reg         i_byte_done = 0;
reg [7:0]   i_byte = 0;
reg         i_byte_v = 0;

termbuffer uut (
    .clk,
    .rst,
    .o_byte,
    .o_byte_v,
    .i_byte_done,
    .i_byte,
    .i_byte_v);

integer i = 0;
initial begin
    $dumpfile("termbuffer.vcd");
    $dumpvars;
    rst = 1;
    #50 rst = 0;

    /*
    #10 i_byte = "l";
    for (i=0; i < 1024; i = i + 1) begin
        #20 i_byte_v = 1;
        #20 i_byte_v = 0;
        while (o_byte_v == 0) #1;
        if (o_byte == 8'h1b) $write("%c%c%c",8'he2,8'h90,8'h9b);
        else if (o_byte == 8'h0d) $write("%c", o_byte);
        else if (o_byte == 8'h0a) $write("%c", o_byte);
        else if (o_byte == 8'h20) $write("%c", o_byte);
        else if (o_byte < "0") $write("%x", o_byte);
        else $write("%c", o_byte);
        #10 i_byte_done = 1;
        #10 i_byte_done = 0;
    end
*/
    i_byte = " ";
    #1 i_byte_v = 1;
    #1 i_byte_v = 0;
    for (i=0; i < 271; i = i + 1) begin
        while (o_byte_v == 0) #1;
        //if (o_byte == 8'h1b) $write("%c%c%c",8'he2,8'h90,8'h9b);
        if (o_byte == 8'h1b) $write("%c", o_byte);
        else if (o_byte == 8'h0d) $write("%c", o_byte);
        else if (o_byte == 8'h0a) $write("%c", o_byte);
        else if (o_byte == 8'h20) $write("%c", o_byte);
        else if (o_byte < "0") $write("%x", o_byte);
        else $write("%c", o_byte);
        #10 i_byte_done = 1;
        #10 i_byte_done = 0;
    end

    $display();
    $display("%c%c%c%c",8'hf0,8'h9f,8'h8d,8'hba); // beer
    $finish;
end // initial

always begin
    #10 clk = !clk;
end // always
endmodule
