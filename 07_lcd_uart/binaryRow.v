module binaryRow (input i_clk,
                input [7:0] i_value,
                input [3:0] i_charIndex,
                output [7:0] o_character);

reg [7:0] r_character;
assign o_character = r_character;

wire [2:0] r_bitNumber;
assign r_bitNumber = i_charIndex - 5; //binary value is printed starting at 6th character

always @(posedge i_clk)
begin
    case(i_charIndex)
        0: r_character <= "B";
        1: r_character <= "i";
        2: r_character <= "n";
        3: r_character <= ":";
        4: r_character <= " ";
        13, 14,15: r_character <= " ";
        default: r_character <= (i_value[7 - r_bitNumber]) ? "1" : "0"; //print "1" or "0" depending on bit value, starting with MSB at left 
    endcase
end     


endmodule