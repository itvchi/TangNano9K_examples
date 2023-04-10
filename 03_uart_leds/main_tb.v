`timescale 10ns/1ns
`include "main.v"
`include "uart.v"
`include "clock_divider.v"

module main_tb();

reg r_clk;
reg r_rx;
wire w_tx;

main UUT (.i_clk(r_clk), .i_rx(r_rx), .o_tx(w_tx));

always #2 r_clk = ~r_clk; 

initial
begin
    r_clk = 0;
    r_rx = 1;

    $dumpfile("main_tb.vcd");
    $dumpvars(0, main_tb);

    #1000;
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
    #10000;
    #100 r_rx = 0; //start bit
    #868 r_rx = 1;
    #868 r_rx = 1;
    #868 r_rx = 1;
    #868 r_rx = 1;
    #868 r_rx = 1;
    #868 r_rx = 1;
    #868 r_rx = 1;
    #868 r_rx = 0;
    #868 r_rx = 1; //stop bit
    #10000 $finish();
end


endmodule