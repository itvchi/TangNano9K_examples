module uartRX #(parameter INPUT_CLOCK = 27000000,
            parameter BAUD_RATE = 9600)
            (input i_clk,
            input i_RX,
            output reg [7:0] o_RX_Data,
            output reg o_RX_DataValid);

wire w_clk;
clock_divider #(.INPUT_CLOCK(INPUT_CLOCK), .OUTPUT_CLOCK(2*BAUD_RATE)) clk_div (.i_clk(i_clk), .o_clk(w_clk));

reg [3:0] r_RX_State;
reg [7:0] r_RX_Data;
reg [2:0] r_RX_DataBit;

initial
begin
    r_RX_State <= RX_STATE_IDLE;
    r_RX_Data <= 0;
    r_RX_DataBit <= 0;
end

localparam RX_STATE_IDLE = 3'd0,
RX_STATE_START_BIT = 3'd1,
RX_STATE_READ = 3'd2,
RX_STATE_WAIT = 3'd3,
RX_STATE_STOP_BIT = 3'd4;

//Receiver block
always @(posedge w_clk) 
begin
    o_RX_DataValid <= 1'b0; //default assignment

    case (r_RX_State)
        RX_STATE_IDLE:
        begin 
            r_RX_DataBit = 3'd0; //default assignment

            if(i_RX == 1'b0) //wait for start bit
                r_RX_State <= RX_STATE_START_BIT;
            else
                r_RX_State <= RX_STATE_IDLE;
        end
        RX_STATE_START_BIT: //state for 1 clock delay
        begin
            r_RX_State <= RX_STATE_READ;
        end
        RX_STATE_READ: //shift data bit to register
        begin
            r_RX_Data <= {i_RX, r_RX_Data[7:1]};
            r_RX_DataBit <= r_RX_DataBit + 3'd1;

            if(r_RX_DataBit == 3'b111) //end after 7th bit
                r_RX_State <= RX_STATE_STOP_BIT;
            else
                r_RX_State <= RX_STATE_WAIT;
        end
        RX_STATE_WAIT: //wait 1 clock cycle
        begin
            r_RX_State <= RX_STATE_READ;
        end
        RX_STATE_STOP_BIT: //toggle data valid for 1 clock
        begin
            o_RX_DataValid <= 1'b1;
            o_RX_Data <= r_RX_Data;
            r_RX_State <= RX_STATE_IDLE;
        end
        default: 
            r_RX_State <= RX_STATE_IDLE;
    endcase
end
endmodule