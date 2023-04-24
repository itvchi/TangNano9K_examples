module flashNavigator (input i_clk,
                    input i_flashMISO,
                    output reg o_flashCLK = 0,
                    output reg o_flashMOSI = 0,
                    output reg o_flashCS = 1,
                    input [5:0] i_charAddress,
                    output reg [7:0] o_character,
                    input i_btn1,
                    input i_btn2);

localparam STARTUP_DELAY = 2700000; //2.7M * 1/27MHz = 100ms

reg [23:0] r_readAddress = 0; //read address of the flash memory
reg [7:0] r_command = 8'h03; //read command for the flash IC
reg [7:0] r_currentByteOut = 0; //current data from the flash IC
reg [7:0] r_currentByteNum = 0; //readed byte number counter
reg [191:0] r_dataIn = 0; //buffer of 24 bytes
reg [191:0] r_dataInBuffer = 0; //data buffer assigned after read operation complete

localparam STATE_RESET = 3'd0,
STATE_INIT_POWER = 3'd1,
STATE_LOAD_CMD_TO_SEND = 3'd2,
STATE_SEND = 3'd3,
STATE_LOAD_ADDRESS_TO_SEND = 3'd4,
STATE_READ_DATA = 3'd5,
STATE_DONE = 3'd6;

reg [23:0] r_dataToSend = 0; //data to send 24bit address or 8bit data
reg [7:0] r_bitsToSend = 0; //number of bits to send

reg [31:0] r_counter = 0;
reg [2:0] r_state = 0;
reg [2:0] r_returnState = 0;

reg r_dataReady = 0;

always @(posedge i_clk) 
begin
    r_dataReady <= 1'b0; //default assignment

    case(r_state)
        STATE_RESET:
        begin
            r_counter <= 0;
            r_readAddress <= 0;
            r_state <= STATE_INIT_POWER;
        end
        STATE_INIT_POWER:
        begin
            if(r_counter > STARTUP_DELAY && i_btn1 == 1 && i_btn2 == 1) //if button released
            begin
                r_state <= STATE_LOAD_CMD_TO_SEND;
                r_counter <= 0;
                r_currentByteNum <= 0;
                r_currentByteOut <= 0;
            end
            else
                r_counter <= r_counter + 32'd1;
        end
        STATE_LOAD_CMD_TO_SEND:
        begin
            o_flashCS <= 1'b0; //chip select active
            r_dataToSend[23-:8] <= r_command; //load command to register
            r_bitsToSend <= 8; //set number of bits to send
            r_state <= STATE_SEND; 
            r_returnState <= STATE_LOAD_ADDRESS_TO_SEND; 
        end
        STATE_SEND:
        begin
            r_state <= STATE_SEND; //default assignment

            if(r_counter == 32'd0) //falling edge of clk
            begin
                o_flashCLK <= 1'b0;
                o_flashMOSI <= r_dataToSend[23];
                r_dataToSend <= {r_dataToSend[22:0], 1'b0}; //shift data register
                r_bitsToSend <= r_bitsToSend - 1; //decrease number bits to send
                r_counter <= 32'd1;
            end
            else //riging edge of clk
            begin
                o_flashCLK <= 1'b1;
                r_counter <= 32'd0;
                if(r_bitsToSend == 8'd0)
                    r_state <= r_returnState;
            end
        end
        STATE_LOAD_ADDRESS_TO_SEND:
        begin
            r_dataToSend <= r_readAddress; //load address to register
            r_bitsToSend <= 24;
            r_state <= STATE_SEND;
            r_returnState <= STATE_READ_DATA;
        end
        STATE_READ_DATA:
        begin
            r_counter <= r_counter + 32'd1; //default assignment

            if(r_counter[0] == 1'b0) //falling edge of clk
            begin
                o_flashCLK <= 1'b0;
                if(r_counter[3:0] == 3'd0 && r_counter > 0) //every 16 counter increments (8 falling edges)
                begin
                    r_dataIn[(r_currentByteNum<<3)+:8] <= r_currentByteOut;
                    r_currentByteNum <= r_currentByteNum + 1;
                    if(r_currentByteNum == 23) //after bytes 0-23 (at 24th received byte)
                        r_state <= STATE_DONE;
                end
            end
            else //rising edge of clk
            begin
                o_flashCLK <= 1'b1;
                r_currentByteOut <= {r_currentByteOut[6:0], i_flashMISO}; //shift in MISO data
            end
        end
        STATE_DONE:
        begin
            r_dataReady <= 1'b1; //pulse dataReady signal for one clock
            o_flashCS <= 1'b1; //chip select active
            r_dataInBuffer <= r_dataIn; //latch received data
            r_counter <= STARTUP_DELAY;

            if(i_btn1 == 0)
            begin
                r_readAddress <= r_readAddress + 8;
                r_state <= STATE_INIT_POWER;
            end
            else if(i_btn2 == 0)
            begin
                r_readAddress <= r_readAddress - 8;
                r_state <= STATE_INIT_POWER;
            end
        end
        default: 
            r_state <= STATE_RESET;
    endcase    
end

reg [7:0] r_chosenByte = 0; //byte from buffer to be displayed
wire [7:0] w_byteDisplayNumber; //displayed byte number (0-23) - need 8bit register, because of shift left by 3
wire w_lowerHalf; //indicator of lower hex value in byte
wire [7:0] w_hexASCII; //ASCII character of hex value
wire [3:0] w_hexValue; //currently converted nibble

/* Divide displayed character address into byte number and lower/upper half */
assign w_byteDisplayNumber = i_charAddress[5:1] - 5'd8; //move displayed byte by 1 row down
assign w_lowerHalf = i_charAddress[0];

assign w_hexValue = w_lowerHalf ? r_chosenByte[3:0] : r_chosenByte[7:4];

toHex hexConv (.i_value(w_hexValue),
                .o_hexCharacter(w_hexASCII));

always @(posedge i_clk) 
begin
    if(i_charAddress[5:4] == 2'b0) /* First row, i_charAddress[5:4] - address of row */
    begin
        case(i_charAddress[3:0]) //i_charAddress[3:0] - address of character
            0: o_character <= "A";
            1: o_character <= "d";
            2: o_character <= "d";
            3: o_character <= "r";
            4: o_character <= ":";
            6: o_character <= "0";
            7: o_character <= "x";
            8: o_character <= address[5].w_hexASCII;
            9: o_character <= address[4].w_hexASCII;
            10: o_character <= address[3].w_hexASCII;
            11: o_character <= address[2].w_hexASCII;
            12: o_character <= address[1].w_hexASCII;
            13: o_character <= address[0].w_hexASCII;
            15: o_character <= r_dataReady ? " " : "L";
            default: o_character <= " ";
        endcase
    end
    else /* Other rows */
    begin
        o_character <= w_hexASCII;  
    end

    /* Load byte to ASCII from hex conversion */
    r_chosenByte <= r_dataInBuffer[(w_byteDisplayNumber<<3)+:8];  
end

/* Address display */
genvar i;
generate
    for(i = 0; i<6; i = i + 1)
    begin: address
        wire [7:0] w_hexASCII;
        toHex hexConv (.i_value(r_readAddress[{i[2:0], 2'b0}+:4]), //0-3, 4-7, 8-11 ...
                .o_hexCharacter(w_hexASCII));
    end
endgenerate

endmodule