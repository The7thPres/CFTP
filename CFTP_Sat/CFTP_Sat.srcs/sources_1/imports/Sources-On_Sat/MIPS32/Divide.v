`timescale 1ns / 1ns
/*
 * File         : Divide.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Neil Russell
 *
 * Modification History:
 *  Rev   Date         Initials  Description of Change
 *  1.0   6-Nov-2012   NJR       Initial design.
 *
 * Description:
 *  A multi-cycle 32-bit divider.
 *
 *  On any cycle that one of OP_div or OP_divu are true, the Dividend and
 *  Divisor will be captured and a multi-cycle divide operation initiated.
 *  Stall will go true on the next cycle and the first cycle of the divide
 *  operation completed.  After some time (about 32 cycles), Stall will go
 *  false on the same cycle that the result becomes valid.  OP_div or OP_divu
 *  will abort any currently running divide operation and initiate a new one.
 */
module Divide(
   input  clock,
   input  reset,
   input  OP_div,     		// True to initiate a signed divide
   input  OP_divu,    		// True to initiate an unsigned divide
   input  [31:0] Dividend,
   input  [31:0] Divisor,
   output [31:0] Quotient,
   output [31:0] Remainder,
   output Stall,       		// True while calculating
   //Voter Signals for Registers
	input  active,     		// True if the divider is running
   input  neg,        		// True if the result will be negative
   input  [31:0] result,  // Begin with dividend, end with quotient
   input  [31:0] denom,   // Divisor
   input  [31:0] work,
	output reg  vote_active,     		// True if the divider is running
   output reg  vote_neg,        		// True if the result will be negative
   output reg  [31:0] vote_result,  // Begin with dividend, end with quotient
   output reg  [31:0] vote_denom,   // Divisor
   output reg  [31:0] vote_work
	);

   reg [4:0] cycle;      // Number of cycles to go
	 
   // Calculate the current digit
   wire [32:0]     sub = { work[30:0], result[31] } - denom;

   // Send the results to our master
   assign Quotient = !neg ? result : -result;
   assign Remainder = work;
   assign Stall = active;

   // The state machine
   always @(posedge clock) begin
      if (reset) begin
         vote_active <= 0;
         vote_neg <= 0;
         cycle <= 0;
         vote_result <= 0;
         vote_denom <= 0;
         vote_work <= 0;
      end
      else begin
         if (OP_div) begin
            // Set up for a signed divide.  Remember the resulting sign,
            // and make the operands positive.
            cycle <= 5'd31;
            vote_result <= (Dividend[31] == 0) ? Dividend : -Dividend;
            vote_denom <= (Divisor[31] == 0) ? Divisor : -Divisor;
            vote_work <= 32'b0;
            vote_neg <= Dividend[31] ^ Divisor[31];
            vote_active <= 1;
         end
         else if (OP_divu) begin
            // Set up for an unsigned divide.
            cycle <= 5'd31;
            vote_result <= Dividend;
            vote_denom <= Divisor;
            vote_work <= 32'b0;
            vote_neg <= 0;
            vote_active <= 1;
         end
         else if (active) begin
            // Run an iteration of the divide.
            if (sub[32] == 0) begin
               vote_work <= sub[31:0];
               vote_result <= {result[30:0], 1'b1};
            end
            else begin
               vote_work <= {work[30:0], result[31]};
               vote_result <= {result[30:0], 1'b0};
            end
            if (cycle == 0) begin
               vote_active <= 0;
            end
            cycle <= cycle - 5'd1;
         end
      end
   end
endmodule
