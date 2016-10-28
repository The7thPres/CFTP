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
module Processor(
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
	output InstMem_Read,
	// Register Voting Signals
	input  [1853:0] Vote_in,
	output [1853:0] Vote_out
	);

   `include "MIPS_Parameters.v"


   /*** MIPS Instruction and Components (ID Stage) ***/
   wire [31:0] Instruction;
   wire [5:0]  OpCode = Instruction[31:26];
   wire [4:0]  Rs = Instruction[25:21];
   wire [4:0]  Rt = Instruction[20:16];
   wire [4:0]  Rd = Instruction[15:11];
   wire [5:0]  Funct = Instruction[5:0];
   wire [15:0] Immediate = Instruction[15:0];
   wire [25:0] JumpAddress = Instruction[25:0];
   wire [2:0]  Cp0_Sel = Instruction[2:0];

   /*** IF (Instruction Fetch) Signals ***/
   wire IF_Stall, IF_Flush;
   wire IF_EXC_AdIF;
   wire IF_Exception_Stall;
   wire IF_Exception_Flush;
   wire IF_IsBDS;
   wire [31:0] IF_PCAdd4, IF_PC_PreExc, IF_PCIn, IF_PCOut, IF_Instruction;

   /*** ID (Instruction Decode) Signals ***/
   wire ID_Stall;
   wire [1:0] ID_PCSrc;
   wire [1:0] ID_RsFwdSel, ID_RtFwdSel;
   wire ID_Link, ID_Movn, ID_Movz;
   wire ID_SignExtend;
   wire ID_LLSC;
   wire ID_RegDst, ID_ALUSrcImm, ID_MemWrite, ID_MemRead, ID_MemByte, ID_MemHalf, ID_MemSignExtend, ID_RegWrite, ID_MemtoReg;
   wire [4:0] ID_ALUOp;
   wire ID_Mfc0, ID_Mtc0, ID_Eret;
   wire ID_NextIsDelay;
   wire ID_CanErr, ID_ID_CanErr, ID_EX_CanErr, ID_M_CanErr;
   wire ID_KernelMode;
   wire ID_ReverseEndian;
   wire ID_Trap, ID_TrapCond;
   wire ID_EXC_Sys, ID_EXC_Bp, ID_EXC_RI;
   wire ID_Exception_Stall;
   wire ID_Exception_Flush;
   wire ID_PCSrc_Exc;
   wire [31:0] ID_ExceptionPC;
   wire ID_CP1, ID_CP2, ID_CP3;
   wire [31:0] ID_PCAdd4;
   wire [31:0] ID_ReadData1_RF, ID_ReadData1_End;
   wire [31:0] ID_ReadData2_RF, ID_ReadData2_End;
   wire [31:0] CP0_RegOut;
   wire ID_CmpEQ, ID_CmpGZ, ID_CmpLZ, ID_CmpGEZ, ID_CmpLEZ;
   wire [29:0] ID_SignExtImm = (ID_SignExtend) ? {{14{Immediate[15]}}, Immediate} : {14'h0000, Immediate}; //More Explicit Sign Extend
   wire [31:0] ID_ImmLeftShift2 = {ID_SignExtImm[29:0], 2'b00};
   wire [31:0] ID_JumpAddress = {ID_PCAdd4[31:28], JumpAddress[25:0], 2'b00};
   wire [31:0] ID_BranchAddress;
   wire [31:0] ID_RestartPC;
   wire ID_IsBDS;
   wire ID_Left, ID_Right;
   wire ID_IsFlushed;

   /*** EX (Execute) Signals ***/
   wire EX_ALU_Stall, EX_Stall;
   wire [1:0] EX_RsFwdSel, EX_RtFwdSel;
   wire EX_Link;
   wire [1:0] EX_LinkRegDst;
   wire EX_ALUSrcImm;
   wire [4:0] EX_ALUOp;
   wire EX_Movn, EX_Movz;
   wire EX_LLSC;
   wire EX_MemRead, EX_MemWrite, EX_MemByte, EX_MemHalf, EX_MemSignExtend, EX_RegWrite, EX_MemtoReg;
   wire [4:0] EX_Rs, EX_Rt;
   wire EX_WantRsByEX, EX_NeedRsByEX, EX_WantRtByEX, EX_NeedRtByEX;
   wire EX_Trap, EX_TrapCond;
   wire EX_CanErr, EX_EX_CanErr, EX_M_CanErr;
   wire EX_KernelMode;
   wire EX_ReverseEndian;
   wire EX_Exception_Stall;
   wire EX_Exception_Flush;
   wire [31:0] EX_ReadData1_PR, EX_ReadData1_Fwd, EX_ReadData2_PR, EX_ReadData2_Fwd, EX_ReadData2_Imm;
   wire [31:0] EX_SignExtImm;
   wire [4:0] EX_Rd, EX_RtRd, EX_Shamt;
   wire [31:0] EX_ALUResult;
   wire EX_BZero;
   wire EX_EXC_Ov;
   wire [31:0] EX_RestartPC;
   wire EX_IsBDS;
   wire EX_Left, EX_Right;

   /*** MEM (Memory) Signals ***/
   wire M_Stall, M_Stall_Controller;
   wire M_LLSC;
   wire M_MemRead, M_MemWrite, M_MemByte, M_MemHalf, M_MemSignExtend;
   wire M_RegWrite, M_MemtoReg;
   wire M_WriteDataFwdSel;
   wire M_EXC_AdEL, M_EXC_AdES;
   wire M_M_CanErr;
   wire M_KernelMode;
   wire M_ReverseEndian;
   wire M_Trap, M_TrapCond;
   wire M_EXC_Tr;
   wire M_Exception_Flush;
   wire [31:0] M_ALUResult, M_ReadData2_PR;
   wire [4:0] M_RtRd;
   wire [31:0] M_MemReadData;
   wire [31:0] M_RestartPC;
   wire M_IsBDS;
   wire [31:0] M_WriteData_Pre;
   wire M_Left, M_Right;
   wire M_Exception_Stall;

   /*** WB (Writeback) Signals ***/
   wire WB_Stall, WB_RegWrite, WB_MemtoReg;
   wire [31:0] WB_ReadData, WB_ALUResult;
   wire [4:0]  WB_RtRd;
   wire [31:0] WB_WriteData;

   /*** Other Signals ***/
   wire [7:0] ID_DP_Hazards, HAZ_DP_Hazards;

   /*** Assignments ***/
   assign IF_Instruction = (IF_Stall) ? 32'h00000000 : InstMem_In;
   assign IF_IsBDS = ID_NextIsDelay;
   assign HAZ_DP_Hazards = {ID_DP_Hazards[7:4], EX_WantRsByEX, EX_NeedRsByEX, EX_WantRtByEX, EX_NeedRtByEX};
   assign IF_EXC_AdIF = IF_PCOut[1] | IF_PCOut[0];
   assign ID_CanErr = ID_ID_CanErr | ID_EX_CanErr | ID_M_CanErr;
   assign EX_CanErr = EX_EX_CanErr | EX_M_CanErr;

   // External Memory Interface
//	reg vote_IRead, vote_IReadMask;
//	assign IRead = Vote_in[0];
//	assign IReadMask = Vote_in[1];
   assign InstMem_Address = IF_PCOut[31:2];
   assign DataMem_Address = M_ALUResult[31:2];
/*   always @(posedge clock) begin
		vote_IRead <= (reset) ? 1'b1 : ~InstMem_Ready;
      vote_IReadMask <= (reset) ? 1'b0 : ((IRead & InstMem_Ready) ? 1'b1 : ((~IF_Stall) ? 1'b0 : IReadMask));
   end*/
   assign InstMem_Read = 1'b1;
//	assign Vote_out[0] = vote_IRead;
//	assign Vote_out[1] = vote_IReadMask;

   /*** Datapath Controller ***/
   Control Controller (
		.ID_Stall       (ID_Stall),
      .OpCode         (OpCode),
      .Funct          (Funct),
      .Rs             (Rs),
      .Rt             (Rt),
      .Cmp_EQ         (ID_CmpEQ),
      .Cmp_GZ         (ID_CmpGZ),
      .Cmp_GEZ        (ID_CmpGEZ),
      .Cmp_LZ         (ID_CmpLZ),
      .Cmp_LEZ        (ID_CmpLEZ),
      .IF_Flush       (IF_Flush),
      .DP_Hazards     (ID_DP_Hazards),
      .PCSrc          (ID_PCSrc),
      .SignExtend     (ID_SignExtend),
      .Link           (ID_Link),
      .Movn           (ID_Movn),
      .Movz           (ID_Movz),
      .Mfc0           (ID_Mfc0),
      .Mtc0           (ID_Mtc0),
      .CP1            (ID_CP1),
      .CP2            (ID_CP2),
      .CP3            (ID_CP3),
      .Eret           (ID_Eret),
      .Trap           (ID_Trap),
      .TrapCond       (ID_TrapCond),
      .EXC_Sys        (ID_EXC_Sys),
      .EXC_Bp         (ID_EXC_Bp),
      .EXC_RI         (ID_EXC_RI),
      .ID_CanErr      (ID_ID_CanErr),
      .EX_CanErr      (ID_EX_CanErr),
      .M_CanErr       (ID_M_CanErr),
      .NextIsDelay    (ID_NextIsDelay),
      .RegDst         (ID_RegDst),
      .ALUSrcImm      (ID_ALUSrcImm),
      .ALUOp          (ID_ALUOp),
      .LLSC           (ID_LLSC),
      .MemWrite       (ID_MemWrite),
      .MemRead        (ID_MemRead),
      .MemByte        (ID_MemByte),
      .MemHalf        (ID_MemHalf),
      .MemSignExtend  (ID_MemSignExtend),
      .Left           (ID_Left),
      .Right          (ID_Right),
      .RegWrite       (ID_RegWrite),
      .MemtoReg       (ID_MemtoReg)
   );

   /*** Hazard and Forward Control Unit ***/
   Hazard_Detection HazardControl (
      .DP_Hazards          (HAZ_DP_Hazards),
      .ID_Rs               (Rs),
      .ID_Rt               (Rt),
      .EX_Rs               (EX_Rs),
      .EX_Rt               (EX_Rt),
      .EX_RtRd             (EX_RtRd),
      .MEM_RtRd            (M_RtRd),
      .WB_RtRd             (WB_RtRd),
      .EX_Link             (EX_Link),
      .EX_RegWrite         (EX_RegWrite),
      .MEM_RegWrite        (M_RegWrite),
      .WB_RegWrite         (WB_RegWrite),
      .MEM_MemRead         (M_MemRead),
      .MEM_MemWrite        (M_MemWrite),
      .InstMem_Read        (InstMem_Read),
      .InstMem_Ready       (InstMem_Ready),
      .Mfc0                (ID_Mfc0),
      .IF_Exception_Stall  (IF_Exception_Stall),
      .ID_Exception_Stall  (ID_Exception_Stall),
      .EX_Exception_Stall  (EX_Exception_Stall),
      .EX_ALU_Stall        (EX_ALU_Stall),
      .M_Stall_Controller  (M_Stall_Controller),
      .IF_Stall            (IF_Stall),
      .ID_Stall            (ID_Stall),
      .EX_Stall            (EX_Stall),
      .M_Stall             (M_Stall),
      .WB_Stall            (WB_Stall),
      .ID_RsFwdSel         (ID_RsFwdSel),
      .ID_RtFwdSel         (ID_RtFwdSel),
      .EX_RsFwdSel         (EX_RsFwdSel),
      .EX_RtFwdSel         (EX_RtFwdSel),
      .M_WriteDataFwdSel   (M_WriteDataFwdSel)
   );

   /*** Coprocessor 0: Exceptions and Interrupts ***/
   CPZero CP0 (
      .clock               (clock),
      .Mfc0                (ID_Mfc0),
      .Mtc0                (ID_Mtc0),
      .IF_Stall            (IF_Stall),
      .ID_Stall            (ID_Stall),
      .COP1                (ID_CP1),
      .COP2                (ID_CP2),
      .COP3                (ID_CP3),
      .ERET                (ID_Eret),
      .Rd                  (Rd),
      .Sel                 (Cp0_Sel),
      .Reg_In              (ID_ReadData2_End),
      .Reg_Out             (CP0_RegOut),
      .KernelMode          (ID_KernelMode),
      .ReverseEndian       (ID_ReverseEndian),
      .Int                 (Interrupts),
      .reset               (reset),
      .EXC_NMI             (NMI),
      .EXC_AdIF            (IF_EXC_AdIF),
      .EXC_AdEL            (M_EXC_AdEL),
      .EXC_AdES            (M_EXC_AdES),
      .EXC_Ov              (EX_EXC_Ov),
      .EXC_Tr              (M_EXC_Tr),
      .EXC_Sys             (ID_EXC_Sys),
      .EXC_Bp              (ID_EXC_Bp),
      .EXC_RI              (ID_EXC_RI),
      .ID_RestartPC        (ID_RestartPC),
      .EX_RestartPC        (EX_RestartPC),
      .M_RestartPC         (M_RestartPC),
      .ID_IsFlushed        (ID_IsFlushed),
      .IF_IsBD             (IF_IsBDS),
      .ID_IsBD             (ID_IsBDS),
      .EX_IsBD             (EX_IsBDS),
      .M_IsBD              (M_IsBDS),
      .BadAddr_M           (M_ALUResult),
      .BadAddr_IF          (IF_PCOut),
      .ID_CanErr           (ID_CanErr),
      .EX_CanErr           (EX_CanErr),
      .M_CanErr            (M_M_CanErr),
      .IF_Exception_Stall  (IF_Exception_Stall),
      .ID_Exception_Stall  (ID_Exception_Stall),
      .EX_Exception_Stall  (EX_Exception_Stall),
      .M_Exception_Stall   (M_Exception_Stall),
      .IF_Exception_Flush  (IF_Exception_Flush),
      .ID_Exception_Flush  (ID_Exception_Flush),
      .EX_Exception_Flush  (EX_Exception_Flush),
      .M_Exception_Flush   (M_Exception_Flush),
      .Exc_PC_Sel          (ID_PCSrc_Exc),
      .Exc_PC_Out          (ID_ExceptionPC), 
	  .reset_r			   (Vote_in[2]), 
		.Status_BEV				(Vote_in[3]), 
		.Status_NMI				(Vote_in[4]), 
		.Status_ERL				(Vote_in[5]), 
		.ErrorEPC				(Vote_in[37:6]), 
		.Count					(Vote_in[69:38]), 
		.Compare					(Vote_in[101:70]), 
		.Status_CU_0			(Vote_in[102]), 
		.Status_RE				(Vote_in[103]), 
		.Status_IM				(Vote_in[111:104]), 
		.Status_UM				(Vote_in[112]), 
		.Status_IE				(Vote_in[113]), 
		.Cause_IV				(Vote_in[114]), 
		.Cause_IP				(Vote_in[122:115]), 
		.Cause_BD				(Vote_in[123]), 
		.Cause_CE				(Vote_in[125:124]), 
		.Cause_ExcCode30		(Vote_in[129:126]), 
		.Status_EXL				(Vote_in[130]), 
		.EPC						(Vote_in[162:131]), 
		.BadVAddr				(Vote_in[194:163]), 
		.vote_reset_r			(Vote_out[2]), 
		.vote_Status_BEV		(Vote_out[3]), 
		.vote_Status_NMI		(Vote_out[4]), 
		.vote_Status_ERL		(Vote_out[5]), 
		.vote_ErrorEPC			(Vote_out[37:6]), 
		.vote_Count				(Vote_out[69:38]), 
		.vote_Compare			(Vote_out[101:70]), 
		.vote_Status_CU_0		(Vote_out[102]), 
		.vote_Status_RE		(Vote_out[103]), 
		.vote_Status_IM		(Vote_out[111:104]), 
		.vote_Status_UM		(Vote_out[112]), 
		.vote_Status_IE		(Vote_out[113]), 
		.vote_Cause_IV			(Vote_out[114]), 
		.vote_Cause_IP			(Vote_out[122:115]), 
		.vote_Cause_BD			(Vote_out[123]), 
		.vote_Cause_CE			(Vote_out[125:124]), 
		.vote_Cause_ExcCode30(Vote_out[129:126]), 
		.vote_Status_EXL		(Vote_out[130]), 
		.vote_EPC				(Vote_out[162:131]), 
		.vote_BadVAddr			(Vote_out[194:163])
   );

   /*** PC Source Non-Exception Mux ***/
   Mux4 #(.WIDTH(32)) PCSrcStd_Mux (
      .sel  (ID_PCSrc),
      .in0  (IF_PCAdd4),
      .in1  (ID_JumpAddress),
      .in2  (ID_BranchAddress),
      .in3  (ID_ReadData1_End),
      .out  (IF_PC_PreExc)
   );

   /*** PC Source Exception Mux ***/
   Mux2 #(.WIDTH(32)) PCSrcExc_Mux (
      .sel  (ID_PCSrc_Exc),
      .in0  (IF_PC_PreExc),
      .in1  (ID_ExceptionPC),
      .out  (IF_PCIn)
   );

   /*** Program Counter (MIPS spec is 0xBFC00000 starting address) ***/
   assign IF_PCOut = Vote_in[226:195];
   Register #(.WIDTH(32), .INIT(`EXC_Vector_Base_Reset)) PC (
      .clock	(clock),
      .reset   (reset),
      //.enable  (~IF_Stall),   // XXX verify. HERE. Was 1 but on stall latches PC+4, ad nauseum.
      .enable 	(~(IF_Stall | ID_Stall)),
      .D       (IF_PCIn),
      .Q       (IF_PCOut),
	   .vote_Q  (Vote_out[226:195])
   );

   /*** PC +4 Adder ***/
   Add PC_Add4 (
      .A  (IF_PCOut),
      .B  (32'h00000004),
      .C  (IF_PCAdd4)
   );

   /*** Instruction Fetch -> Instruction Decode Stage Register ***/
   assign Instruction = Vote_in[258:227];
   assign ID_PCAdd4 = Vote_in[290:259];
   assign ID_IsBDS = Vote_in[291];
	assign ID_RestartPC = Vote_in[323:292];
   assign ID_IsFlushed = Vote_in[324];
   IFID_Stage IFID (
      .clock           		(clock),
      .reset           		(reset),
      .IF_Flush        		(IF_Exception_Flush | IF_Flush),
      .IF_Stall        		(IF_Stall),
      .ID_Stall        		(ID_Stall),
      .IF_Instruction  		(IF_Instruction),
      .IF_PCAdd4       		(IF_PCAdd4),
      .IF_PC           		(IF_PCOut),
      .IF_IsBDS        		(IF_IsBDS),
      .ID_Instruction  		(Instruction),
      .ID_PCAdd4       		(ID_PCAdd4),
      .ID_IsBDS        		(ID_IsBDS),
		.ID_RestartPC    		(ID_RestartPC),
      .ID_IsFlushed    		(ID_IsFlushed),
		.vote_ID_Instruction	(Vote_out[258:227]), 
		.vote_ID_PCAdd4		(Vote_out[290:259]), 
		.vote_ID_IsBDS			(Vote_out[291]),
		.vote_ID_RestartPC	(Vote_out[323:292]), 
		.vote_ID_IsFlushed	(Vote_out[324])
   );

   /*** Register File ***/
   RegisterFile RegisterFile (
      .clock      	(clock),
      .reset      	(reset),
      .ReadReg1   	(Rs),
      .ReadReg2   	(Rt),
      .WriteReg   	(WB_RtRd),
      .WriteData  	(WB_WriteData),
      .RegWrite   	(WB_RegWrite),
      .ReadData1  	(ID_ReadData1_RF),
      .ReadData2  	(ID_ReadData2_RF),
	   .registers_in	(Vote_in[1316:325]), 
		.registers_out	(Vote_out[1316:325])
   );

   /*** ID Rs Forwarding/Link Mux ***/
   Mux4 #(.WIDTH(32)) IDRsFwd_Mux (
      .sel  (ID_RsFwdSel),
      .in0  (ID_ReadData1_RF),
      .in1  (M_ALUResult),
      .in2  (WB_WriteData),
      .in3  (32'h00000000),
      .out  (ID_ReadData1_End)
   );

   /*** ID Rt Forwarding/CP0 Mfc0 Mux ***/
   Mux4 #(.WIDTH(32)) IDRtFwd_Mux (
      .sel  (ID_RtFwdSel),
      .in0  (ID_ReadData2_RF),
      .in1  (M_ALUResult),
      .in2  (WB_WriteData),
      .in3  (CP0_RegOut),
      .out  (ID_ReadData2_End)
   );

   /*** Condition Compare Unit ***/
   Compare Compare (
      .A    (ID_ReadData1_End),
      .B    (ID_ReadData2_End),
      .EQ   (ID_CmpEQ),
      .GZ   (ID_CmpGZ),
      .LZ   (ID_CmpLZ),
      .GEZ  (ID_CmpGEZ),
      .LEZ  (ID_CmpLEZ)
   );

   /*** Branch Address Adder ***/
   Add BranchAddress_Add (
      .A  (ID_PCAdd4),
      .B  (ID_ImmLeftShift2),
      .C  (ID_BranchAddress)
   );

   /*** Instruction Decode -> Execute Pipeline Stage ***/
   assign EX_Link = Vote_in[1317];
   assign EX_ALUSrcImm = Vote_in[1319];
   assign EX_ALUOp = Vote_in[1324:1320];
   assign EX_Movn = Vote_in[1325];
   assign EX_Movz = Vote_in[1326];
   assign EX_LLSC = Vote_in[1327];
   assign EX_MemRead = Vote_in[1328];
   assign EX_MemWrite = Vote_in[1329];
   assign EX_MemByte = Vote_in[1330];
   assign EX_MemHalf = Vote_in[1331];
   assign EX_MemSignExtend = Vote_in[1332];
   assign EX_Left = Vote_in[1333];
   assign EX_Right = Vote_in[1334];
   assign EX_RegWrite = Vote_in[1335];
   assign EX_MemtoReg = Vote_in[1336];
   assign EX_ReverseEndian = Vote_in[1337];
   assign EX_RestartPC = Vote_in[1369:1338];
   assign EX_IsBDS = Vote_in[1370];
   assign EX_Trap = Vote_in[1371];
   assign EX_TrapCond = Vote_in[1372];
   assign EX_EX_CanErr = Vote_in[1373];
   assign EX_M_CanErr = Vote_in[1374];
   assign EX_ReadData1_PR = Vote_in[1406:1375];
   assign EX_ReadData2_PR = Vote_in[1438:1407];
	assign EX_Rs = Vote_in[1460:1456];
   assign EX_Rt = Vote_in[1465:1461];
   assign EX_WantRsByEX = Vote_in[1466];
   assign EX_NeedRsByEX = Vote_in[1467];
   assign EX_WantRtByEX = Vote_in[1468];
   assign EX_NeedRtByEX = Vote_in[1469];
   assign EX_KernelMode = Vote_in[1470];
   
	
	IDEX_Stage IDEX (
      .clock             		(clock),
      .reset             		(reset),
      .ID_Flush          		(ID_Exception_Flush),
      .ID_Stall          		(ID_Stall),
      .EX_Stall          		(EX_Stall),
      .ID_Link           		(ID_Link),
      .ID_RegDst         		(ID_RegDst),
      .ID_ALUSrcImm      		(ID_ALUSrcImm),
      .ID_ALUOp          		(ID_ALUOp),
      .ID_Movn           		(ID_Movn),
      .ID_Movz           		(ID_Movz),
      .ID_LLSC           		(ID_LLSC),
      .ID_MemRead        		(ID_MemRead),
      .ID_MemWrite       		(ID_MemWrite),
      .ID_MemByte        		(ID_MemByte),
      .ID_MemHalf        		(ID_MemHalf),
      .ID_MemSignExtend  		(ID_MemSignExtend),
      .ID_Left           		(ID_Left),
      .ID_Right          		(ID_Right),
      .ID_RegWrite       		(ID_RegWrite),
      .ID_MemtoReg       		(ID_MemtoReg),
      .ID_ReverseEndian  		(ID_ReverseEndian),
      .ID_Rs             		(Rs),
      .ID_Rt             		(Rt),
      .ID_WantRsByEX     		(ID_DP_Hazards[3]),
      .ID_NeedRsByEX     		(ID_DP_Hazards[2]),
      .ID_WantRtByEX     		(ID_DP_Hazards[1]),
      .ID_NeedRtByEX     		(ID_DP_Hazards[0]),
      .ID_KernelMode     		(ID_KernelMode),
      .ID_RestartPC      		(ID_RestartPC),
      .ID_IsBDS          		(ID_IsBDS),
      .ID_Trap           		(ID_Trap),
      .ID_TrapCond       		(ID_TrapCond),
      .ID_EX_CanErr      		(ID_EX_CanErr),
      .ID_M_CanErr       		(ID_M_CanErr),
      .ID_ReadData1      		(ID_ReadData1_End),
      .ID_ReadData2      		(ID_ReadData2_End),
      .ID_SignExtImm     		(ID_SignExtImm[16:0]),
      .EX_Link           		(EX_Link),
      .EX_RegDst					(Vote_in[1318]),
		.EX_LinkRegDst     		(EX_LinkRegDst),
      .EX_ALUSrcImm      		(EX_ALUSrcImm),
      .EX_ALUOp          		(EX_ALUOp),
      .EX_Movn           		(EX_Movn),
      .EX_Movz           		(EX_Movz),
      .EX_LLSC           		(EX_LLSC),
      .EX_MemRead        		(EX_MemRead),
      .EX_MemWrite       		(EX_MemWrite),
      .EX_MemByte        		(EX_MemByte),
      .EX_MemHalf        		(EX_MemHalf),
      .EX_MemSignExtend  		(EX_MemSignExtend),
      .EX_Left           		(EX_Left),
      .EX_Right          		(EX_Right),
      .EX_RegWrite       		(EX_RegWrite),
      .EX_MemtoReg       		(EX_MemtoReg),
      .EX_ReverseEndian  		(EX_ReverseEndian),
      .EX_RestartPC      		(EX_RestartPC),
      .EX_IsBDS          		(EX_IsBDS),
      .EX_Trap           		(EX_Trap),
      .EX_TrapCond       		(EX_TrapCond),
      .EX_EX_CanErr      		(EX_EX_CanErr),
      .EX_M_CanErr       		(EX_M_CanErr),
      .EX_ReadData1      		(EX_ReadData1_PR),
      .EX_ReadData2      		(EX_ReadData2_PR),
      .EX_SignExtImm_pre		(Vote_in[1455:1439]),
		.EX_Rs             		(EX_Rs),
      .EX_Rt             		(EX_Rt),
      .EX_WantRsByEX     		(EX_WantRsByEX),
      .EX_NeedRsByEX     		(EX_NeedRsByEX),
      .EX_WantRtByEX     		(EX_WantRtByEX),
      .EX_NeedRtByEX     		(EX_NeedRtByEX),
      .EX_KernelMode     		(EX_KernelMode),
		.EX_SignExtImm     		(EX_SignExtImm),
      .EX_Rd             		(EX_Rd),
      .EX_Shamt          		(EX_Shamt),
		.vote_EX_Link				(Vote_out[1317]), 
		.vote_EX_RegDst			(Vote_out[1318]),
		.vote_EX_ALUSrcImm		(Vote_out[1319]), 
		.vote_EX_ALUOp				(Vote_out[1324:1320]), 
		.vote_EX_Movn				(Vote_out[1325]), 
		.vote_EX_Movz				(Vote_out[1326]), 
		.vote_EX_LLSC				(Vote_out[1327]), 
		.vote_EX_MemRead			(Vote_out[1328]), 
		.vote_EX_MemWrite			(Vote_out[1329]), 
		.vote_EX_MemByte			(Vote_out[1330]), 
		.vote_EX_MemHalf			(Vote_out[1331]), 
		.vote_EX_MemSignExtend	(Vote_out[1332]), 
		.vote_EX_Left				(Vote_out[1333]), 
		.vote_EX_Right				(Vote_out[1334]), 
		.vote_EX_RegWrite			(Vote_out[1335]), 
		.vote_EX_MemtoReg			(Vote_out[1336]), 
		.vote_EX_ReverseEndian	(Vote_out[1337]), 
		.vote_EX_RestartPC		(Vote_out[1369:1338]), 
		.vote_EX_IsBDS				(Vote_out[1370]), 
		.vote_EX_Trap				(Vote_out[1371]), 
		.vote_EX_TrapCond			(Vote_out[1372]), 
		.vote_EX_EX_CanErr		(Vote_out[1373]), 
		.vote_EX_M_CanErr			(Vote_out[1374]), 
		.vote_EX_ReadData1		(Vote_out[1406:1375]), 
		.vote_EX_ReadData2		(Vote_out[1438:1407]),
		.vote_EX_SignExtImm_pre	(Vote_out[1455:1439]),
		.vote_EX_Rs					(Vote_out[1460:1456]), 
		.vote_EX_Rt					(Vote_out[1465:1461]), 
		.vote_EX_WantRsByEX		(Vote_out[1466]), 
		.vote_EX_NeedRsByEX		(Vote_out[1467]), 
		.vote_EX_WantRtByEX		(Vote_out[1468]), 
		.vote_EX_NeedRtByEX		(Vote_out[1469]), 
		.vote_EX_KernelMode		(Vote_out[1470]) 
   );

   /*** EX Rs Forwarding Mux ***/
   Mux4 #(.WIDTH(32)) EXRsFwd_Mux (
      .sel  (EX_RsFwdSel),
      .in0  (EX_ReadData1_PR),
      .in1  (M_ALUResult),
      .in2  (WB_WriteData),
      .in3  (EX_RestartPC),
      .out  (EX_ReadData1_Fwd)
   );

   /*** EX Rt Forwarding / Link Mux ***/
   Mux4 #(.WIDTH(32)) EXRtFwdLnk_Mux (
      .sel  (EX_RtFwdSel),
      .in0  (EX_ReadData2_PR),
      .in1  (M_ALUResult),
      .in2  (WB_WriteData),
      .in3  (32'h00000008),
      .out  (EX_ReadData2_Fwd)
   );

   /*** EX ALU Immediate Mux ***/
   Mux2 #(.WIDTH(32)) EXALUImm_Mux (
      .sel  (EX_ALUSrcImm),
      .in0  (EX_ReadData2_Fwd),
      .in1  (EX_SignExtImm),
      .out  (EX_ReadData2_Imm)
   );

   /*** EX RtRd / Link Mux ***/
   Mux4 #(.WIDTH(5)) EXRtRdLnk_Mux (
      .sel  (EX_LinkRegDst),
      .in0  (EX_Rt),
      .in1  (EX_Rd),
      .in2  (5'b11111),
      .in3  (5'b00000),
      .out  (EX_RtRd)
   );

   /*** Arithmetic Logic Unit ***/
   ALU ALU (
      .clock      		(clock),
      .reset      		(reset),
      .EX_Stall   		(EX_Stall),
      .EX_Flush   		(EX_Exception_Flush),
      .A          		(EX_ReadData1_Fwd),
      .B          		(EX_ReadData2_Imm),
      .Operation  		(EX_ALUOp),
      .Shamt      		(EX_Shamt),
      .Result     		(EX_ALUResult),
      .BZero      		(EX_BZero),
      .EXC_Ov     		(EX_EXC_Ov),
      .ALU_Stall  		(EX_ALU_Stall),
		.HILO					(Vote_in[1534:1471]), 
		.div_fsm				(Vote_in[1535]), 
		.vote_HILO			(Vote_out[1534:1471]), 
		.vote_div_fsm		(Vote_out[1535]), 
		.active				(Vote_in[1536]), 
		.neg					(Vote_in[1537]), 
		.div_result			(Vote_in[1569:1538]), 
		.denom				(Vote_in[1601:1570]), 
		.work					(Vote_in[1633:1602]), 
		.vote_active		(Vote_out[1536]), 
		.vote_neg			(Vote_out[1537]), 
		.vote_div_result	(Vote_out[1569:1538]), 
		.vote_denom			(Vote_out[1601:1570]), 
		.vote_work			(Vote_out[1633:1602])
   );

   /*** Execute -> Memory Pipeline Stage ***/
   assign M_RegWrite = Vote_in[1634];
   assign M_MemtoReg = Vote_in[1635];
   assign M_ReverseEndian = Vote_in[1636];
   assign M_LLSC = Vote_in[1637];
   assign M_MemRead = Vote_in[1638];
   assign M_MemWrite = Vote_in[1639];
   assign M_MemByte = Vote_in[1640];
   assign M_MemHalf = Vote_in[1641];
   assign M_MemSignExtend = Vote_in[1642];
   assign M_Left = Vote_in[1643];
   assign M_Right = Vote_in[1644];
   assign M_KernelMode = Vote_in[1645];
   assign M_RestartPC = Vote_in[1677:1646];
   assign M_IsBDS = Vote_in[1678];
   assign M_Trap = Vote_in[1679];
   assign M_TrapCond = Vote_in[1680];
   assign M_M_CanErr = Vote_in[1681];
   assign M_ALUResult = Vote_in[1713:1682];
   assign M_ReadData2_PR = Vote_in[1745:1714];
   assign M_RtRd = Vote_in[1750:1746];
	EXMEM_Stage EXMEM (
      .clock             		(clock),
      .reset             		(reset),
      .EX_Flush          		(EX_Exception_Flush),
      .EX_Stall          		(EX_Stall),
      .M_Stall           		(M_Stall),
      .EX_Movn           		(EX_Movn),
      .EX_Movz           		(EX_Movz),
      .EX_BZero          		(EX_BZero),
      .EX_RegWrite       		(EX_RegWrite),
      .EX_MemtoReg       		(EX_MemtoReg),
      .EX_ReverseEndian  		(EX_ReverseEndian),
      .EX_LLSC           		(EX_LLSC),
      .EX_MemRead        		(EX_MemRead),
      .EX_MemWrite       		(EX_MemWrite),
      .EX_MemByte        		(EX_MemByte),
      .EX_MemHalf        		(EX_MemHalf),
      .EX_MemSignExtend  		(EX_MemSignExtend),
      .EX_Left           		(EX_Left),
      .EX_Right          		(EX_Right),
      .EX_KernelMode     		(EX_KernelMode),
      .EX_RestartPC      		(EX_RestartPC),
      .EX_IsBDS          		(EX_IsBDS),
      .EX_Trap           		(EX_Trap),
      .EX_TrapCond       		(EX_TrapCond),
      .EX_M_CanErr       		(EX_M_CanErr),
      .EX_ALU_Result     		(EX_ALUResult),
      .EX_ReadData2      		(EX_ReadData2_Fwd),
      .EX_RtRd           		(EX_RtRd),
      .M_RegWrite        		(M_RegWrite),
      .M_MemtoReg        		(M_MemtoReg),
      .M_ReverseEndian   		(M_ReverseEndian),
      .M_LLSC            		(M_LLSC),
      .M_MemRead         		(M_MemRead),
      .M_MemWrite        		(M_MemWrite),
      .M_MemByte        		(M_MemByte),
      .M_MemHalf         		(M_MemHalf),
      .M_MemSignExtend   		(M_MemSignExtend),
      .M_Left            		(M_Left),
      .M_Right           		(M_Right),
      .M_KernelMode      		(M_KernelMode),
      .M_RestartPC       		(M_RestartPC),
      .M_IsBDS           		(M_IsBDS),
      .M_Trap            		(M_Trap),
      .M_TrapCond        		(M_TrapCond),
      .M_M_CanErr        		(M_M_CanErr),
      .M_ALU_Result      		(M_ALUResult),
      .M_ReadData2       		(M_ReadData2_PR),
      .M_RtRd            		(M_RtRd),
		.vote_M_RegWrite			(Vote_out[1634]), 
		.vote_M_MemtoReg			(Vote_out[1635]), 
		.vote_M_ReverseEndian	(Vote_out[1636]), 
		.vote_M_LLSC				(Vote_out[1637]), 
		.vote_M_MemRead			(Vote_out[1638]), 
		.vote_M_MemWrite			(Vote_out[1639]), 
		.vote_M_MemByte			(Vote_out[1640]), 
		.vote_M_MemHalf			(Vote_out[1641]), 
		.vote_M_MemSignExtend	(Vote_out[1642]), 
		.vote_M_Left				(Vote_out[1643]), 
		.vote_M_Right				(Vote_out[1644]), 
		.vote_M_KernelMode		(Vote_out[1645]), 
		.vote_M_RestartPC			(Vote_out[1677:1646]), 
		.vote_M_IsBDS				(Vote_out[1678]), 
		.vote_M_Trap				(Vote_out[1679]), 
		.vote_M_TrapCond			(Vote_out[1680]), 
		.vote_M_M_CanErr			(Vote_out[1681]), 
		.vote_M_ALU_Result		(Vote_out[1713:1682]), 
		.vote_M_ReadData2			(Vote_out[1745:1714]), 
		.vote_M_RtRd				(Vote_out[1750:1746])
   );

   /*** Trap Detection Unit ***/
   TrapDetect TrapDetect (
      .Trap       (M_Trap),
      .TrapCond   (M_TrapCond),
      .ALUResult  (M_ALUResult),
      .EXC_Tr     (M_EXC_Tr)
   );

   /*** MEM Write Data Mux ***/
   Mux2 #(.WIDTH(32)) MWriteData_Mux (
      .sel  (M_WriteDataFwdSel),
      .in0  (M_ReadData2_PR),
      .in1  (WB_WriteData),
      .out  (M_WriteData_Pre)
   );

   /*** Data Memory Controller ***/
   MemControl DataMem_Controller (
      .clock         	(clock),
      .reset         	(reset),
      .DataIn        	(M_WriteData_Pre),
      .Address       	(M_ALUResult),
      .MReadData     	(DataMem_In),
      .MemRead       	(M_MemRead),
      .MemWrite      	(M_MemWrite),
      .DataMem_Ready 	(DataMem_Ready),
      .Byte          	(M_MemByte),
      .Half          	(M_MemHalf),
      .SignExtend    	(M_MemSignExtend),
      .KernelMode    	(M_KernelMode),
      .ReverseEndian 	(M_ReverseEndian),
      .LLSC          	(M_LLSC),
      .ERET          	(ID_Eret),
      .Left          	(M_Left),
      .Right         	(M_Right),
      .M_Exception_Stall(M_Exception_Stall),
      .IF_Stall      	(IF_Stall),
      .DataOut       	(M_MemReadData),
      .MWriteData    	(DataMem_Out),
      .WriteEnable   	(DataMem_Write),
      .ReadEnable    	(DataMem_Read),
      .M_Stall       	(M_Stall_Controller),
      .EXC_AdEL      	(M_EXC_AdEL),
      .EXC_AdES      	(M_EXC_AdES),
		.LLSC_Address		(Vote_in[1780:1751]), 
		.LLSC_Atomic		(Vote_in[1781]), 
		.RW_Mask				(Vote_in[1782]), 
		.vote_LLSC_Address(Vote_out[1780:1751]), 
		.vote_LLSC_Atomic	(Vote_out[1781]), 
		.vote_RW_Mask		(Vote_out[1782])
   );

   /*** Memory -> Writeback Pipeline Stage ***/
   assign WB_RegWrite = Vote_in[1783];
   assign WB_MemtoReg = Vote_in[1784];
   assign WB_ReadData = Vote_in[1816:1785];
   assign WB_ALUResult = Vote_in[1848:1817];
   assign WB_RtRd = Vote_in[1853:1849];
	MEMWB_Stage MEMWB (
      .clock          		(clock),
      .reset          		(reset),
      .M_Flush        		(M_Exception_Flush),
      .M_Stall        		(M_Stall),
      .WB_Stall       		(WB_Stall),
      .M_RegWrite     		(M_RegWrite),
      .M_MemtoReg     		(M_MemtoReg),
      .M_ReadData     		(M_MemReadData),
      .M_ALU_Result   		(M_ALUResult),
      .M_RtRd         		(M_RtRd),
      .WB_RegWrite    		(WB_RegWrite),
      .WB_MemtoReg    		(WB_MemtoReg),
      .WB_ReadData    		(WB_ReadData),
      .WB_ALU_Result  		(WB_ALUResult),
      .WB_RtRd        		(WB_RtRd),
		.vote_WB_RegWrite		(Vote_out[1783]), 
		.vote_WB_MemtoReg		(Vote_out[1784]), 
		.vote_WB_ReadData		(Vote_out[1816:1785]), 
		.vote_WB_ALU_Result	(Vote_out[1848:1817]), 
		.vote_WB_RtRd			(Vote_out[1853:1849])
   );

   /*** WB MemtoReg Mux ***/
   Mux2 #(.WIDTH(32)) WBMemtoReg_Mux (
      .sel  (WB_MemtoReg),
      .in0  (WB_ALUResult),
      .in1  (WB_ReadData),
      .out  (WB_WriteData)
   );

endmodule

