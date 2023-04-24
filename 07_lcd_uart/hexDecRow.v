module hexDecRow (input i_clk,
                input [7:0] i_value,
                input [3:0] i_charIndex,
                output [7:0] o_character);

reg [7:0] r_character;
assign o_character = r_character;

wire [3:0] w_hexLower, w_hexHigher;
assign w_hexLower = i_value[3:0];
assign w_hexHigher = i_value[7:4];

wire [7:0] w_charLowerNibble, w_charHigherNibble;
toHex lowerHex (.i_value(w_hexLower),
                .o_hexCharacter(w_charLowerNibble));
toHex higherHex (.i_value(w_hexHigher),
                .o_hexCharacter(w_charHigherNibble));

wire [7:0] w_charHundreds, w_charTens, w_charUnits;
toDec decimal (.i_clk(i_clk),
            .i_value(i_value),
            .o_hundredsCharacter(w_charHundreds),
            .o_tensCharacter(w_charTens),
            .o_unitsCharacter(w_charUnits));

always @(posedge i_clk)
begin
    case(i_charIndex)
        0: r_character <= "H";
        1: r_character <= "e";
        2: r_character <= "x";
        3: r_character <= ":";
        5: r_character <= w_charHigherNibble;
        6: r_character <= w_charLowerNibble;
        8: r_character <= "D";
        9: r_character <= "e";
        10: r_character <= "c";
        11: r_character <= ":";
        13: r_character <= w_charHundreds;
        14: r_character <= w_charTens;
        15: r_character <= w_charUnits;
        default: r_character <= " ";
    endcase
end     




endmodule