`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:38:17 04/11/2015 
// Design Name: 
// Module Name:    Output_Voter 
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
module Output_Voter(
	input Vote_Pipe_A_DataMem_Read,
	input [3:0] Vote_Pipe_A_DataMem_Write,
	input [29:0] Vote_Pipe_A_DataMem_Address,
	input [31:0] Vote_Pipe_A_DataMem_Out,
	input [29:0] Vote_Pipe_A_InstMem_Address,
	input Vote_Pipe_A_InstMem_Read,
	input Vote_Pipe_B_DataMem_Read,
	input [3:0] Vote_Pipe_B_DataMem_Write,
	input [29:0] Vote_Pipe_B_DataMem_Address,
	input [31:0] Vote_Pipe_B_DataMem_Out,
	input [29:0] Vote_Pipe_B_InstMem_Address,
	input Vote_Pipe_B_InstMem_Read,
	input Vote_Pipe_C_DataMem_Read,
	input [3:0] Vote_Pipe_C_DataMem_Write,
	input [29:0] Vote_Pipe_C_DataMem_Address,
	input [31:0] Vote_Pipe_C_DataMem_Out,
	input [29:0] Vote_Pipe_C_InstMem_Address,
	input Vote_Pipe_C_InstMem_Read,
	output DataMem_Read,
	output [3:0] DataMem_Write,
	output [29:0] DataMem_Address,
	output [31:0] DataMem_Out,
	output [29:0] InstMem_Address,
	output InstMem_Read);

	Voter #(.WIDTH(1)) Output_DataMem_Read (
        .A  	(Vote_Pipe_A_DataMem_Read),
        .B  	(Vote_Pipe_B_DataMem_Read),
        .C  	(Vote_Pipe_C_DataMem_Read),
        .True  (DataMem_Read)
    );

	Voter #(.WIDTH(4)) Output_DataMem_Write (
        .A  	(Vote_Pipe_A_DataMem_Write),
        .B  	(Vote_Pipe_B_DataMem_Write),
        .C  	(Vote_Pipe_C_DataMem_Write),
        .True  (DataMem_Write)
    );

	Voter #(.WIDTH(30)) Output_DataMem_Address (
        .A  	(Vote_Pipe_A_DataMem_Address),
        .B  	(Vote_Pipe_B_DataMem_Address),
        .C  	(Vote_Pipe_C_DataMem_Address),
        .True  (DataMem_Address)
    );

	Voter #(.WIDTH(32)) Output_DataMem_Out (
        .A  	(Vote_Pipe_A_DataMem_Out),
        .B  	(Vote_Pipe_B_DataMem_Out),
        .C  	(Vote_Pipe_C_DataMem_Out),
        .True  (DataMem_Out)
    );

	Voter #(.WIDTH(30)) Output_InstMem_Address (
        .A  	(Vote_Pipe_A_InstMem_Address),
        .B  	(Vote_Pipe_B_InstMem_Address),
        .C  	(Vote_Pipe_C_InstMem_Address),
        .True  (InstMem_Address)
    );

	Voter #(.WIDTH(1)) Output_InstMem_Read (
        .A  	(Vote_Pipe_A_InstMem_Read),
        .B  	(Vote_Pipe_B_InstMem_Read),
        .C  	(Vote_Pipe_C_InstMem_Read),
        .True  (InstMem_Read)
    );

endmodule
