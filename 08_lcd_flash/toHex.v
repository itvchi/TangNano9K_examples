module toHex (input [3:0] i_value,
            output [7:0] o_hexCharacter);

/* Change 4-bit i_value to ASCII number or letter depending on value */
assign o_hexCharacter = (i_value < 4'hA) ? (8'd48 + i_value) : (8'd55 + i_value);

endmodule
