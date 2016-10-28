`timescale 1ns / 1ps
/*
 * File         : IDEX_Stage.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   9-Jun-2011   GEA       Initial design.
 *   2.0   26-Jul-2012  GEA       Many updates have been made.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   The Pipeline Register to bridge the Instruction Decode
 *   and Execute stages.
 */
module IDEX_Stage(
    input  clock,
    input  reset,
    input  ID_Flush,
    input  ID_Stall,
    input  EX_Stall,
    // Control Signals
    input  ID_Link,
    input  ID_RegDst,
    input  ID_ALUSrcImm,
    input  [4:0] ID_ALUOp,
    input  ID_Movn,
    input  ID_Movz,
    input  ID_LLSC,
    input  ID_MemRead,
    input  ID_MemWrite,
    input  ID_MemByte,
    input  ID_MemHalf,
    input  ID_MemSignExtend,
    input  ID_Left,
    input  ID_Right,
    input  ID_RegWrite,
    input  ID_MemtoReg,
    input  ID_ReverseEndian,
    // Hazard & Forwarding
    input  [4:0] ID_Rs,
    input  [4:0] ID_Rt,
    input  ID_WantRsByEX,
    input  ID_NeedRsByEX,
    input  ID_WantRtByEX,
    input  ID_NeedRtByEX,
    // Exception Control/Info
    input  ID_KernelMode,
    input  [31:0] ID_RestartPC,
    input  ID_IsBDS,
    input  ID_Trap,
    input  ID_TrapCond,
    input  ID_EX_CanErr,
    input  ID_M_CanErr,
    // Data Signals
    input  [31:0] ID_ReadData1,
    input  [31:0] ID_ReadData2,
    input  [16:0] ID_SignExtImm, // ID_Rd, ID_Shamt included here
    // ----------------
    output [4:0] EX_Rd,
    output [4:0] EX_Shamt,
	 output [1:0] EX_LinkRegDst,
	 output [31:0] EX_SignExtImm,
	 // Voter Signals for Registers
	 input [16:0] EX_SignExtImm_pre,
	 input EX_RegDst,
	 input EX_Link,
    input EX_ALUSrcImm,
    input [4:0] EX_ALUOp,
    input EX_Movn,
    input EX_Movz,
    input EX_LLSC,
    input EX_MemRead,
    input EX_MemWrite,
    input EX_MemByte,
    input EX_MemHalf,
    input EX_MemSignExtend,
    input EX_Left,
    input EX_Right,
    input EX_RegWrite,
    input EX_MemtoReg,
    input EX_ReverseEndian,
    input [4:0]  EX_Rs,
    input [4:0]  EX_Rt,
    input EX_WantRsByEX,
    input EX_NeedRsByEX,
    input EX_WantRtByEX,
    input EX_NeedRtByEX,
    input EX_KernelMode,
    input [31:0] EX_RestartPC,
    input EX_IsBDS,
    input EX_Trap,
    input EX_TrapCond,
    input EX_EX_CanErr,
    input EX_M_CanErr,
    input [31:0] EX_ReadData1,
    input [31:0] EX_ReadData2,
	 output reg [16:0] vote_EX_SignExtImm_pre,
	 output reg vote_EX_RegDst,
	 output reg vote_EX_Link,
    output reg vote_EX_ALUSrcImm,
    output reg [4:0] vote_EX_ALUOp,
    output reg vote_EX_Movn,
    output reg vote_EX_Movz,
    output reg vote_EX_LLSC,
    output reg vote_EX_MemRead,
    output reg vote_EX_MemWrite,
    output reg vote_EX_MemByte,
    output reg vote_EX_MemHalf,
    output reg vote_EX_MemSignExtend,
    output reg vote_EX_Left,
    output reg vote_EX_Right,
    output reg vote_EX_RegWrite,
    output reg vote_EX_MemtoReg,
    output reg vote_EX_ReverseEndian,
    output reg [4:0]  vote_EX_Rs,
    output reg [4:0]  vote_EX_Rt,
    output reg vote_EX_WantRsByEX,
    output reg vote_EX_NeedRsByEX,
    output reg vote_EX_WantRtByEX,
    output reg vote_EX_NeedRtByEX,
    output reg vote_EX_KernelMode,
    output reg [31:0] vote_EX_RestartPC,
    output reg vote_EX_IsBDS,
    output reg vote_EX_Trap,
    output reg vote_EX_TrapCond,
    output reg vote_EX_EX_CanErr,
    output reg vote_EX_M_CanErr,
    output reg [31:0] vote_EX_ReadData1,
    output reg [31:0] vote_EX_ReadData2 
    );

    /***
     The purpose of a pipeline register is to capture data from one pipeline stage
     and provide it to the next pipeline stage. This creates at least one clock cycle
     of delay, but reduces the combinatorial path length of signals which allows for
     higher clock speeds.

     All pipeline registers update unless the forward stage is stalled. When this occurs
     or when the current stage is being flushed, the forward stage will receive data that
     is effectively a NOP and causes nothing to happen throughout the remaining pipeline
     traversal. In other words:

     A stall masks all control signals to forward stages. A flush permanently clears
     control signals to forward stages (but not certain data for exception purposes).
    ***/
	 
    assign EX_LinkRegDst = (EX_Link) ? 2'b10 : ((EX_RegDst) ? 2'b01 : 2'b00);
    assign EX_Rd = EX_SignExtImm[15:11];
    assign EX_Shamt = EX_SignExtImm[10:6];
    assign EX_SignExtImm = (EX_SignExtImm_pre[16]) ? {15'h7fff, EX_SignExtImm_pre[16:0]} : {15'h0000, EX_SignExtImm_pre[16:0]};

    always @(posedge clock) begin
        vote_EX_Link           <= (reset) ? 1'b0  : ((EX_Stall) ? EX_Link                                          : ID_Link);
        vote_EX_RegDst         <= (reset) ? 1'b0  : ((EX_Stall) ? EX_RegDst                                        : ID_RegDst);
        vote_EX_ALUSrcImm      <= (reset) ? 1'b0  : ((EX_Stall) ? EX_ALUSrcImm                                     : ID_ALUSrcImm);
        vote_EX_ALUOp          <= (reset) ? 5'b0  : ((EX_Stall) ? EX_ALUOp         : ((ID_Stall | ID_Flush) ? 5'b0 : ID_ALUOp));
        vote_EX_Movn           <= (reset) ? 1'b0  : ((EX_Stall) ? EX_Movn                                          : ID_Movn);
        vote_EX_Movz           <= (reset) ? 1'b0  : ((EX_Stall) ? EX_Movz                                          : ID_Movz);
        vote_EX_LLSC           <= (reset) ? 1'b0  : ((EX_Stall) ? EX_LLSC                                          : ID_LLSC);
        vote_EX_MemRead        <= (reset) ? 1'b0  : ((EX_Stall) ? EX_MemRead       : ((ID_Stall | ID_Flush) ? 1'b0 : ID_MemRead));
        vote_EX_MemWrite       <= (reset) ? 1'b0  : ((EX_Stall) ? EX_MemWrite      : ((ID_Stall | ID_Flush) ? 1'b0 : ID_MemWrite));
        vote_EX_MemByte        <= (reset) ? 1'b0  : ((EX_Stall) ? EX_MemByte                                       : ID_MemByte);
        vote_EX_MemHalf        <= (reset) ? 1'b0  : ((EX_Stall) ? EX_MemHalf                                       : ID_MemHalf);
        vote_EX_MemSignExtend  <= (reset) ? 1'b0  : ((EX_Stall) ? EX_MemSignExtend                                 : ID_MemSignExtend);
        vote_EX_Left           <= (reset) ? 1'b0  : ((EX_Stall) ? EX_Left                                          : ID_Left);
        vote_EX_Right          <= (reset) ? 1'b0  : ((EX_Stall) ? EX_Right                                         : ID_Right);
        vote_EX_RegWrite       <= (reset) ? 1'b0  : ((EX_Stall) ? EX_RegWrite      : ((ID_Stall | ID_Flush) ? 1'b0 : ID_RegWrite));
        vote_EX_MemtoReg       <= (reset) ? 1'b0  : ((EX_Stall) ? EX_MemtoReg                                      : ID_MemtoReg);
        vote_EX_ReverseEndian  <= (reset) ? 1'b0  : ((EX_Stall) ? EX_ReverseEndian                                 : ID_ReverseEndian);
        vote_EX_RestartPC      <= (reset) ? 32'b0 : ((EX_Stall) ? EX_RestartPC                                     : ID_RestartPC);
        vote_EX_IsBDS          <= (reset) ? 1'b0  : ((EX_Stall) ? EX_IsBDS                                         : ID_IsBDS);
        vote_EX_Trap           <= (reset) ? 1'b0  : ((EX_Stall) ? EX_Trap          : ((ID_Stall | ID_Flush) ? 1'b0 : ID_Trap));
        vote_EX_TrapCond       <= (reset) ? 1'b0  : ((EX_Stall) ? EX_TrapCond                                      : ID_TrapCond);
        vote_EX_EX_CanErr      <= (reset) ? 1'b0  : ((EX_Stall) ? EX_EX_CanErr     : ((ID_Stall | ID_Flush) ? 1'b0 : ID_EX_CanErr));
        vote_EX_M_CanErr       <= (reset) ? 1'b0  : ((EX_Stall) ? EX_M_CanErr      : ((ID_Stall | ID_Flush) ? 1'b0 : ID_M_CanErr));
        vote_EX_ReadData1      <= (reset) ? 32'b0 : ((EX_Stall) ? EX_ReadData1                                     : ID_ReadData1);
        vote_EX_ReadData2      <= (reset) ? 32'b0 : ((EX_Stall) ? EX_ReadData2                                     : ID_ReadData2);
        vote_EX_SignExtImm_pre <= (reset) ? 17'b0 : ((EX_Stall) ? EX_SignExtImm_pre                                : ID_SignExtImm);
        vote_EX_Rs             <= (reset) ? 5'b0  : ((EX_Stall) ? EX_Rs                                            : ID_Rs);
        vote_EX_Rt             <= (reset) ? 5'b0  : ((EX_Stall) ? EX_Rt                                            : ID_Rt);
        vote_EX_WantRsByEX     <= (reset) ? 1'b0  : ((EX_Stall) ? EX_WantRsByEX    : ((ID_Stall | ID_Flush) ? 1'b0 : ID_WantRsByEX));
        vote_EX_NeedRsByEX     <= (reset) ? 1'b0  : ((EX_Stall) ? EX_NeedRsByEX    : ((ID_Stall | ID_Flush) ? 1'b0 : ID_NeedRsByEX));
        vote_EX_WantRtByEX     <= (reset) ? 1'b0  : ((EX_Stall) ? EX_WantRtByEX    : ((ID_Stall | ID_Flush) ? 1'b0 : ID_WantRtByEX));
        vote_EX_NeedRtByEX     <= (reset) ? 1'b0  : ((EX_Stall) ? EX_NeedRtByEX    : ((ID_Stall | ID_Flush) ? 1'b0 : ID_NeedRtByEX));
        vote_EX_KernelMode     <= (reset) ? 1'b0  : ((EX_Stall) ? EX_KernelMode                                    : ID_KernelMode);
    end

endmodule
