module progressbarRow (input i_clk,
                    input [7:0] i_value,
                    input [9:0] i_pixelAddress,
                    output [7:0] o_pixelData);

reg [7:0] r_pixelData;
assign o_pixelData = r_pixelData;

wire [6:0] r_column; //lcd width is 128(7 bits)
assign r_column = i_pixelAddress[6:0];

reg [7:0] r_bar, r_border;

wire w_topRow;
assign w_topRow = !i_pixelAddress[7];

localparam BAR_0_TOP = 8'b11000000,
BAR_0_BOTTOM = 8'b00000011,
BAR_1_TOP = 8'b11100000,
BAR_1_BOTTOM = 8'b00000111,
BAR_2_TOP = 8'b11100000,
BAR_2_BOTTOM = 8'b00000111,
BAR_TOP = 8'b11110000,
BAR_BOTTOM = 8'b00001111;

localparam BORDER_0_TOP = 8'b11000000,
BORDER_0_BOTTOM = 8'b00000011,
BORDER_1_TOP = 8'b00100000,
BORDER_1_BOTTOM = 8'b00000100,
BORDER_2_TOP = 8'b00100000,
BORDER_2_BOTTOM = 8'b00000100,
BORDER_TOP = 8'b00010000,
BORDER_BOTTOM = 8'b00001000;

always @(posedge i_clk) 
begin
    case(r_column)
        0, 127:
        begin
            r_bar <= w_topRow ? BAR_0_TOP : BAR_0_BOTTOM;
            r_border <= w_topRow ? BORDER_0_TOP : BORDER_0_BOTTOM;
        end
        1, 126:
        begin
            r_bar <= w_topRow ? BAR_1_TOP : BAR_1_BOTTOM;
            r_border <= w_topRow ? BORDER_1_TOP : BORDER_1_BOTTOM;
        end
        2, 125:
        begin
            r_bar <= w_topRow ? BAR_2_TOP : BAR_2_BOTTOM;
            r_border <= w_topRow ? BORDER_2_TOP : BORDER_2_BOTTOM;
        end
        default:
        begin
            r_bar <= w_topRow ? BAR_TOP : BAR_BOTTOM;
            r_border <= w_topRow ? BORDER_TOP : BORDER_BOTTOM;
        end
    endcase

    if(r_column > i_value[7:1]) //i_value varies between 0-255 and r_column has range of 0 to 127 (so LSB of i_value is insignificant)
        r_pixelData <= r_border;
    else
        r_pixelData <= r_bar;
end

endmodule