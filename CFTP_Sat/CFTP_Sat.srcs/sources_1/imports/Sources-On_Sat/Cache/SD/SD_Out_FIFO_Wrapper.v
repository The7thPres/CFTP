`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2015 09:10:43 AM
// Design Name: 
// Module Name: SD_Out_FIFO_Wrapper
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


module SD_Out_FIFO_Wrapper(
    input clk,
    input srst,
    input [7:0] din,
    input wr_en,
    output reg dout,
    output empty);
    
    wire Temp_out;
    
    SD_Out_FIFO Outgoing(
        .clk    (clk),
        .srst   (srst),
        .din    (din),
        .wr_en  (wr_en),
        .rd_en  (1'b1),
        .dout   (Temp_out),
        .full   (),
        .empty  (empty));

    always@(negedge clk) dout = (empty) ? 1'b1 : Temp_out;

endmodule
