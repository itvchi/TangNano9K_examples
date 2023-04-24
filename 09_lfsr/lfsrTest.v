module lfsrTest (input i_clk,
            output reg o_randomBit);

reg [4:0] r_shiftRegister = 5'b00001;

always @(posedge i_clk) 
begin
    r_shiftRegister <= {r_shiftRegister[3:0], r_shiftRegister[4] ^r_shiftRegister[1]};
    o_randomBit <= r_shiftRegister[4];    
end

endmodule