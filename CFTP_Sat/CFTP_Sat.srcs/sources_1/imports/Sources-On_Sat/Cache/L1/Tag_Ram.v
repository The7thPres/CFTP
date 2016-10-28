`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:07:03 07/12/2015 
// Design Name: 
// Module Name:    Tag_Ram 
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
module Tag_Ram(
	 input [3:0] Index_in,
	 input [18:0] Tag_in,
	 input Clock_in,
    input Write_Tag_in,
    output [18:0] Tag_out
    );

			Distributed_RAM #(4,19,16) TAG_RAM(
				.Clock_in			(Clock_in),
				.Write_Enable_in	(Write_Tag_in),
				.Address_in			(Index_in),
				.Data_in				(Tag_in),
				.Data_out			(Tag_out)
			);

endmodule
