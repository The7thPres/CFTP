`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:15:28 07/05/2015 
// Design Name: 
// Module Name:    Level1_Cache 
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
module Level_1_Cache(
    input Clock_in,
    input Reset_in,
    input [29:0] CPU_Address_in,
    input [3:0] CPU_Write_Data_in,
    input [31:0] CPU_Data_in,
    output [31:0] CPU_Data_out,
    input CPU_Read_in,
    output CPU_Ready_out,
	input CPU_Flush_in,
	output CPU_Flush_Complete_out,
	output [29:0] MEM_Address_out,
    output MEM_Write_Data_out,
    input [4095:0] MEM_Data_in,
    output [4095:0] MEM_Data_out,
    output MEM_Read_out,
    input MEM_Ready_in,
    output Init_Mem_out
    );
	 
	 wire [3:0] Index, Write_Data;
	 wire [7:0] Flush_Counter, Counter;
	 wire [6:0] Offset;
	 wire [18:0] Tag;
	 
	 Cache_Control CONTROL (
    .CPU_Address_in(CPU_Address_in), 
    .CPU_Write_Data_in(CPU_Write_Data_in), 
    .CPU_Read_in(CPU_Read_in), 
    .CPU_Ready_out(CPU_Ready_out), 
    .CPU_Flush_in(CPU_Flush_in), 
    .CPU_Flush_out(CPU_Flush_Complete_out), 
    .MEM_Address_out(MEM_Address_out), 
    .MEM_Write_Data_out(MEM_Write_Data_out),  
    .MEM_Read_out(MEM_Read_out), 
    .MEM_Ready_in(MEM_Ready_in), 
    .Index_out(Index), 
    .Offset_out(Offset),  
    .Write_Data_out(Write_Data), 
    .Dirty_in(Dirty_o), 
    .Dirty_out(Dirty_i), 
    .Write_Dirty_out(Write_Dirty), 
    .Init_Dirty_in(Init_Dirty), 
    .Tag_in(Tag), 
    .Write_Valid_Tag_out(Write_Valid_Tag), 
    .Valid_out(Valid_i), 
    .Init_Valid_in(Init_Mem_out), 
    .Hit_in(Hit), 
    .Counter_in(Counter), 
    .Reset_Counter_out(Reset_Counter), 
    .Counter_Enable_out(Counter_Enable), 
    .Flush_Count_in(Flush_Counter), 
    .Flush_Reset_Counter_out(Flush_Reset_Counter), 
    .Flush_Counter_Enable_out(Flush_Counter_Enable), 
    .Clock_in(Clock_in), 
    .Reset_in(Reset_in),
    .Reset_Valid_Dirty_out(Reset_Valid_Dirty),
    .Fill_out(Fill)
    );
	 
	 Data_Ram DATA_RAM (
    .Offset_in(Offset), 
    .Index_in(Index), 
    .CPU_Data_in(CPU_Data_in),
    .MEM_Data_in(MEM_Data_in), 
    .Clock_in(Clock_in), 
    .Write_Data_in(Write_Data), 
    .CPU_Data_out(CPU_Data_out),
    .MEM_Data_out(MEM_Data_out),
    .Fill_in(Fill)
    );
	 
	 Dirty_Ram DIRTY_RAM (
    .Clock_in(Clock_in), 
    .Reset_in(Reset_Valid_Dirty || Reset_in), 
    .Index_in(Index), 
    .Dirty_in(Dirty_i), 
    .Write_Dirty_in(Write_Dirty), 
    .Dirty_out(Dirty_o), 
    .Counter_in(Counter), 
    .Init_Dirty_out(Init_Dirty)
    );
	 
	 Tag_Ram TAG_RAM (
    .Index_in(Index), 
    .Tag_in(CPU_Address_in[29:11]), 
    .Clock_in(Clock_in), 
    .Write_Tag_in(Write_Valid_Tag), 
    .Tag_out(Tag)
    );
	 
	 Valid_Ram VALID_RAM (
    .Clock_in(Clock_in), 
    .Reset_in(Reset_Valid_Dirty || Reset_in), 
    .Index_in(Index), 
    .Valid_in(Valid_i), 
    .Write_Valid_in(Write_Valid_Tag), 
    .Valid_out(Valid_o), 
    .Counter_in(Counter), 
    .Init_Valid_out(Init_Mem_out)
    );
	 
	 Hit_Detection HIT (
    .CPU_Tag_in(CPU_Address_in[29:11]), 
    .Cache_Tag_in(Tag), 
    .Valid_Bit_in(Valid_o), 
    .HIT_out(Hit)
    );
	 
	 Counter Cache_Count (
    .Clock_in(Clock_in), 
    .Enable_in(Counter_Enable), 
    .Reset_in(Reset_Counter), 
    .Count_out(Counter)
    );

	 Counter Flush_Count (
    .Clock_in(Clock_in), 
    .Enable_in(Flush_Counter_Enable), 
    .Reset_in(Flush_Reset_Counter), 
    .Count_out(Flush_Counter)
    );

		

endmodule
