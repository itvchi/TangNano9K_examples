`timescale 10ns/10ns
`include "lfsr.v"

module lfsr_tb ();

reg r_clk = 0;
wire w_out1;
wire w_out2;
wire w_out3;

always #5 r_clk <= ~r_clk;

lfsr  #(.SEED(5'd1),
        .TAPS(5'h12),
        .NUM_BITS(5))
    UUT1 (.i_clk(r_clk),
        .o_randomBit(w_out1));

lfsr  #(.SEED(5'd1),
        .TAPS(5'h1B),
        .NUM_BITS(5))
    UUT2 (.i_clk(r_clk),
        .o_randomBit(w_out1));

lfsr  #(.SEED(5'd1),
        .TAPS(5'h1E),
        .NUM_BITS(5))
    UUT3 (.i_clk(r_clk),
        .o_randomBit(w_out1));

initial 
begin
    $dumpfile("lfsr_tb.vcd");
    $dumpvars(0, lfsr_tb);

    #1000 $finish;
end

endmodule