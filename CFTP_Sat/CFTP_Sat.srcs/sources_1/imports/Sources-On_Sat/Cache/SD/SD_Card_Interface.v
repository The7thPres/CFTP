`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2015 09:44:53 AM
// Design Name: 
// Module Name: SD_Card_Interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module SD_Card_Interface(
    input Clock, //200MHz
    input Reset, //Active-High
    input [7:0] Data_in,
    input Write_in, //Active-High
    input Clock_Speed, // 0 = 400KHz, 1 = 25MHz
    output [7:0] Data_out,
    output Data_Send_Complete,
    output SD_Clock,
    input MISO,
    output MOSI);
    
    SD_Clock_Gen ClockGen(
        .clk    (Clock),
        .select (Clock_Speed),
        .clock  (SD_Clock));
    
    SD_Out_FIFO_Wrapper Outgoing(
        .clk    (SD_Clock),
        .srst   (Reset),
        .din    (Data_in),
        .wr_en  (Write_in),
        .dout   (MOSI),
        .empty  (Data_Send_Complete));
        
    SD_In_ShiftRegister Incoming(
        .clk    (SD_Clock),
        .srst   (Reset),
        .din    (MISO),
        .dout   (Data_out));
        
endmodule
