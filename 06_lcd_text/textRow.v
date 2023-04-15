module textRow #(parameter ADDRESS_OFFSET = 0)
                (input i_clk,
                input [7:0] i_readAddr,
                output [7:0] o_outputData);

/* One line buffer - contains char number of each of 16 characters in a row */ 
reg [7:0] textBuffer [0:15];

/* Initialize the memory */
integer i;
initial begin
    for (i=0; i<16; i++) 
    begin
        textBuffer[i] = 48 + ADDRESS_OFFSET + i;
    end
end

assign o_outputData = textBuffer[(i_readAddr - ADDRESS_OFFSET)];

endmodule                