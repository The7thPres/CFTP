`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2015 11:06:55 AM
// Design Name: 
// Module Name: SD_Control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:  Need to add timeouts for command response states and handle additional response errors.
// 
//////////////////////////////////////////////////////////////////////////////////


module SD_Control(
    input SD_Clock, //200MHz
    input Reset, //Active-High
    input [7:0] SD_Data_in,
    output reg Write_out, //Active-High
    output Clock_Speed, // 0 = 400KHz, 1 = 25MHz
    output reg [7:0] SD_Data_out,
    output CS_out,
    input Data_Send_Complete,
    output reg [4:0] CurrentState,
    input Read_in,
    input Write_in,
    output Ready_out,
    input [29:0] Address_in,
    input [4095:0] DDR_Data_out,
    output reg [4095:0] DDR_Data_in);
    
    wire [2:0] BitCount;
    wire [8:0] ByteCount;
    reg [4:0] NextState;
    wire CountReset, BitEnable, ByteEnable;
         
    parameter SD_STATE_INIT             = 5'b00000;
    parameter SD_STATE_CMD0             = 5'b00001;
    parameter SD_STATE_CMD0_Response    = 5'b00010;
    parameter SD_STATE_DELAY1           = 5'b00011;
    parameter SD_STATE_CMD55            = 5'b00100;
    parameter SD_STATE_CMD55_Response   = 5'b00101;
    parameter SD_STATE_DELAY2           = 5'b00110;
    parameter SD_STATE_ACMD41           = 5'b00111;
    parameter SD_STATE_ACMD41_Response  = 5'b01000;
    parameter SD_STATE_IDLE             = 5'b01001;
    parameter SD_STATE_CMD17            = 5'b01010;
    parameter SD_STATE_CMD17_Response   = 5'b01011;
    parameter SD_STATE_READTOKEN        = 5'b01100;
    parameter SD_STATE_READBLOCK        = 5'b01101;
    parameter SD_STATE_READCRC          = 5'b01110;
    parameter SD_STATE_READACK          = 5'b01111;
    parameter SD_STATE_CMD24            = 5'b10000;
    parameter SD_STATE_CMD24_Response   = 5'b10001;
    parameter SD_STATE_WRITEDELAY       = 5'b10010;
    parameter SD_STATE_WRITETOKEN       = 5'b10011;
    parameter SD_STATE_WRITEBLOCK       = 5'b10100;
    parameter SD_STATE_WRITECRC         = 5'b10101;
    parameter SD_STATE_WRITERESPONSE    = 5'b10110;
    parameter SD_STATE_WRITEACK         = 5'b10111;
                
    initial DDR_Data_in = 4095'd0;

    Counter #(.CountWidth(3)) Bit(
        .Clock_in   (SD_Clock),
        .Enable_in  (BitEnable),
        .Reset_in   (CountReset),
        .Count_out  (BitCount));
    
    Counter #(.CountWidth(9)) Byte(
        .Clock_in   (SD_Clock),
        .Enable_in  (ByteEnable),
        .Reset_in   (CountReset),
        .Count_out  (ByteCount));

    
    // Assignments
    assign Ready_out = (CurrentState == SD_STATE_READACK || CurrentState == SD_STATE_WRITEACK);
    assign CS_out = (CurrentState == SD_STATE_INIT);
    assign Clock_Speed = ~(CurrentState == SD_STATE_INIT || CurrentState == SD_STATE_CMD0 || CurrentState == SD_STATE_CMD0_Response    
                        || CurrentState == SD_STATE_DELAY1 || CurrentState == SD_STATE_CMD55 || CurrentState == SD_STATE_CMD55_Response   
                        || CurrentState == SD_STATE_DELAY2 || CurrentState == SD_STATE_ACMD41 || CurrentState == SD_STATE_ACMD41_Response);
    assign BitEnable = ~((CurrentState == SD_STATE_IDLE) && (SD_Data_in[0] == 1'b0));  //Disable all counting while SD card is busy.
    assign ByteEnable = ((BitCount==3'd7)&&~(CurrentState == SD_STATE_IDLE && ByteCount == 9'd1))||(CurrentState == SD_STATE_WRITEBLOCK); //Ensure atleast 1Byte delay between end of reads and writes.
    assign CountReset = (Reset) || ((CurrentState == SD_STATE_INIT) && (ByteCount == 9'd9) && (BitCount == 3'd2)) ||
                        ((CurrentState == SD_STATE_CMD0_Response) && (~SD_Data_in[7])) ||
                        ((CurrentState == SD_STATE_CMD55_Response) && (~SD_Data_in[7])) ||
                        ((CurrentState == SD_STATE_ACMD41_Response) && (~SD_Data_in[7])) ||
                        ((CurrentState == SD_STATE_DELAY1) && (ByteCount == 9'd1)) ||
                        ((CurrentState == SD_STATE_DELAY2) && (ByteCount == 9'd1)) ||
                        ((CurrentState == SD_STATE_IDLE) && (ByteCount == 9'd1) && ((~Write_in)||(~Read_in))) ||
                        ((CurrentState == SD_STATE_READTOKEN) && (~SD_Data_in[0])) ||
                        ((CurrentState == SD_STATE_CMD24_Response) && (~SD_Data_in[7])) ||
                        (CurrentState == SD_STATE_WRITETOKEN);
    
    always @ (posedge SD_Clock)
    begin
        Write_out = ((CurrentState == SD_STATE_CMD0)||(CurrentState == SD_STATE_CMD55)||(CurrentState == SD_STATE_ACMD41)||
                    (CurrentState == SD_STATE_CMD17)||(CurrentState == SD_STATE_CMD24)||(CurrentState == SD_STATE_WRITETOKEN)||
                    (CurrentState == SD_STATE_WRITEBLOCK)||(CurrentState == SD_STATE_WRITECRC));
        //Data Out
        case (CurrentState)
            SD_STATE_CMD0: 
                case (BitCount)
                    3'd0 : SD_Data_out = 8'h40; 
                    3'd5 : SD_Data_out = 8'h95;  
                    default : SD_Data_out = 8'h00;
                endcase
            SD_STATE_CMD55: 
                case (BitCount)
                    3'd0 : SD_Data_out = 8'h77;   
                    default : SD_Data_out = 8'h00;
                endcase
            SD_STATE_ACMD41: 
                case (BitCount)
                    3'd0 : SD_Data_out = 8'h69; 
                    default : SD_Data_out = 8'h00;
                endcase 
            SD_STATE_CMD17: 
                case (BitCount)
                    3'd0 : SD_Data_out = 8'h51;
                    3'd1 : SD_Data_out = Address_in[29:22];
                    3'd2 : SD_Data_out = Address_in[21:14];
                    3'd3 : SD_Data_out = Address_in[13:6];
                    3'd4 : SD_Data_out = {Address_in[5:0],2'b0};
                    default : SD_Data_out = 8'h00;
                endcase 
            SD_STATE_CMD24: 
                case (BitCount)
                    3'd0 : SD_Data_out = 8'h58;
                    3'd1 : SD_Data_out = Address_in[29:22];
                    3'd2 : SD_Data_out = Address_in[21:14];
                    3'd3 : SD_Data_out = Address_in[13:6];
                    3'd4 : SD_Data_out = {Address_in[5:0],2'b0}; 
                    default : SD_Data_out = 8'h00;
                endcase  
            SD_STATE_WRITETOKEN: 
                    SD_Data_out = 8'hfe; 
            SD_STATE_WRITEBLOCK: 
                    SD_Data_out = DDR_Data_out[4095-(8*ByteCount)-:8];    
            default : SD_Data_out = 8'hff;
        endcase
         //Data In
        if ((CurrentState == SD_STATE_READBLOCK) && (BitCount == 3'd7)) DDR_Data_in[4095-(8*ByteCount)-:8] = SD_Data_in;         
    end
    
    // Synchronous State Transistion
    always @ (posedge SD_Clock) CurrentState = (Reset) ? SD_STATE_INIT : NextState;
    
    // State Logic
    
    always @ (*) 
        case (CurrentState) 
            SD_STATE_INIT : NextState = (ByteCount == 9'd9 && BitCount == 3'd2) ? SD_STATE_CMD0 : SD_STATE_INIT; 
            SD_STATE_CMD0 : NextState = (BitCount == 3'd5) ? SD_STATE_CMD0_Response : SD_STATE_CMD0; 
            SD_STATE_CMD0_Response : NextState = (~SD_Data_in[7]) ? (SD_Data_in == 8'h01) ? SD_STATE_DELAY1 : SD_STATE_INIT : SD_STATE_CMD0_Response;
            SD_STATE_DELAY1 : NextState = (ByteCount == 9'd1) ? SD_STATE_CMD55 : SD_STATE_DELAY1;
            SD_STATE_CMD55 : NextState = (BitCount == 3'd5) ? SD_STATE_CMD55_Response : SD_STATE_CMD55;
            SD_STATE_CMD55_Response : NextState = (~SD_Data_in[7]) ? (SD_Data_in == 8'h01) ? SD_STATE_DELAY2 : SD_STATE_INIT : SD_STATE_CMD55_Response;
            SD_STATE_DELAY2 : NextState = (ByteCount == 9'd1) ? SD_STATE_ACMD41 : SD_STATE_DELAY2;
            SD_STATE_ACMD41 : NextState = (BitCount == 3'd5) ? SD_STATE_ACMD41_Response : SD_STATE_ACMD41;
            SD_STATE_ACMD41_Response : NextState = (~SD_Data_in[7]) ? (SD_Data_in == 8'h00) ? SD_STATE_IDLE : (SD_Data_in == 8'b01) ? SD_STATE_CMD55 : SD_STATE_INIT : SD_STATE_ACMD41_Response;
            SD_STATE_IDLE : NextState = (ByteCount == 9'd1) ? (Write_in) ? SD_STATE_CMD24 : (Read_in) ? SD_STATE_CMD17 : SD_STATE_IDLE : SD_STATE_IDLE;
            SD_STATE_CMD17 : NextState = (BitCount == 3'd5) ? SD_STATE_CMD17_Response : SD_STATE_CMD17;
            SD_STATE_CMD17_Response : NextState = (ByteCount == 9'd20) ? SD_STATE_CMD17 : (~SD_Data_in[7]) ? (SD_Data_in == 8'h00) ? SD_STATE_READTOKEN : (SD_Data_in == 8'h01) ? SD_STATE_INIT : SD_STATE_CMD24 : SD_STATE_CMD17_Response;
            SD_STATE_READTOKEN : NextState = (~SD_Data_in[0]) ? SD_STATE_READBLOCK : SD_STATE_READTOKEN;
            SD_STATE_READBLOCK : NextState = ((ByteCount == 9'd511) && (BitCount == 3'd7)) ? SD_STATE_READCRC : SD_STATE_READBLOCK;
            SD_STATE_READCRC : NextState = (ByteCount == 9'd2) ? SD_STATE_READACK : SD_STATE_READCRC;
            SD_STATE_READACK : NextState = (~Read_in) ? SD_STATE_IDLE : SD_STATE_READACK;
            SD_STATE_CMD24 : NextState = (BitCount == 3'd5) ? SD_STATE_CMD24_Response : SD_STATE_CMD24;
            SD_STATE_CMD24_Response : NextState = (ByteCount == 9'd20) ? SD_STATE_CMD24 : (~SD_Data_in[7]) ? (SD_Data_in == 8'h00) ? SD_STATE_WRITEDELAY : (SD_Data_in == 8'h01) ? SD_STATE_INIT : SD_STATE_CMD24 : SD_STATE_CMD24_Response;
            SD_STATE_WRITEDELAY : NextState = (ByteCount == 9'd1) ? SD_STATE_WRITETOKEN : SD_STATE_WRITEDELAY;
            SD_STATE_WRITETOKEN : NextState = SD_STATE_WRITEBLOCK;
            SD_STATE_WRITEBLOCK : NextState = (ByteCount == 9'd511) ? SD_STATE_WRITECRC : SD_STATE_WRITEBLOCK;
            SD_STATE_WRITECRC : NextState = (ByteCount == 9'd2) ? SD_STATE_WRITERESPONSE : SD_STATE_WRITECRC;
            SD_STATE_WRITERESPONSE : NextState = (SD_Data_in[4:0]==5'b00101) ? SD_STATE_WRITEACK : (SD_Data_in[4:0]==5'b01011 || SD_Data_in[4:0]==5'b01101) ? SD_STATE_IDLE : SD_STATE_WRITERESPONSE; 
            SD_STATE_WRITEACK : NextState = (~Write_in) ? SD_STATE_IDLE : SD_STATE_WRITEACK; 
            default : NextState = SD_STATE_INIT; 
        endcase
     
endmodule
