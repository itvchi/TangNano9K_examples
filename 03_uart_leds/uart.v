module uart #(parameter INPUT_CLOCK = 27000000,
            parameter BAUD_RATE = 9600)
            (input i_clk,
            input i_rx,
            output reg [7:0] o_RX_Data,
            output o_RX_DataValid,
            output o_tx,
            input [7:0] i_TX_Data,
            input i_TX_DataValid,
            output o_busy);

wire w_clk;

clock_divider #(.INPUT_CLOCK(INPUT_CLOCK), .OUTPUT_CLOCK(2*BAUD_RATE)) clk_div (.i_clk(i_clk), .o_clk(w_clk));

reg [3:0] r_RX_State;
reg r_RX_DataValid;
reg [2:0] r_RX_DataBit;
reg [7:0] r_RX_Data;

initial
begin
    r_RX_State <= RX_STATE_IDLE;
    r_RX_DataValid <= 0;
    r_RX_DataBit <= 0;
    r_RX_Data <= 0;
end

localparam RX_STATE_IDLE = 3'd0,
RX_STATE_START_BIT = 3'd1,
RX_STATE_READ = 3'd2,
RX_STATE_WAIT = 3'd3,
RX_STATE_STOP_BIT = 3'd4;

//Receiver block
always @(posedge w_clk) 
begin
    case (r_RX_State)
        RX_STATE_IDLE:
        begin
            //default assignments
            r_RX_DataValid = 1'b0;
            r_RX_DataBit = 3'd0;

            if(i_rx == 1'b0) //wait for start bit
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
            r_RX_Data <= {i_rx, r_RX_Data[7:1]};
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
            r_RX_DataValid <= 1'b1;
            o_RX_Data <= r_RX_Data;
            r_RX_State <= RX_STATE_IDLE;
        end
        default: 
            r_RX_State <= RX_STATE_IDLE;
    endcase
end

assign o_RX_DataValid = r_RX_DataValid;

reg [3:0] r_TX_State;
reg [3:0] r_TX_NextState;
reg r_TX_Pin;
reg [7:0] r_TX_Data;
reg [2:0] r_TX_DataBit;
reg r_busy;

initial
begin
    r_TX_State <= TX_STATE_IDLE;
    r_TX_NextState <= TX_STATE_IDLE;
    r_TX_Pin <= 1;
    r_TX_Data <= 0;
    r_TX_DataBit <= 0;
    r_busy <= 0;
end

localparam TX_STATE_IDLE = 3'd0,
TX_STATE_START_BIT = 3'd1,
TX_STATE_DATA_BIT = 3'd2,
TX_STATE_STOP_BIT = 3'd3,
TX_STATE_WAIT = 3'd4;

//Transmitter block
always @(posedge w_clk) 
begin
    case (r_TX_State)
        TX_STATE_IDLE: 
        begin
            //default assignment
            r_TX_Pin = 1'b1;
            r_TX_DataBit = 3'd0;
            r_busy <= 1'b0;

            if(i_TX_DataValid == 1'b1)
            begin
                r_busy <= 1'b1;
                r_TX_Pin <= 1'b0;
                r_TX_Data <= i_TX_Data;
                r_TX_NextState <= TX_STATE_START_BIT;
                r_TX_State <= TX_STATE_WAIT;
            end
            else
            begin
                r_TX_State <= TX_STATE_IDLE;
            end
        end
        TX_STATE_START_BIT:
        begin
            r_TX_Pin <= r_TX_Data[r_TX_DataBit];
            r_TX_DataBit <= r_TX_DataBit + 3'd1;
            r_TX_NextState <= TX_STATE_DATA_BIT;
            r_TX_State <= TX_STATE_WAIT;
        end
        TX_STATE_DATA_BIT:
        begin
            r_TX_Pin <= r_TX_Data[r_TX_DataBit];
            r_TX_DataBit <= r_TX_DataBit + 3'd1;

            if(r_TX_DataBit == 3'b111)
                r_TX_NextState <= TX_STATE_STOP_BIT;
            else
                r_TX_NextState <= TX_STATE_DATA_BIT;

            r_TX_State <= TX_STATE_WAIT;
        end
        TX_STATE_STOP_BIT:
        begin
            r_TX_Pin <= 1'b1;
            r_TX_State <= TX_STATE_IDLE;
        end
        TX_STATE_WAIT:
        begin
            r_TX_State <= r_TX_NextState;
        end
        default: 
            r_TX_State <= TX_STATE_IDLE;
    endcase
end

assign o_tx = r_TX_Pin;
assign o_busy = r_busy;

endmodule