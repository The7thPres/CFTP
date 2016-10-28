`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:55:14 07/05/2015 
// Design Name: 
// Module Name:    Memory 
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
module System_Memory(
	input  clock,
    input  reset,
    input  Inst_Read_in,
    input  [3:0]  Inst_Write_in,
    input  [29:0] Inst_Address_in,
    input  [31:0] Inst_Data_in,
    output [31:0] Inst_Data_out,
    output Inst_Ready_out,
	input  flush,
	output flushcomplete,
    input  Data_Read_in,
    input  [3:0]  Data_Write_in,
    input  [29:0] Data_Address_in,
    input  [31:0] Data_Data_in,
    output [31:0] Data_Data_out,
    output Data_Ready_out,
    output Init_Mem_out,
    // DDR Signals
    input Memory_Clock_in,/* //200MHz
    input DDR_Reset_in,
        // Inouts
    inout [15:0] ddr2_dq,
    inout [1:0] ddr2_dqs_n,
    inout [1:0] ddr2_dqs_p,
        // Outputs
    output [12:0] ddr2_addr,
    output [2:0] ddr2_ba,
    output ddr2_ras_n,
    output ddr2_cas_n,
    output ddr2_we_n,
    output [0:0] ddr2_ck_p,
    output [0:0] ddr2_ck_n,
    output [0:0] ddr2_cke,
    output [0:0] ddr2_cs_n,
    output [1:0] ddr2_dm,
    output [0:0] ddr2_odt */ 
    input MISO,
    output MOSI,
    output CSn,
    output SClk,
    output [4:0] CurrentState 
    );
	 
	wire [29:0] Inst_Address;
	wire Inst_Write, Inst_Read, Inst_Ready;
	wire [4095:0] Inst_Data_i, Inst_Data_o;
	 	 
	wire [29:0] Data_Address;
	wire Data_Write, Data_Read, Data_Ready;
	wire [4095:0] Data_Data_i, Data_Data_o;
	
	wire [29:0] SD_Address;
    wire SD_Write, SD_Read, SD_Ready;
    wire [4095:0] SD_Data_i, SD_Data_o;
	 
	Level_1_Cache ICache(
		.Clock_in                 (clock),
		.Reset_in		          (reset),
		.CPU_Address_in           (Inst_Address_in),
		.CPU_Write_Data_in	      (Inst_Write_in),
		.CPU_Data_in	          (Inst_Data_in),
		.CPU_Data_out		      (Inst_Data_out),
		.CPU_Read_in	          (Inst_Read_in),
		.CPU_Ready_out	          (Inst_Ready_out),
		.CPU_Flush_in	          (flush),
		.CPU_Flush_Complete_out   (flushcomplete),
		.MEM_Address_out          (Inst_Address),
		.MEM_Write_Data_out       (Inst_Write),
		.MEM_Data_in		      (Inst_Data_i),
		.MEM_Data_out             (Inst_Data_o),
		.MEM_Read_out	          (Inst_Read),
		.MEM_Ready_in	          (Inst_Ready),
		.Init_Mem_out             (Init_Mem_out));
		
	Level_1_Cache DCache(
		.Clock_in		          (clock),
		.Reset_in		          (reset||flush),
		.CPU_Address_in           (Data_Address_in),
		.CPU_Write_Data_in	      (Data_Write_in),
		.CPU_Data_in	          (Data_Data_in),
		.CPU_Data_out		      (Data_Data_out),
		.CPU_Read_in	          (Data_Read_in),
		.CPU_Ready_out	          (Data_Ready_out),
		.CPU_Flush_in	          (1'b0),
		.CPU_Flush_Complete_out   (),
		.MEM_Address_out          (Data_Address),
		.MEM_Write_Data_out       (Data_Write),
		.MEM_Data_in		      (Data_Data_i),
		.MEM_Data_out             (Data_Data_o),
		.MEM_Read_out	          (Data_Read),
		.MEM_Ready_in	          (Data_Ready),
		.Init_Mem_out             ());
		
	Bus_Arbiter BUS(
        .Clock_in           (clock),
        .Reset_in           (reset),
        .Inst_Read_in       (Inst_Read),
        .Inst_Write_in      (Inst_Write),
        .Inst_Address_in    (Inst_Address),
        .Inst_Data_in       (Inst_Data_o),
        .Inst_Ready_out     (Inst_Ready),
        .Inst_Data_out      (Inst_Data_i),
        .Data_Read_in       (Data_Read),
        .Data_Write_in      (Data_Write),
        .Data_Address_in    (Data_Address),
        .Data_Data_in       (Data_Data_o),
        .Data_Ready_out     (Data_Ready),
        .Data_Data_out      (Data_Data_i),
        .SD_Read_in         (SD_Read),
        .SD_Write_in        (SD_Write),
        .SD_Address_in      (SD_Address),
        .SD_Data_in         (SD_Data_i),
        .SD_Ready_out       (SD_Ready),
        .SD_Data_out        (SD_Data_o));
	 
//	   BRAM_540KB_Wrapper SD(
//		.clock			(clock),
//		.reset			(reset),
//		.rea			(SD_Read),
//		.wea			(SD_Write),
//		.addra			(SD_Address),
//		.dina			(SD_Data_i),
//		.douta			(SD_Data_o),
//		.dreadya		(SD_Ready));
		
        SD_Module_Interface SD(
            .Clock          (clock),
            .Reset          (reset),
            .MISO_in        (MISO),
            .MOSI_out       (MOSI),
            .CS_out         (CSn),
            .SD_Clock       (SClk),
            .CurrentState   (CurrentState),
            .Read_in        (SD_Read),
            .Write_in       (SD_Write),
            .Ready_out      (SD_Ready),
            .Address_in     (SD_Address),
            .DDR_Data_out   (SD_Data_i),
            .DDR_Data_in    (SD_Data_o) 
            );
		
/*    DDR_Interface(
        .Clock_in       (Memory_Clock_in), //200MHz
        .Reset_in       (DDR_Reset_in),
        .Address_in     (SD_Address),
        .Data_in        (SD_Data_i),
        .Data_out       (SD_Data_o),
        .Read_in        (SD_Read),
        .Write_in       (SD_Write),
        .Ready_out      (SD_Ready),
            // Inouts
        .ddr2_dq        (ddr2_dq),
        .ddr2_dqs_n     (ddr2_dqs_n),
        .ddr2_dqs_p     (ddr2_dqs_p),
            // Outputs
        .ddr2_addr      (ddr2_addr),
        .ddr2_ba        (ddr2_ba),
        .ddr2_ras_n     (ddr2_ras_n),
        .ddr2_cas_n     (ddr2_cas_n),
        .ddr2_we_n      (ddr2_we_n),
        .ddr2_ck_p      (ddr2_ck_p),
        .ddr2_ck_n      (ddr2_ck_n),
        .ddr2_cke       (ddr2_cke),
        .ddr2_cs_n      (ddr2_cs_n),
        .ddr2_dm        (ddr2_dm),
        .ddr2_odt       (ddr2_odt));*/
            

endmodule
