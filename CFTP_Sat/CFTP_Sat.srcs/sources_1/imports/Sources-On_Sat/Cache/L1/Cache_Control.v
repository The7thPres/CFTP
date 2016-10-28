`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:45:22 07/05/2015 
// Design Name: 
// Module Name:    Cache_Control 
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
module Cache_Control(
    input [29:0] CPU_Address_in,
    input [3:0] CPU_Write_Data_in,
    input CPU_Read_in,
    output CPU_Ready_out,
	 input CPU_Flush_in,
	 output CPU_Flush_out,
	 output [29:0] MEM_Address_out,
    output MEM_Write_Data_out,
    output MEM_Read_out,
    input MEM_Ready_in,
	 output [3:0] Index_out,
	 output [6:0] Offset_out,
    output [3:0] Write_Data_out,
    input Dirty_in,
    output Dirty_out,
    output Write_Dirty_out,
    input Init_Dirty_in,
	 input [18:0] Tag_in,
    output Write_Valid_Tag_out,
    output Valid_out,
    input Init_Valid_in,
	 input Hit_in,
    input [7:0] Counter_in,
    output Reset_Counter_out,
	 output Counter_Enable_out,
	 input [7:0] Flush_Count_in,
    output Flush_Reset_Counter_out,
	 output Flush_Counter_Enable_out,
    input Clock_in,
    input Reset_in,
    output Reset_Valid_Dirty_out,
    output Fill_out
    );


// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
// State Encoding
// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
parameter STATE_CACHE_INIT			= 4'b0000;
parameter STATE_CACHE_IDLE			= 4'b0001;
parameter STATE_CACHE_REQUEST_ACK	= 4'b0010;
parameter STATE_CACHE_ALLOCATE 		= 4'b0011;
parameter STATE_CACHE_ALLOCATE_ACK 	= 4'b0100;
parameter STATE_CACHE_WRITEBACK		= 4'b0101;
parameter STATE_CACHE_WRITEBACK_ACK	= 4'b0110;
parameter STATE_CACHE_FLUSH			= 4'b1000;
parameter STATE_CACHE_FLUSH_ACK		= 4'b1010;
// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----


// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
// State reg Declarations
// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
reg [3:0] CurrentState ;
reg [3:0] NextState ;
// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----


// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
// Internal Signals
// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
//wire Reset_FSM;
wire CPU_Request;
wire [14:0] Tag;
// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----


// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
// Outputs
// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
// Continuous Assignments
assign CPU_Request = CPU_Read_in || (|CPU_Write_Data_in) || CPU_Flush_in ;
//assign Reset_FSM = (CurrentState == STATE_CACHE_REQUEST_ACK && (~CPU_Request)); 
assign Tag = (CurrentState == STATE_CACHE_WRITEBACK || CurrentState == STATE_CACHE_WRITEBACK_ACK) ?
				 Tag_in : CPU_Address_in[29:11];
// State Outputs
		//CPU Interface
assign CPU_Ready_out = Hit_in/*(CurrentState == STATE_CACHE_REQUEST_ACK) ? 1'b1 : 1'b0*/;
assign CPU_Flush_out = (CurrentState == STATE_CACHE_FLUSH_ACK) ? 1'b1 : 1'b0;
		//MEM Interface
assign MEM_Address_out = {Tag, Index_out, 7'h0};
assign MEM_Write_Data_out = (CurrentState == STATE_CACHE_WRITEBACK) ? 1'b1 : 1'b0;
assign MEM_Read_out = (CurrentState == STATE_CACHE_ALLOCATE) ? 1'b1 : 1'b0;
assign Fill_out = (CurrentState == STATE_CACHE_ALLOCATE && MEM_Ready_in);
		//Data RAM Interface	
assign Index_out = ((CurrentState == STATE_CACHE_FLUSH) || ((CurrentState == STATE_CACHE_WRITEBACK || CurrentState == STATE_CACHE_WRITEBACK_ACK) &&
						 CPU_Flush_in)) ? Flush_Count_in : CPU_Address_in[10:7];
assign Offset_out = /*(CurrentState == STATE_CACHE_WRITEBACK || CurrentState == STATE_CACHE_WRITEBACK_ACK ||
							CurrentState == STATE_CACHE_ALLOCATE  || CurrentState == STATE_CACHE_ALLOCATE_ACK) ?
							Counter_in : */CPU_Address_in[6:0];
assign Write_Data_out = (CurrentState == STATE_CACHE_IDLE && Hit_in) ? CPU_Write_Data_in : /*(CurrentState == STATE_CACHE_ALLOCATE && MEM_Ready_in) ?
								4'b1111 :*/ 4'b0000;
		//Dirty RAM Interface
assign Dirty_out = (CurrentState == STATE_CACHE_IDLE && (|CPU_Write_Data_in)) ? 1'b1 : 1'b0;
assign Write_Dirty_out = ((CurrentState == STATE_CACHE_IDLE && (|CPU_Write_Data_in) && Hit_in) || (CurrentState == STATE_CACHE_ALLOCATE_ACK &&
								  /*Counter_in == 8'b00001111 &&*/ ~MEM_Ready_in)) ? 1'b1 : 1'b0;
		//Valid RAM Interface
assign Valid_out = (CurrentState == STATE_CACHE_ALLOCATE_ACK && /*Counter_in == 8'b00001111 &&*/ ~MEM_Ready_in) ? 1'b1 : 1'b0;
assign Write_Valid_Tag_out = (CurrentState == STATE_CACHE_ALLOCATE_ACK && /*Counter_in == 8'b00001111 &&*/ ~MEM_Ready_in) ? 1'b1 : 1'b0;
		//Counter Interface
assign Reset_Counter_out = (Reset_in || CurrentState == STATE_CACHE_IDLE) ? 1'b1 : 1'b0;
assign Counter_Enable_out = (CurrentState == STATE_CACHE_INIT) ? 1'b1 : 1'b0;
		//Flush Counter Interface
assign Flush_Reset_Counter_out = (CurrentState == STATE_CACHE_INIT) ? 1'b1 : 1'b0;
assign Flush_Counter_Enable_out = ((CPU_Flush_in && CurrentState == STATE_CACHE_WRITEBACK_ACK && /*Counter_in == 8'b00001111 &&*/ ~MEM_Ready_in) ||
											 (CurrentState == STATE_CACHE_FLUSH && ~Dirty_in)) ? 1'b1 : 1'b0;	
assign Reset_Valid_Dirty_out = (CurrentState == STATE_CACHE_FLUSH_ACK) ? 1'b1: 1'b0;									 
// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----


// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
// Synchronous State - Transition always@ ( posedge Clock ) block
// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
//Allow for asynchronous acknowledgement to the CPU.
always@ ( posedge Clock_in /*or posedge Reset_FSM*/) begin
//		if (Reset_FSM) begin
//				CurrentState = STATE_CACHE_IDLE;
//		end
//		else begin
			CurrentState = NextState;
//		end
	end
// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----


// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
// Conditional State - Transition always@ ( * ) block
// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----
always@ ( CurrentState, CPU_Request, MEM_Ready_in, Hit_in, Dirty_in,
			 Counter_in, Init_Valid_in, Init_Dirty_in, CPU_Flush_in,
			 Flush_Count_in, Reset_in) begin
	NextState = CurrentState ;
	case ( CurrentState )
		STATE_CACHE_INIT : begin
			NextState = (~Init_Valid_in && ~Init_Dirty_in) ? STATE_CACHE_IDLE : STATE_CACHE_INIT;
		end
		STATE_CACHE_IDLE : begin //Request
			NextState = (Reset_in) ? STATE_CACHE_INIT : (CPU_Request) ? (CPU_Flush_in) ? STATE_CACHE_FLUSH : (Hit_in) ? CurrentState /*STATE_CACHE_REQUEST_ACK*/ : (Dirty_in) ?
							STATE_CACHE_WRITEBACK : STATE_CACHE_ALLOCATE : CurrentState;
		end
		STATE_CACHE_REQUEST_ACK : begin
			NextState = (Reset_in) ? STATE_CACHE_INIT : CurrentState;
		end
		STATE_CACHE_ALLOCATE : begin
			NextState = (Reset_in) ? STATE_CACHE_INIT : ( MEM_Ready_in ) ? STATE_CACHE_ALLOCATE_ACK : CurrentState;
		end
		STATE_CACHE_ALLOCATE_ACK : begin
			NextState = (Reset_in) ? STATE_CACHE_INIT : ( ~MEM_Ready_in ) ? /*( Counter_in == 8'b00001111) ?*/ STATE_CACHE_IDLE :
							/*STATE_CACHE_ALLOCATE :*/ CurrentState;
		end
		STATE_CACHE_WRITEBACK : begin
			NextState = (Reset_in) ? STATE_CACHE_INIT : ( MEM_Ready_in ) ? STATE_CACHE_WRITEBACK_ACK : CurrentState;
		end
		STATE_CACHE_WRITEBACK_ACK : begin
			NextState = (Reset_in) ? STATE_CACHE_INIT : ( ~MEM_Ready_in ) ? /*( Counter_in == 8'b00001111 ) ?*/ (CPU_Flush_in) ? 
							STATE_CACHE_FLUSH : STATE_CACHE_ALLOCATE : /*STATE_CACHE_WRITEBACK :*/ CurrentState;
		end
		STATE_CACHE_FLUSH : begin
			NextState = (Reset_in) ? STATE_CACHE_INIT : ( Flush_Count_in == 8'b00010000 ) ? STATE_CACHE_FLUSH_ACK : ( Dirty_in ) ?
							STATE_CACHE_WRITEBACK : CurrentState ;
		end
		STATE_CACHE_FLUSH_ACK : begin
			NextState = (Reset_in) ? STATE_CACHE_INIT : ( ~CPU_Flush_in ) ? STATE_CACHE_INIT : CurrentState;
		end
		default : begin
			NextState = (Reset_in) ? STATE_CACHE_INIT : STATE_CACHE_IDLE;
		end
	endcase
end
// --- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- ----- ---- ---- -----


endmodule