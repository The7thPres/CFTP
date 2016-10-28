`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:36:53 07/12/2015 
// Design Name: 
// Module Name:    Dirty_Ram 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Output of 0 is Clean. Output of 1 is Dirty.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Dirty_Ram(		
	input  Clock_in,
   input  Reset_in,
   input  [3:0] Index_in, 
   input  Dirty_in,
   input  Write_Dirty_in,
   output Dirty_out,
	input [7:0] Counter_in,
	output reg Init_Dirty_out
   );
	 
	Distributed_RAM #(4,1,16) DIRTY_RAM(
		.Clock_in			(Clock_in),
		.Write_Enable_in	((Init_Dirty_out) ? 1'b1 : Write_Dirty_in),
		.Address_in			((Init_Dirty_out) ? Counter_in[3:0] : Index_in),
		.Data_in				((Init_Dirty_out) ? 1'b0 : Dirty_in),
		.Data_out			(Dirty_out)
	);
				
	always @ (posedge Clock_in) begin
		if (Reset_in) begin
			Init_Dirty_out = 1'b1;
		end
		else begin
			if (Counter_in == 8'b00010000) begin
				Init_Dirty_out = 1'b0;
			end
		end
	end
endmodule
