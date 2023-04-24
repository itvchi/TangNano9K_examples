module lfsr #(parameter SEED = 5'd1,
            TAPS = 5'h1B,
            NUM_BITS = 5)
            (input i_clk,
            output reg o_randomBit);

reg [(NUM_BITS-1):0] r_shiftRegister = SEED;

wire w_finalFeedback;

always @(posedge i_clk) 
begin
    r_shiftRegister <= {r_shiftRegister[(NUM_BITS-2):0], w_finalFeedback};
    o_randomBit <= r_shiftRegister[NUM_BITS-1];
end

genvar i;
generate
    for(i=0; i<NUM_BITS; i=i+1)
    begin: lf //linear feedback
        wire w_feedback;
        if(i == 0)
            assign w_feedback = r_shiftRegister[i] & TAPS[i];
        else
            assign w_feedback = lf[i-1].w_feedback ^ (r_shiftRegister[i] & TAPS[i]);
    end
endgenerate

assign w_finalFeedback = lf[NUM_BITS-1].w_feedback;

endmodule