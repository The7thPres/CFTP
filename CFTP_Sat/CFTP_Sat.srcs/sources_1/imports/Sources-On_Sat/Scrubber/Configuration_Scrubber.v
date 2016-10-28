`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/11/2015 07:49:13 PM
// Design Name: 
// Module Name: Configuration_Scrubber
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Configuration_Scrubber(
    input CLK,
    output reg HEARTBEAT_out
    );
    
    wire CRCERROR;             
    wire ECCERROR;            
    wire ECCERRORSINGLE; 
    wire [25:0] FAR;                       
    wire [4:0] SYNBIT;                
    wire[ 12:0] SYNDROME;             
    wire SYNDROMEVALID;                                      
    wire [6:0] SYNWORD;
    wire [31:0] O;    
    wire CSIB;
    wire [31:0] I;
    wire RDWRB;
    reg [17:0] count;
    
    initial begin
        count = 18'h00000;
    end
    
    always@(posedge HEARTBEAT) begin
        count = (count == 18'h28B0A) ? 0 : count + 1'b1;
        HEARTBEAT_out = (count == 18'h28B0A) ? ~HEARTBEAT_out : HEARTBEAT_out;
    end
    
    sem_0 SEM(
        .status_heartbeat   (HEARTBEAT),
        .monitor_txfull     (1'B0),
        .monitor_rxdata     (8'H00),
        .monitor_rxempty    (1'B1),
        .icap_o             (O),
        .icap_csib          (CSIB),
        .icap_rdwrb         (RDWRB),
        .icap_i             (I),
        .icap_clk           (CLK),
        .icap_grant         (1'B1),
        .fecc_crcerr        (CRCERROR),
        .fecc_eccerr        (ECCERROR),
        .fecc_eccerrsingle  (ECCERRORSINGLE),
        .fecc_syndromevalid (SYNDROMEVALID),
        .fecc_syndrome      (SYNDROME),
        .fecc_far           (FAR),
        .fecc_synbit        (SYNBIT),
        .fecc_synword       (SYNWORD));
    
    // FRAME_ECCE2: Configuration Frame Error Correction
    //              Artix-7
    // Xilinx HDL Language Template, version 2015.2
    
    FRAME_ECCE2 #(
       .FARSRC("EFAR"),                // Determines if the output of FAR[25:0] configuration register points to
                                       // the FAR or EFAR. Sets configuration option register bit CTL0[7].
       .FRAME_RBT_IN_FILENAME("None")  // This file is output by the ICAP_E2 model and it contains Frame Data
                                       // information for the Raw Bitstream (RBT) file. The FRAME_ECCE2 model
                                       // will parse this file, calculate ECC and output any error conditions.
    )
    FRAME_ECCE2_inst (
       .CRCERROR(CRCERROR),             // 1-bit output: Output indicating a CRC error.
       .ECCERROR(ECCERROR),             // 1-bit output: Output indicating an ECC error.
       .ECCERRORSINGLE(ECCERRORSINGLE), // 1-bit output: Output Indicating single-bit Frame ECC error detected.
       .FAR(FAR),                       // 26-bit output: Frame Address Register Value output.
       .SYNBIT(SYNBIT),                 // 5-bit output: Output bit address of error.
       .SYNDROME(SYNDROME),             // 13-bit output: Output location of erroneous bit.
       .SYNDROMEVALID(SYNDROMEVALID),   // 1-bit output: Frame ECC output indicating the SYNDROME output is
                                        // valid.
    
       .SYNWORD(SYNWORD)                // 7-bit output: Word output in the frame where an ECC error has been
                                        // detected.
    
    );
    
       // ICAPE2: Internal Configuration Access Port
       //         Artix-7
       // Xilinx HDL Language Template, version 2015.2
    
       ICAPE2 #(
          .DEVICE_ID(0'h3651093),     // Specifies the pre-programmed Device ID value to be used for simulation
                                      // purposes.
          .ICAP_WIDTH("X32"),         // Specifies the input and output data width.
          .SIM_CFG_FILE_NAME("None")  // Specifies the Raw Bitstream (RBT) file to be parsed by the simulation
                                      // model.
       )
       ICAPE2_inst (
          .O(O),         // 32-bit output: Configuration data output bus
          .CLK(CLK),     // 1-bit input: Clock Input
          .CSIB(CSIB),   // 1-bit input: Active-Low ICAP Enable
          .I(I),         // 32-bit input: Configuration data input bus
          .RDWRB(RDWRB)  // 1-bit input: Read/Write Select input
       );
endmodule
