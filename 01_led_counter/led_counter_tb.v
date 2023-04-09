`timescale 10ns/1ns
`include "clock_divider.v"
`include "led_counter.v"

module led_counter_tb();

reg r_clk;
wire [5:0] w_leds;

led_counter UUT (.i_clk(r_clk), .o_leds(w_leds));

always #2 r_clk = ~r_clk;

initial 
begin
    r_clk = 0;    

    $dumpfile("led_counter_tb.vcd");
    $dumpvars(0, led_counter_tb);

    #20000;

    $finish;

end


endmodule