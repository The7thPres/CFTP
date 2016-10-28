`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:43:58 07/12/2015 
// Design Name: 
// Module Name:    Counter 
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
module Counter(
    Clock_in,
    Enable_in,
    Reset_in,
    Count_out
    );

	parameter CountWidth = 8;

	input Clock_in;
   input Enable_in;
   input Reset_in;
	output reg [CountWidth-1:0] Count_out;
		
	always @ (posedge Clock_in) begin
		if (Reset_in) begin
			Count_out = 0;
		end
		else begin
			if (Enable_in) begin
				Count_out = Count_out + 1;
			end
		end
	end
endmodule
