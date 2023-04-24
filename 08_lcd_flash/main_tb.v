`timescale 10ns/1ns
`include "clock_divider.v"
`include "lcd.v"
`include "textEngine.v"
`include "main.v"
`include "flash.v"
`include "toHex.v"

module main_tb ();

reg r_clk;
reg MISO;
reg btn1, btn2;

wire w_rst;
wire w_cs;
wire w_dc;
wire w_clk;
wire w_data;

wire CLK;
wire MOSI;
wire CS;

main UUT (.i_clk(r_clk),
        .o_rst(w_rst),
        .o_cs(w_cs),
        .o_dc(w_dc),
        .o_clk(w_clk),
        .o_data(w_data),
        .i_flashMISO(MISO),
        .o_flashCLK(CLK),
        .o_flashMOSI(MOSI),
        .o_flashCS(CS),
        .i_btn1(btn1),
        .i_btn2(btn2));

always #2 r_clk <= ~r_clk;

initial 
begin
    r_clk <= 1'b0; //clock initial value
    MISO <= 1'b0;
    btn1 <= 1'b1; 
    btn2 <= 1'b1;

    $dumpfile("main_tb.vcd");
    $dumpvars(0, main_tb);

    #50000;

    #15000000; //150ms
    #10000 $finish();  


end

endmodule