`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2015 09:39:42 AM
// Design Name: 
// Module Name: SD_In_ShiftRegister
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


module SD_In_ShiftRegister(
    input clk,
    input srst,
    input din,
    output reg [7:0] dout);

    always@(posedge clk)
    begin
        if (srst) dout = 8'hff;
        else dout = {dout[6:0],din};
    end
endmodule
