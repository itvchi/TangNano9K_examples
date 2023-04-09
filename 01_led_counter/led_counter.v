module led_counter (input i_clk,
                    output [5:0] o_leds);

wire w_clk;
reg [5:0] led_cnt;

initial
begin
    led_cnt = 0;
end

clock_divider #(.INPUT_CLOCK(27000000), .OUTPUT_CLOCK(2)) clk_div (.i_clk(i_clk), .o_clk(w_clk));

always @(posedge w_clk)
begin
    led_cnt <= led_cnt + 1'd1;
end

assign o_leds = ~led_cnt; //leds are connected with common cathode

endmodule