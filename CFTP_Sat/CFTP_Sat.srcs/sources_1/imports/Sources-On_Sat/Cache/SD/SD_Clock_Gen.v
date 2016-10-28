`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2015 10:28:25 AM
// Design Name: 
// Module Name: SD_Clock_Gen
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


module SD_Clock_Gen(
    input clk,
    input select,
    output clock
    );
    
    reg clock25m,clock400k;
    reg [8:0] count400k;
    
    initial clock25m = 1'b0;
    initial clock400k = 1'b0;
    initial count400k = 1'd0;
    
    always@(posedge clk) clock25m = ~clock25m;
    always@(posedge clk) clock400k = (count400k == 7'd124) ? ~clock400k : clock400k;
    always@(posedge clk) count400k = (count400k == 7'd124) ? 8'd0 : count400k + 1;
    
    assign clock = (select) ? clock25m : clock400k;
    
endmodule
