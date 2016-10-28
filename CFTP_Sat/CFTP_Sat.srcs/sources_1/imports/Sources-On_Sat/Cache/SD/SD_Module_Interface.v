`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2015 12:37:17 PM
// Design Name: 
// Module Name: SD_Module_Interface
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


module SD_Module_Interface(
    input Clock,
    input Reset,
    input MISO_in,
    output MOSI_out,
    output CS_out,
    output SD_Clock,
    output [4:0] CurrentState,
    input Read_in,
    input Write_in,
    output Ready_out,
    input [29:0] Address_in,
    input [4095:0] DDR_Data_out,
    output[4095:0] DDR_Data_in 
    );
    
    wire [7:0] Data_i, Data_o;
    wire Write, Clock_Speed, Data_Send_Complete;
    
    SD_Control Control(
        .SD_Clock           (SD_Clock),
        .Reset              (Reset), 
        .SD_Data_in         (Data_i),
        .Write_out          (Write), 
        .Clock_Speed        (Clock_Speed), 
        .SD_Data_out        (Data_o),
        .CS_out             (CS_out),
        .Data_Send_Complete (Data_Send_Complete),
        .CurrentState       (CurrentState),
        .Read_in            (Read_in),
        .Write_in           (Write_in),
        .Ready_out          (Ready_out),
        .Address_in         (Address_in),
        .DDR_Data_out       (DDR_Data_out),
        .DDR_Data_in        (DDR_Data_in));
        
    SD_Card_Interface Interface(
        .Clock              (Clock), //200MHz
        .Reset              (Reset), //Active-High
        .Data_in            (Data_o),
        .Write_in           (Write), //Active-High
        .Clock_Speed        (Clock_Speed), // 0 = 400KHz, 1 = 25MHz
        .Data_out           (Data_i),
        .Data_Send_Complete (Data_Send_Complete),
        .SD_Clock           (SD_Clock),
        .MISO               (MISO_in),
        .MOSI               (MOSI_out));

endmodule
