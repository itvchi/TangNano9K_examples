module main (input i_clk,
            output o_rst,
            output o_cs,
            output o_dc,
            output o_clk,
            output o_data,
            input i_rx);

wire w_clk;
clock_divider #(.INPUT_CLOCK(27000000), 
                .OUTPUT_CLOCK(1000000)) 
clk_div (.i_clk(i_clk), 
        .o_clk(w_clk));

wire [9:0] w_pixelAddress;
wire [7:0] w_textPixelData, w_progressbarPixelData, w_chosenPixelData;
wire [5:0] w_charAddress;
reg [7:0] r_character;

lcd #(.INPUT_CLOCK_HZ(1000000), 
    .RESET_TIME_US(1000))
oled (.i_clk(w_clk),
    .o_rst(o_rst),
    .o_cs(o_cs),
    .o_dc(o_dc),
    .o_clk(o_clk),
    .o_data(o_data),
    .o_pixelAddress(w_pixelAddress),
    .i_pixelData(w_chosenPixelData));

TextEngine te (.i_clk(w_clk),
                .i_pixelAddress(w_pixelAddress),
                .o_pixelData(w_textPixelData),
                .i_character(r_character),
                .o_charAddress(w_charAddress));

progressbarRow row_4 (.i_clk(i_clk),
                    .i_value(w_counterValue),
                    .i_pixelAddress(w_pixelAddress),
                    .o_pixelData(w_progressbarPixelData));

assign w_chosenPixelData = (w_rowNumber == 3) ? w_progressbarPixelData : w_textPixelData;

/* Character at first row - UART data */
wire w_RX_DataValid;
wire [7:0] w_RX_Data;

uartRX #(.INPUT_CLOCK(27000000), 
        .BAUD_RATE(9600)) 
uart    (.i_clk(i_clk), 
        .i_RX(i_rx), 
        .o_RX_Data(w_RX_Data), 
        .o_RX_DataValid(w_RX_DataValid));

wire [7:0] w_charOut1;

uartRow row_1 (.i_clk(i_clk),
            .i_RX_Data(w_RX_Data),
            .i_RX_DataValid(w_RX_DataValid),
            .i_charIndex(w_charAddress[3:0]), //char to print, selected by TextEngine
            .o_character(w_charOut1));

/* Character at second row - binary counter */
wire [7:0] w_counterValue;

counter #(.INPUT_CLOCK_HZ(1000000),
        .INC_TIME_MS(500))
cnt (.i_clk(w_clk),
    .o_value(w_counterValue));

wire [7:0] w_charOut2, w_charOut3;

binaryRow row_2 (.i_clk(i_clk),
                .i_value(w_counterValue),
                .i_charIndex(w_charAddress[3:0]), //char to print, selected by TextEngine
                .o_character(w_charOut2));

hexDecRow row_3 (.i_clk(i_clk),
                .i_value(w_counterValue),
                .i_charIndex(w_charAddress[3:0]), //char to print, selected by TextEngine
                .o_character(w_charOut3));

/* Character at specific row number */
wire [1:0] w_rowNumber;
assign w_rowNumber = w_charAddress[5:4];

always @(posedge i_clk) begin
        case (w_rowNumber)
            0: r_character <= w_charOut1;
            1: r_character <= w_charOut2;
            2: r_character <= w_charOut3;
            default: r_character <= " ";
        endcase
    end



endmodule