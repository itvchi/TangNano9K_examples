module lcd (input i_clk,
            output o_rst,
            output o_cs,
            output o_dc,
            output o_clk,
            output o_data);

reg r_rst;
reg r_cs;
reg r_dc;
reg r_clk;
reg r_data;

initial 
begin
    r_rst = 1; //reset inactive
    r_cs = 1; //cs inactive
    r_dc = 0;
    r_clk = 0; //CPOL = 0
    r_data = 0;    
end

assign o_rst = r_rst;
assign o_cs = r_cs;
assign o_dc = r_dc;
assign o_clk = r_clk;
assign o_data = r_data;

localparam LOCAL_CLOCK_HZ = 1000000;
wire w_clk;
clock_divider #(.INPUT_CLOCK(27000000), .OUTPUT_CLOCK(LOCAL_CLOCK_HZ)) clk_div (.i_clk(i_clk), .o_clk(w_clk));

localparam RESET_TIME_US = 1000;
localparam COUNTER_TOP = RESET_TIME_US*LOCAL_CLOCK_HZ/1000000;
localparam COUTER_BITS = $clog2(2*COUNTER_TOP);

reg [(COUTER_BITS-1):0] r_counter;
reg [2:0] r_State;

reg [6:0] r_col;
reg [2:0] r_row;

initial
begin
    r_counter = 0;
    r_State = STATE_INIT_POWER;
    r_col = 0;
    r_row = 0;
end

reg [15:0] r_TX_Data;
reg [2:0] r_TX_DataBit;

localparam STATE_INIT_POWER = 3'd0,
STATE_LOAD_INIT_CMD = 3'd1,
STATE_SEND = 3'd2,
STATE_INIT_CHECK = 3'd3,
STATE_LOAD_DATA = 3'd4,
STATE_IDLE = 3'd5;

localparam SETUP_INSTRUCTIONS = 23;
reg [((SETUP_INSTRUCTIONS * 8) - 1):0] r_startupCommands = {
    8'hAE,  // display off

    8'h81,  // contast value to 0x7F according to datasheet
    8'h7F,  

    8'hA6,  // normal screen mode (not inverted)

    8'h20,  // horizontal addressing mode
    8'h00,  

    8'hC8,  // normal scan direction

    8'h40,  // first line to start scanning from

    8'hA1,  // address 0 is segment 0

    8'hA8,  // mux ratio
    8'h3f,  // 63 (64 -1)

    8'hD3,  // display offset
    8'h00,  // no offset

    8'hD5,  // clock divide ratio
    8'h80,  // set to default ratio/osc frequency

    8'hD9,  // set precharge
    8'h22,  // switch precharge to 0x22 default

    8'hDB,  // vcom deselect level
    8'h20,  // 0x20 

    8'h8D,  // charge pump config
    8'h14,  // enable charge pump

    8'hA4,  // resume RAM content

    8'hAF   // display on

};
reg [9:0] r_commandIndex = SETUP_INSTRUCTIONS * 8; //bit after MSB of register, which contains MSB of first command

always @(posedge w_clk) 
begin
    case (r_State)
        STATE_INIT_POWER: 
        begin
            r_counter <= r_counter + 1'd1;

            if(r_counter < COUNTER_TOP)
            begin
                r_rst <= 0; //reset active
                r_State <= STATE_INIT_POWER;
            end
            else if(r_counter < 2*COUNTER_TOP)
            begin
                r_rst <= 1; //reset inactive
                r_State <= STATE_INIT_POWER;
            end
            else
            begin
                r_rst <= 1; //reset inactive
                //r_commandIndex <= SETUP_INSTRUCTIONS * 8;
                r_col <= 0;
                r_row <= 0;
                r_State <= STATE_LOAD_INIT_CMD;
            end 
        end
        STATE_LOAD_INIT_CMD:
        begin
            r_cs <= 1'b1; //chip select inactive
            r_dc <= 1'b0; //send command
            r_TX_Data <= r_startupCommands[(r_commandIndex - 1)-:8]; //-: indicate length not LSB range
            r_TX_DataBit <= 3'd7; //start sending from MSB
            r_commandIndex <= r_commandIndex - 10'd8;
            
            r_counter <= 0;
            r_State <= STATE_SEND;
        end
        STATE_SEND:
        begin
            r_cs <= 1'b0; //chip select active

            if(r_counter == 0)
            begin
                r_counter <= r_counter + 1; //increment counter
                r_clk <= 1'b0; //set clock to idle state (CPOL = 0)
                r_data <= r_TX_Data[r_TX_DataBit]; //load bit to send

                r_State <= STATE_SEND;
            end
            else
            begin
                r_counter <= 0; //reset counter
                r_clk <= 1'b1; //generate clk rising edge
                r_TX_DataBit <= r_TX_DataBit - 3'd1; //set next bit

                if(r_TX_DataBit == 3'd0) //if this was 0 bit
                    r_State <= STATE_INIT_CHECK; 
                else
                    r_State <= STATE_SEND;
            end
        end
        STATE_INIT_CHECK:
        begin
            r_cs <= 1'b1; //chip select inactive
            r_clk <= 1'b0; //set clock to idle state (CPOL = 0)
            
            if(r_commandIndex == 0)
                r_State <= STATE_LOAD_DATA;
            else
                r_State <= STATE_LOAD_INIT_CMD;
        end
        STATE_LOAD_DATA:
        begin
            r_cs <= 1'b0; //chip select active
            r_dc <= 1'b1; //send data
            r_State <= STATE_SEND; //default assignment

            r_col <= r_col + 1;

            if(r_col == 127)
            begin
                r_col <= 0;
                r_row <= r_row + 1;

                if(r_row == 7)
                    r_State <= STATE_IDLE;
            end

            r_TX_Data <= {4{r_col[0], ~r_col[0]}};
            r_TX_DataBit <= 3'd7; //start sending from MSB
        end
        STATE_IDLE:
        begin
            r_State <= STATE_IDLE;
        end
        default:
            r_State <= STATE_INIT_POWER;
    endcase
end

endmodule