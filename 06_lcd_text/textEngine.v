module TextEngine (input i_clk,
                    input [9:0] i_pixelAddress,
                    output [7:0] o_pixelData);

/* CHARACTER MEMORY FORMAT
    CHARACTER TOP:
        (top row, 1st byte) 
        ... 
        (top row, 8th byte) 
    CHARACTER BOTTOM:
        (bottom row, 1st byte) 
        ... 
        (bottom row, 8th byte)
    
    C0T, C1T ... C15T,
    C0B, C1B ... C15B,
    ...
*/

reg [7:0] fontBuffer [0:1535]; //96 characters x 16 bytes (character size is 16x8 - 2 rows of 8 bytes)
initial $readmemh("font.hex", fontBuffer);

/* PIXEL ADDRESS: 
    B9 B8 - character index top bits,
    B7 - top row flag (indicates row of character, 0 is top)
    B6 B5 B4 B3 - character index lower bits,
    B2 B1 B0 - column counter (indicates column of character)

    character index - display is split to 4 rows 16 characters each */
wire [5:0] w_charAddress;    
wire [2:0] w_columnAddress;    
wire w_topRow;    

/* Convert pixel address into character address and row, column position in this character */
assign w_charAddress = { i_pixelAddress[9:8], i_pixelAddress[6:3] };
assign w_columnAddress = i_pixelAddress[2:0];
assign w_topRow = !i_pixelAddress[7];

reg [7:0] r_outputBuffer;
assign o_pixelData = r_outputBuffer;

/* Check and adjust the range of selected character (not all ASCII characters are printable) */
wire [7:0] w_chosenChar; //char to print
wire [7:0] w_charNumber; //adjusted number of char (0 is space, print space if over range) 
assign w_charNumber = (w_chosenChar >= 32 && w_chosenChar <= 126) ? (w_chosenChar-32) : 0; //convert ASCII code to character number (e.g. 'A' is 65 ASCII and 33th character in memory)

/* Generate character for each line */
wire [7:0] charOutput [0:3];

textRow #(.ADDRESS_OFFSET(0))
row_1   (.i_clk(w_clk),
        .i_readAddr({ 2'b00, w_charAddress }),
        .o_outputData(charOutput[0]));

textRow #(.ADDRESS_OFFSET(16))
row_2   (.i_clk(w_clk),
        .i_readAddr({ 2'b00, w_charAddress }),
        .o_outputData(charOutput[1]));

textRow #(.ADDRESS_OFFSET(32))
row_3   (.i_clk(w_clk),
        .i_readAddr({ 2'b00, w_charAddress }),
        .o_outputData(charOutput[2]));

textRow #(.ADDRESS_OFFSET(48))
row_4   (.i_clk(w_clk),
        .i_readAddr({ 2'b00, w_charAddress }),
        .o_outputData(charOutput[3]));

assign w_chosenChar = charOutput[w_charAddress[5:4]]; //assign char output from textRow module appropriate to row selected by character address

/* Calculate character pixel column address in memory
    - w_charNumber[7:4] * 256 - get position of packet (each packet contains 8 top columns of 16 characters and 8 bottom columns of 16 characters - packet size = 2x128columns)
    - w_charNumber[3:0] * 8 - offset inside the packet of characters (point to first top column of apropriate character)
    - (topRow ? 0 : 128) - get appropriate row
    - columnAddress - get appropriate column
*/
wire [10:0] w_index;
assign w_index = w_charNumber[7:4]*256 + w_charNumber[3:0]*8 + (w_topRow ? 0 : 128) + w_columnAddress;

always @(posedge i_clk) begin
    r_outputBuffer <= fontBuffer[w_index];
end

endmodule