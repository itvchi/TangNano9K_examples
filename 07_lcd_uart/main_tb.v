`timescale 10ns/1ns
`include "clock_divider.v"
`include "lcd.v"
`include "textEngine.v"
`include "main.v"
`include "uartRX.v"
`include "uartRow.v"
`include "binaryRow.v"
`include "counter.v"
`include "toHex.v"
`include "hexDecRow.v"
`include "toDec.v"
`include "progressbarRow.v"

module main_tb ();

reg r_clk;
reg r_rx;

wire w_rst;
wire w_cs;
wire w_dc;
wire w_clk;
wire w_data;


main UUT (.i_clk(r_clk), .o_rst(w_rst), .o_cs(w_cs), .o_dc(w_dc), .o_clk(w_clk), .o_data(w_data), .i_rx(r_rx));

always #2 r_clk <= ~r_clk;

initial 
begin
    r_clk <= 1'b0; //clock initial value
    r_rx <= 1'b1;

    $dumpfile("main_tb.vcd");
    $dumpvars(0, main_tb);

    #50000;
    
    #10 r_rx = 0; //start bit
    #868 r_rx = 1;
    #868 r_rx = 1;
    #868 r_rx = 1;
    #868 r_rx = 1;
    #868 r_rx = 1;
    #868 r_rx = 1;
    #868 r_rx = 1;
    #868 r_rx = 0;
    #868 r_rx = 1; //stop bit

    #5000000; //50ms
    #10000 $finish();  


end

endmodule