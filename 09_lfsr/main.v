module main (input i_clk,
            output o_rst,
            output o_cs,
            output o_dc,
            output o_clk,
            output o_data);

wire w_clk;
clock_divider #(.INPUT_CLOCK(27000000), 
                .OUTPUT_CLOCK(1000000)) 
clk_div (.i_clk(i_clk), 
        .o_clk(w_clk));

wire [9:0] w_pixelAddress;
wire [7:0] w_pixelData;

lcd #(.INPUT_CLOCK_HZ(1000000), 
    .RESET_TIME_US(1000))
oled (.i_clk(w_clk),
    .o_rst(o_rst),
    .o_cs(o_cs),
    .o_dc(o_dc),
    .o_clk(o_clk),
    .o_data(o_data),
    .o_pixelAddress(w_pixelAddress),
    .i_pixelData(w_pixelData));

wire w_randomBit;

lfsr  #(.SEED(32'd1),
        .TAPS(32'h80000412),
        .NUM_BITS(32))
    UUT1 (.i_clk(i_clk),
        .o_randomBit(w_randomBit));

reg [3:0] r_tempBuffer;

always @(posedge i_clk) 
begin
    r_tempBuffer <= {r_tempBuffer[2:0], w_randomBit};    
end

/* Generate graph from random generated numbers */
localparam NUM_BITS_STORAGE = 8*128; //128 colums, 8bit each
reg [(NUM_BITS_STORAGE-1):0] r_graphStorage = 0;

reg [7:0] r_graphValue = 127;
reg [6:0] r_graphColumnIdx = 0;
reg [19:0] r_delayCounter;

always @(posedge i_clk) 
begin
    if(r_delayCounter == 20'd900000) /* Every ~33ms - 30FPS */ 
    begin
        if(r_tempBuffer != 4'd15) //ignore value 15, which is 8 in adjusted range (so adjusted range is -7 to 7)
            r_graphValue <= r_graphValue + r_tempBuffer - 8'd7; //adjust range -7 to 8

        r_delayCounter <= 0;
        r_graphStorage[({3'd0, r_graphColumnIdx} << 3)+:8] <= r_graphValue;
        r_graphColumnIdx <= r_graphColumnIdx + 1;
    end
    else
        r_delayCounter <= r_delayCounter + 1;    
end

/* Draw graph data */
wire [6:0] w_xCord;
wire [2:0] w_yCord;

assign w_xCord = w_pixelAddress[6:0] + r_graphColumnIdx;
assign w_yCord = 3'd7 - w_pixelAddress[9:7]; //7 rows (adjusted to 0 at bottom of the screen)

wire [7:0] w_currentGraphValue;
wire [5:0] w_maxYHeight;

assign w_currentGraphValue = r_graphStorage[({3'd0, w_xCord} << 3)+:8];
assign w_maxYHeight = w_currentGraphValue[7:2];

always @(posedge i_clk) 
begin
    w_pixelData[0] <= ({w_yCord, 3'd7} < w_maxYHeight); 
    w_pixelData[1] <= ({w_yCord, 3'd6} < w_maxYHeight); 
    w_pixelData[2] <= ({w_yCord, 3'd5} < w_maxYHeight); 
    w_pixelData[3] <= ({w_yCord, 3'd4} < w_maxYHeight); 
    w_pixelData[4] <= ({w_yCord, 3'd3} < w_maxYHeight); 
    w_pixelData[5] <= ({w_yCord, 3'd2} < w_maxYHeight); 
    w_pixelData[6] <= ({w_yCord, 3'd1} < w_maxYHeight); 
    w_pixelData[7] <= ({w_yCord, 3'd0} < w_maxYHeight);      
end

endmodule