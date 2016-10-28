`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:56:21 04/12/2015 
// Design Name: 
// Module Name:    Voter 
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
module Voter #(parameter WIDTH = 1)(
    input  [(WIDTH-1):0] A, B, C,
    output [(WIDTH-1):0] True/*, A_error, B_error, C_error, Bit_error*/
    );

//wire [(WIDTH-1):0] AB_error, AC_error, BC_error;
genvar i;

generate	
	for (i = 0; i < WIDTH; i = i +1) begin : Vote_Bit
//			assign AB_error[i] = A[i] ^ B[i];
//			assign AC_error[i] = A[i] ^ C[i];
//			assign BC_error[i] = B[i] ^ C[i];
//			assign A_error[i] = AB_error[i] && AC_error[i];
//			assign B_error[i] = AB_error[i] && BC_error[i];
//			assign C_error[i] = AC_error[i] && BC_error[i];
			assign True[i] =  (A[i] && B[i]) || (A[i] && C[i]) || (B[i] && C[i]);
//			assign Bit_error[i] = AB_error[i] || AC_error[i] || BC_error[i]; 
	end
endgenerate

endmodule
