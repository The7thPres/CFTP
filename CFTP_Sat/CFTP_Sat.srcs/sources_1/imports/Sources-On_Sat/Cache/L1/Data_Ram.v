`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:46:04 07/12/2015 
// Design Name: 
// Module Name:    Data_Ram 
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
module Data_Ram(
    input [6:0] Offset_in,
    input [3:0] Index_in,
    input [31:0] CPU_Data_in,
    input [4095:0] MEM_Data_in,
    input Clock_in,
    input [3:0] Write_Data_in,
    output [31:0] CPU_Data_out,
    output [4095:0] MEM_Data_out,
    input Fill_in
    );
	 
	 wire [127:0] Write_Data_Offset;
	 wire [7:0] Data0 [127:0];
	 wire [7:0] Data1 [127:0];
	 wire [7:0] Data2 [127:0];
	 wire [7:0] Data3 [127:0];
	 
	 genvar i,j;
	 generate 
		for (i=0; i<128; i=i+1) begin : DATA_RAM
			Distributed_RAM #(4,8,16) DATA_RAM_0(
				.Clock_in			(Clock_in),
				.Write_Enable_in	((Fill_in) ? 1'b1 : (Write_Data_Offset[i] && Write_Data_in[0])),
				.Address_in			(Index_in),
				.Data_in			((Fill_in) ? MEM_Data_in[(32*i)+:8] : CPU_Data_in[0+:8]),
				.Data_out			(Data0 [i])
			);
			Distributed_RAM #(4,8,16) DATA_RAM_1(
				.Clock_in			(Clock_in),
				.Write_Enable_in	((Fill_in) ? 1'b1 : (Write_Data_Offset[i] && Write_Data_in[1])),
				.Address_in			(Index_in),
				.Data_in			((Fill_in) ? MEM_Data_in[((32*i)+8)+:8] : CPU_Data_in[8+:8]),
				.Data_out			(Data1 [i])
			);
			Distributed_RAM #(4,8,16) DATA_RAM_2(
				.Clock_in			(Clock_in),
				.Write_Enable_in	((Fill_in) ? 1'b1 : (Write_Data_Offset[i] && Write_Data_in[2])),
				.Address_in			(Index_in),
				.Data_in			((Fill_in) ? MEM_Data_in[((32*i)+16)+:8] : CPU_Data_in[16+:8]),
				.Data_out			(Data2 [i])
			);
			Distributed_RAM #(4,8,16) DATA_RAM_3(
				.Clock_in			(Clock_in),
				.Write_Enable_in	((Fill_in) ? 1'b1 : (Write_Data_Offset[i] && Write_Data_in[3])),
				.Address_in			(Index_in),
				.Data_in			((Fill_in) ? MEM_Data_in[((32*i)+24)+:8] : CPU_Data_in[24+:8]),
				.Data_out			(Data3 [i])
			);
			assign MEM_Data_out[(32*i)+:32] = {Data3[i], Data2[i], Data1[i], Data0[i]};
		end
	 endgenerate
				
	 assign Write_Data_Offset = (1 << Offset_in);
	 assign CPU_Data_out = {Data3[Offset_in],Data2[Offset_in],Data1[Offset_in],Data0[Offset_in]};


endmodule
