`timescale 1ns / 1ps
/*
 * File         : Processor.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   23-Jul-2011  GEA       Initial design.
 *   2.0   26-May-2012  GEA       Release version with CP0.
 *   2.01   1-Nov-2012  GEA       Fixed issue with Jal.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   The top-level MIPS32 Processor. This file is mostly the instantiation
 *   and wiring of the building blocks of the processor according to the 
 *   hardware design diagram. It contains very little logic itself.
 */

module ITMR_Processor(
    input  clock,
    input  reset,
    input  [4:0] Interrupts,            // 5 general-purpose hardware interrupts
    input  NMI,                         // Non-maskable interrupt
    // Data Memory Interface
    input  [31:0] DataMem_In,
    input  DataMem_Ready,
    output DataMem_Read, 
    output [3:0]  DataMem_Write,        // 4-bit Write, one for each byte in word.
    output [29:0] DataMem_Address,      // Addresses are words, not bytes.
    output [31:0] DataMem_Out,
    // Instruction Memory Interface
    input  [31:0] InstMem_In,
    output [29:0] InstMem_Address,      // Addresses are words, not bytes.
    input  InstMem_Ready,
    output InstMem_Read
    );
genvar i;
parameter N = 3;  

/*** Voting Signals ***/
		wire Vote_DataMem_Read[N-1:0];
		wire [3:0] Vote_DataMem_Write[N-1:0];
		wire [29:0] Vote_DataMem_Address[N-1:0];
		wire [31:0] Vote_DataMem_Out[N-1:0];
		wire [29:0] Vote_InstMem_Address[N-1:0];
		wire Vote_InstMem_Read[N-1:0];
(* DONT_TOUCH = "TRUE" *)wire [1853:0] Vote_in [N-1:0];
(* DONT_TOUCH = "TRUE" *)wire [1853:0] Vote_out [N-1:0];

/*** MIPS Processors ***/

generate	
	for (i = 0; i < N; i = i + 1) begin : Processors

(* DONT_TOUCH = "TRUE" *)Processor MIPS32 (
    .clock						(clock),
    .reset						(reset),
    .Interrupts				(Interrupts),            
    .NMI							(NMI),                         
    .DataMem_In				(DataMem_In),
    .DataMem_Ready			(DataMem_Ready),
    .DataMem_Read				(Vote_DataMem_Read[i]), 
    .DataMem_Write			(Vote_DataMem_Write[i]),       
    .DataMem_Address			(Vote_DataMem_Address[i]),     	 
    .DataMem_Out				(Vote_DataMem_Out[i]),
    .InstMem_In				(InstMem_In),
    .InstMem_Address			(Vote_InstMem_Address[i]),     
    .InstMem_Ready			(InstMem_Ready),
    .InstMem_Read				(Vote_InstMem_Read[i]),                  	 
    .Vote_in					(Vote_in[i]),
    .Vote_out					(Vote_out[i]));	

	/*** Processor Internal Voters ***/
(* DONT_TOUCH = "TRUE" *)Processor_Voter Processor_Voter (
		.Vote_0_in	(Vote_out[0]),
		.Vote_1_in	(Vote_out[1]),
		.Vote_2_in	(Vote_out[2]),
		.Vote_out	(Vote_in[i]));

	end
endgenerate		

	/*** Output Voter ***/
	Output_Voter Output_Voter (
		.Vote_Pipe_A_DataMem_Read		(Vote_DataMem_Read[N-1]),
		.Vote_Pipe_A_DataMem_Write		(Vote_DataMem_Write[N-1]),
		.Vote_Pipe_A_DataMem_Address	(Vote_DataMem_Address[N-1]),
		.Vote_Pipe_A_DataMem_Out		(Vote_DataMem_Out[N-1]),
		.Vote_Pipe_A_InstMem_Address	(Vote_InstMem_Address[N-1]),
		.Vote_Pipe_A_InstMem_Read		(Vote_InstMem_Read[N-1]),
		.Vote_Pipe_B_DataMem_Read		(Vote_DataMem_Read[N-2]),
		.Vote_Pipe_B_DataMem_Write		(Vote_DataMem_Write[N-2]),
		.Vote_Pipe_B_DataMem_Address	(Vote_DataMem_Address[N-2]),
		.Vote_Pipe_B_DataMem_Out		(Vote_DataMem_Out[N-2]),
		.Vote_Pipe_B_InstMem_Address	(Vote_InstMem_Address[N-2]),
		.Vote_Pipe_B_InstMem_Read		(Vote_InstMem_Read[N-2]),
		.Vote_Pipe_C_DataMem_Read		(Vote_DataMem_Read[N-3]),
		.Vote_Pipe_C_DataMem_Write		(Vote_DataMem_Write[N-3]),
		.Vote_Pipe_C_DataMem_Address	(Vote_DataMem_Address[N-3]),
		.Vote_Pipe_C_DataMem_Out		(Vote_DataMem_Out[N-3]),
		.Vote_Pipe_C_InstMem_Address	(Vote_InstMem_Address[N-3]),
		.Vote_Pipe_C_InstMem_Read		(Vote_InstMem_Read[N-3]),
		.DataMem_Read						(DataMem_Read),
		.DataMem_Write						(DataMem_Write),
		.DataMem_Address					(DataMem_Address),
		.DataMem_Out						(DataMem_Out),
		.InstMem_Address					(InstMem_Address),
		.InstMem_Read						(InstMem_Read));

endmodule

