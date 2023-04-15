`timescale 10ns/1ns
`include "clock_divider.v"
`include "lcd.v"
`include "textEngine.v"
`include "textRow.v"
`include "main.v"

module main_tb ();

reg r_clk;
wire w_rst;
wire w_cs;
wire w_dc;
wire w_clk;
wire w_data;

main UUT (.i_clk(r_clk), .o_rst(w_rst), .o_cs(w_cs), .o_dc(w_dc), .o_clk(w_clk), .o_data(w_data));

always #2 r_clk <= ~r_clk;

initial 
begin
    r_clk <= 1'b0; //clock initial value

    $dumpfile("main_tb.vcd");
    $dumpvars(0, main_tb);

    #5000000 $finish();    
end

endmodule