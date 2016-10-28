`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:52:57 07/12/2015 
// Design Name: 
// Module Name:    Hit_Detection 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Hit_Detection(
    input [18:0] CPU_Tag_in,
    input [18:0] Cache_Tag_in,
	 input Valid_Bit_in,
    output HIT_out
    );

wire Matching_Tag;

assign Matching_Tag = (CPU_Tag_in == Cache_Tag_in) ? 1'b1 : 1'b0;
assign HIT_out = Valid_Bit_in && Matching_Tag; 

endmodule
