module counter #(parameter INPUT_CLOCK_HZ = 1000000, parameter INC_TIME_MS = 1000)
                (input i_clk,
                output [7:0] o_value);

localparam INPUT_CLOCK_mHZ = INPUT_CLOCK_HZ * 1000;
localparam LOCAL_CLOCK_mHZ = 1000 * 1000/INC_TIME_MS;

wire w_clk;
clock_divider #(.INPUT_CLOCK(INPUT_CLOCK_mHZ), .OUTPUT_CLOCK(LOCAL_CLOCK_mHZ)) clk_div (.i_clk(i_clk), .o_clk(w_clk));

reg [7:0] r_value;
initial
    r_value <= 8'd0;

always @(posedge w_clk)
begin
    r_value <= r_value + 8'd1;
end

assign o_value = r_value;

endmodule