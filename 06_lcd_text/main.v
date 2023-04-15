module main (input i_clk,
            output o_rst,
            output o_cs,
            output o_dc,
            output o_clk,
            output o_data);

wire w_clk;
clock_divider #(.INPUT_CLOCK(27000000), .OUTPUT_CLOCK(1000000)) clk_div (.i_clk(i_clk), .o_clk(w_clk));

wire [9:0] w_pixelAddress;
wire [7:0] w_pixelData;

lcd #(.INPUT_CLOCK_HZ(1000000), .RESET_TIME_US(1000))
oled (.i_clk(w_clk),
    .o_rst(o_rst),
    .o_cs(o_cs),
    .o_dc(o_dc),
    .o_clk(o_clk),
    .o_data(o_data),
    .o_pixelAddress(w_pixelAddress),
    .i_pixelData(w_pixelData));

TextEngine te (.i_clk(w_clk),
                .i_pixelAddress(w_pixelAddress),
                .o_pixelData(w_pixelData));

endmodule