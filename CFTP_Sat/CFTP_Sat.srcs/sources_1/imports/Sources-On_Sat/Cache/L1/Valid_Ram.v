`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:14:21 07/12/2015 
// Design Name: 
// Module Name:    Valid_Ram 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Output of 0 is Invalid.  Output of 1 is Valid.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Valid_Ram(		
	input  Clock_in,
   input  Reset_in,
   input  [3:0] Index_in, 
   input Valid_in,
   input  Write_Valid_in,
   output Valid_out,
	input [7:0] Counter_in,
	output reg Init_Valid_out
   );
	 
	Distributed_RAM#(4,1,16) VALID_RAM(
		.Clock_in			(Clock_in),
		.Write_Enable_in	((Init_Valid_out) ? 1'b1 : Write_Valid_in),
		.Address_in			((Init_Valid_out) ? Counter_in[3:0] : Index_in),
		.Data_in				((Init_Valid_out) ? 1'b0 : Valid_in),
		.Data_out			(Valid_out)
	);
				
	always @ (posedge Clock_in) begin
		if (Reset_in) begin
			Init_Valid_out = 1'b1;
		end
		else begin
			if (Counter_in == 8'b00010000) begin
				Init_Valid_out = 1'b0;
			end
		end
	end
endmodule
