`timescale 10ns/1ns
`include "lfsrTest.v"

module lfsrTest_tb ();

reg r_clk;
wire w_randomBit;

always #5 r_clk <= ~r_clk;

lfsrTest UUT (.i_clk(r_clk),
        .o_randomBit(w_randomBit));

initial 
begin
    r_clk <= 0;

    $dumpfile("lfsrTest_tb.vcd");
    $dumpvars(0, lfsrTest_tb);

    #1000 $finish;    
end

reg [2:0] r_tempBuffer = 0;
reg [1:0] r_counter = 0;
reg [2:0] r_value;

always @(posedge r_clk) 
begin
    if(r_counter == 3)
        r_value <= r_tempBuffer;

    r_counter <= r_counter + 1;
    r_tempBuffer <= {r_tempBuffer[1:0], w_randomBit};
end

endmodule