module uartRow (input i_clk,
                input [7:0] i_RX_Data,
                input i_RX_DataValid,
                input [3:0] i_charIndex,
                output [7:0] o_character);

localparam BUFFER_WIDTH = 128; //buffer stores 16*8 bytes
reg [(BUFFER_WIDTH - 1):0] r_textBuffer; //buffer for 16 characters
reg [3:0] r_charIndex;
reg [1:0] r_RX_DataValid;
reg r_State;

localparam STATE_IDLE = 1'd0,
STATE_SAVE_CHAR = 1'd1;

initial
begin
    r_textBuffer <= 0;
    r_charIndex <= 4'd0;
    r_RX_DataValid <= 2'd0;
    r_State <= STATE_IDLE;
end

/* Catch rising edge of i_RX_DataValid signal from slower clock domain */
always @(posedge i_clk)
begin
    r_RX_DataValid <= { r_RX_DataValid[0], i_RX_DataValid};
end

always @(posedge i_clk)
begin
    case(r_State)
        STATE_IDLE:
        begin
            if(r_RX_DataValid == 2'b01) //on RX_DataValid rising edge
                r_State <= STATE_SAVE_CHAR;
            else
                r_State <= STATE_IDLE;
        end
        STATE_SAVE_CHAR:
        begin
            if(i_RX_Data == 8'd8 || i_RX_Data == 8'd127)
            begin
                r_charIndex <= r_charIndex - 4'd1; //decrement charIndex
                r_textBuffer[({4'd0, r_charIndex-4'd1}<<3)+:8] <= 8'd32; //save space at previous charIndex
            end
            else
            begin
                r_charIndex <= r_charIndex + 4'd1;
                r_textBuffer[({4'd0, r_charIndex}<<3)+:8] <= i_RX_Data; //save character at r_textBuffer*8 (each character occupy 8 bits in r_textBuffer register)
            end
            r_State <= STATE_IDLE;
        end
        default:
            r_State <= STATE_IDLE;
    endcase
end 

assign o_character = r_textBuffer[({4'd0, i_charIndex}<<3)+:8];

endmodule