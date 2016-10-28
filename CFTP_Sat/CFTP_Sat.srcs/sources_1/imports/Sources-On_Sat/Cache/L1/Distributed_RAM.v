`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:35:35 07/12/2015 
// Design Name: 
// Module Name:    Distributed_RAM 
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
module Distributed_RAM(
	 Clock_in,
	 Write_Enable_in,
	 Address_in,
	 Data_in,
	 Data_out
    );
	 
parameter AddressWidth = 8;
parameter DataWidth = 8;
parameter Depth = 256;	 
	 
input	Clock_in;
input	Write_Enable_in;
input [AddressWidth-1:0]Address_in;
input [DataWidth-1:0]Data_in;
output [DataWidth-1:0]Data_out;

(* ram_style = "distributed" *)
reg [DataWidth-1:0] RAM [Depth-1:0];

integer i;
initial begin
    for (i = 0; i < Depth; i = i + 1) begin
        RAM[i] = {DataWidth{1'b0}};
    end
end

always @ (posedge Clock_in) begin
	if (Write_Enable_in) begin
		RAM[Address_in]<=Data_in;
	end
end

assign Data_out = RAM[Address_in];

endmodule
