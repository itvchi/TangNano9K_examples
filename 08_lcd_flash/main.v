module main (input i_clk,
            output o_rst,
            output o_cs,
            output o_dc,
            output o_clk,
            output o_data,
            input i_flashMISO,
            output o_flashCLK,
            output o_flashMOSI,
            output o_flashCS,
            input i_btn1,
            input i_btn2);

wire w_clk;
clock_divider #(.INPUT_CLOCK(27000000), 
                .OUTPUT_CLOCK(1000000)) 
clk_div (.i_clk(i_clk), 
        .o_clk(w_clk));

wire [9:0] w_pixelAddress;
wire [7:0] w_textPixelData;
wire [5:0] w_charAddress;
wire [7:0] w_character;

/* Read buttons */
reg r_btn1 = 1, r_btn2 = 1;
always @(negedge i_clk) 
begin
    r_btn1 <= i_btn1 ? 1 : 0;
    r_btn2 <= i_btn2 ? 1 : 0;    
end

lcd #(.INPUT_CLOCK_HZ(1000000), 
    .RESET_TIME_US(1000))
oled (.i_clk(w_clk),
    .o_rst(o_rst),
    .o_cs(o_cs),
    .o_dc(o_dc),
    .o_clk(o_clk),
    .o_data(o_data),
    .o_pixelAddress(w_pixelAddress),
    .i_pixelData(w_textPixelData));

TextEngine te (.i_clk(w_clk),
                .i_pixelAddress(w_pixelAddress),
                .o_pixelData(w_textPixelData),
                .i_character(w_character),
                .o_charAddress(w_charAddress));

flashNavigator fn (.i_clk(i_clk),
                .i_flashMISO(i_flashMISO),
                .o_flashCLK(o_flashCLK),
                .o_flashMOSI(o_flashMOSI),
                .o_flashCS(o_flashCS),
                .i_charAddress(w_charAddress),
                .o_character(w_character),
                .i_btn1(r_btn1),
                .i_btn2(r_btn2));
endmodule