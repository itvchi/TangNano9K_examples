module main(input i_clk,
            input i_rx,
            output o_tx,
            output [5:0] o_leds);

wire w_clk;

wire w_RX_DataValid;
wire [7:0] w_RX_Data;
reg r_TX_DataValid;
reg [7:0] r_TX_Data;
wire w_busy;

initial
begin
    r_TX_DataValid = 0;
    r_TX_Data = 0;
end

uart #(.INPUT_CLOCK(27000000), .BAUD_RATE(9600)) uart (.i_clk(i_clk), .i_rx(i_rx), .o_RX_Data(w_RX_Data), .o_RX_DataValid(w_RX_DataValid), .o_tx(o_tx), .i_TX_Data(r_TX_Data), .i_TX_DataValid(r_TX_DataValid), .o_busy(w_busy));
clock_divider #(.INPUT_CLOCK(27000000), .OUTPUT_CLOCK(1000000)) clk_div (.i_clk(i_clk), .o_clk(w_clk));

reg [3:0] r_State;
reg [5:0] r_leds;

initial 
begin
    r_State = STATE_IDLE;
    r_leds = 5'd0;
end

assign o_leds = r_leds; //leds are common Anode, but assigning not flipped signal, beacause of r_leds initial value problem

localparam STATE_IDLE = 3'd0,
STATE_SEND = 3'd1,
STATE_WAIT = 3'd2;

always @(posedge w_clk) 
begin
    case (r_State)
        STATE_IDLE:
        begin
            //default assignment
            r_TX_DataValid <= 1'b0;

            if(r_RX_DataValid == 2'b01 && w_busy == 1'b0) //when received data
            begin
                if((w_RX_Data > "0") && (w_RX_Data <= "6"))
                begin
                    r_leds[w_RX_Data - 'h31] = ~r_leds[w_RX_Data - 'h31];
                    r_State <= STATE_IDLE;
                end
                else
                begin
                    r_TX_Data <= w_RX_Data;
                    r_State <= STATE_SEND;
                end
            end
            else
                r_State <= STATE_IDLE;
        end
        STATE_SEND:
        begin
            r_TX_DataValid <= 1'b1;
            if(w_busy == 1'b1)
                r_State <= STATE_WAIT;
            else
                r_State <= STATE_SEND;
        end 
        STATE_WAIT:
        begin
            r_TX_DataValid <= 1'b0;
            if(w_busy == 1'b1)
                r_State <= STATE_WAIT;
            else
                r_State <= STATE_IDLE;
        end
        default:
            r_State <= STATE_IDLE; 
    endcase
end

reg [2:0] r_RX_DataValid;

always @(posedge w_clk) 
begin
    r_RX_DataValid <= {r_RX_DataValid[0], w_RX_DataValid};
end

endmodule