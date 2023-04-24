module toDec (input i_clk,
            input [7:0] i_value,
            output reg [7:0] o_hundredsCharacter = "0",
            output reg [7:0] o_tensCharacter = "0",
            output reg [7:0] o_unitsCharacter = "0");

reg [11:0] r_valueBCD = 0; //contains i_value in BCD format
reg [7:0] r_cachedValue = 0;
reg [2:0] r_stepCounter = 0;
reg [1:0] r_State = STATE_START;

localparam STATE_START = 2'd0,
STATE_ADD3 = 2'd1,
STATE_SHIFT = 2'd2,
STATE_DONE = 2'd3;

/* Convert i_value into BCD values based on Double dabble algorithm */
always @(posedge i_clk) 
begin
    case(r_State)
    STATE_START:
    begin
        r_cachedValue <= i_value; //store i_value inside temporary register for shift operation on it
        r_stepCounter <= 4'd0; //reset r_stepCounter register
        r_valueBCD <= 12'd0; //reset r_valueBCD reagister
        r_State <= STATE_ADD3;
    end
    STATE_ADD3:
    begin
        /* Add 3 in BCD position, where value is higher or equal 5 */
        r_valueBCD <= r_valueBCD + 
            ((r_valueBCD[3:0] >= 4'd5) ? 12'd3 : 12'd0) + //add 3
            ((r_valueBCD[7:4] >= 4'd5) ? 12'd48 : 12'd0) + //add 3<<4
            ((r_valueBCD[11:8] >= 4'd5) ? 12'd768 : 12'd0); //add 3<<8
        r_State <= STATE_SHIFT;
    end
    STATE_SHIFT:
    begin
        r_valueBCD <= {r_valueBCD[10:0], r_cachedValue[7]}; //shift r_valueBCD by 1, and insert MSB of r_cachedValue to LSB of r_valueBCD
        r_cachedValue <= {r_cachedValue[6:0], 1'b0}; //also shift r_cachedValue register

        if(r_stepCounter == 3'd7)
            r_State <= STATE_DONE;
        else
        begin
            r_stepCounter <= r_stepCounter + 2'd1;
            r_State <= STATE_ADD3;
        end
    end
    STATE_DONE:
    begin
        /* Convert BCD into ASCII character */
        o_hundredsCharacter <= 8'd48 + r_valueBCD[11:8];
        o_tensCharacter <= 8'd48 + r_valueBCD[7:4];
        o_unitsCharacter <= 8'd48 + r_valueBCD[3:0];
        r_State <= STATE_START;
    end
    default:
        r_State <= STATE_START;
    endcase
end

endmodule