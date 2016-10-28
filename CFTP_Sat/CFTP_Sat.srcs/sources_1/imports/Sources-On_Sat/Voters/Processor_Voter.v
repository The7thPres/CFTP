`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:10:36 04/11/2015 
// Design Name: 
// Module Name:    MEMWB_Voter 
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
module Processor_Voter(
	input [1853:0] Vote_0_in,
	input [1853:0] Vote_1_in,
	input [1853:0] Vote_2_in,
	output [1853:0] Vote_out
   );

	Voter #(.WIDTH(2)) InstructionInterface_VOTER (
        .A  	(Vote_0_in[1:0]),
        .B  	(Vote_1_in[1:0]),
        .C  	(Vote_2_in[1:0]),
        .True  (Vote_out[1:0])
	 );
	 
	 Voter #(.WIDTH(193)) CP0_VOTER (
        .A  	(Vote_0_in[194:2]),
        .B  	(Vote_1_in[194:2]),
        .C  	(Vote_2_in[194:2]),
        .True  (Vote_out[194:2])
	 );
	 
	 Voter #(.WIDTH(32)) PC_VOTER (
        .A  	(Vote_0_in[226:195]),
        .B  	(Vote_1_in[226:195]),
        .C  	(Vote_2_in[226:195]),
        .True  (Vote_out[226:195])
	 );
	 
	 Voter #(.WIDTH(98)) IFID_VOTER (
        .A  	(Vote_0_in[324:227]),
        .B  	(Vote_1_in[324:227]),
        .C  	(Vote_2_in[324:227]),
        .True  (Vote_out[324:227])
	 );
	 
	 Voter #(.WIDTH(992)) RegisterFile_VOTER (
        .A  	(Vote_0_in[1316:325]),
        .B  	(Vote_1_in[1316:325]),
        .C  	(Vote_2_in[1316:325]),
        .True  (Vote_out[1316:325])
	 );
	 
	 Voter #(.WIDTH(154)) IDEX_VOTER (
        .A  	(Vote_0_in[1470:1317]),
        .B  	(Vote_1_in[1470:1317]),
        .C  	(Vote_2_in[1470:1317]),
        .True  (Vote_out[1470:1317])
	 );
	 
	 Voter #(.WIDTH(65)) ALU_VOTER (
        .A  	(Vote_0_in[1535:1471]),
        .B  	(Vote_1_in[1535:1471]),
        .C  	(Vote_2_in[1535:1471]),
        .True  (Vote_out[1535:1471])
	 );
	 
	 Voter #(.WIDTH(98)) Divider_VOTER (
        .A  	(Vote_0_in[1633:1536]),
        .B  	(Vote_1_in[1633:1536]),
        .C  	(Vote_2_in[1633:1536]),
        .True  (Vote_out[1633:1536])
	 );
	 
	 Voter #(.WIDTH(117)) EXMEM_VOTER (
        .A  	(Vote_0_in[1750:1634]),
        .B  	(Vote_1_in[1750:1634]),
        .C  	(Vote_2_in[1750:1634]),
        .True  (Vote_out[1750:1634])
	 );
	 
	 Voter #(.WIDTH(32)) DataInterface_VOTER (
        .A  	(Vote_0_in[1782:1751]),
        .B  	(Vote_1_in[1782:1751]),
        .C  	(Vote_2_in[1782:1751]),
        .True  (Vote_out[1782:1751])
	 );
	 
	 Voter #(.WIDTH(71)) MEMWB_VOTER (
        .A  	(Vote_0_in[1853:1783]),
        .B  	(Vote_1_in[1853:1783]),
        .C  	(Vote_2_in[1853:1783]),
        .True  (Vote_out[1853:1783])
	 );
	 
endmodule
