`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: Naval Postgraduate School 
// Engineer: Andrew S Jackson
// 
// Create Date: 11/11/2015 05:53:27 PM
// Design Name: 
// Module Name: NPSAT1_ARM_CFTP_Interface
// Project Name: NPSat1 Configurable Fault Tolerant Processor
// Target Devices: xc7k325tffg676-2
// Tool Versions: Vivado 15.3
// Description: Interface between the ARM and CFTP.  The ARM uses bus timing for
// the LH***** with 16 wait cycles.  The CFTP uses a 4-way handshake.  Incoming
// and outgoing IP FIFOs are used with independent clocks, clocked by the respective
// source/destination for writes/reads respectively.  This mitigates skewing effects
// and possible metastability to ensure synchronous operation on either side of the FIFOs. 
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module NPSAT1_ARM_CFTP_Interface(
    // ARM Interface
    inout wire [15:0] ARM_Data_inout,
    input wire [10:0] ARM_Address_in,
    input wire ARM_Read_in, //active-low
    input wire ARM_Write_in, //active-low
    input wire ARM_CS_in, //active-low
    input wire ARM_BCLK_in, //51MHz
    output wire ARM_IRQ_out, //active-high(???)
    output wire ARM_Data_Direction, //High_in, Low_out
    
    // CFTP Interface
    input wire CFTP_Address_in,
    input wire [31:0] CFTP_Data_in,
    output wire [31:0] CFTP_Data_out,
    input wire CFTP_Read_in, //active-high
    input wire CFTP_Write_in, //active-high
    output wire CFTP_Ready_out, //active-high
    input wire CFTP_BCLK_in, //200MHz
    input wire CFTP_Reset_in, //active-high
    output wire CFTP_IRQ_out //active-high
    );
    
    wire Incoming_Full, Incoming_Empty, Outgoing_Full, Outgoing_Empty;
    
    //ARM Interface Signals and Parameters
    parameter ARM_STATE_IDLE        = 3'b000;
    parameter ARM_STATE_READ        = 3'b001;
    parameter ARM_STATE_READ_WAIT   = 3'b010;
    parameter ARM_STATE_HIZ         = 3'b011;
    parameter ARM_STATE_WRITE       = 3'b100;
    parameter ARM_STATE_WRITE_WAIT  = 3'b101; 
    reg [2:0] ARM_CurrentState, ARM_NextState;     
    wire Decode;
    wire [15:0] ARM_Data_FIFO, ARM_Data_in, ARM_Status;
    wire [10:0] Outgoing_FIFO_Count;

    
    //CFTP Interface Signals and Parameters    
    parameter CFTP_STATE_IDLE   = 2'b00;
    parameter CFTP_STATE_WRITE  = 2'b01;
    parameter CFTP_STATE_READ   = 2'b10;
    parameter CFTP_STATE_ACK    = 2'b11;
    reg [1:0] CFTP_CurrentState, CFTP_NextState;
    reg [7:0] Top8; 
    reg [15:0] ARM_Data_out;
    wire [9:0] Incoming_FIFO_Count;
    wire [31:0] CFTP_Data; 
             
    ARM_FIFO_in INCOMING ( //Uses first word fall through FIFO
        .rst(CFTP_Reset_in),
        .wr_clk(ARM_BCLK_in),
        .rd_clk(CFTP_BCLK_in),
        .din({Top8,ARM_Data_inout[7:0]}),
        .wr_en((ARM_CurrentState == ARM_STATE_WRITE) && (ARM_Address_in == 11'h340)),
        .rd_en((CFTP_CurrentState == CFTP_STATE_READ) && (CFTP_Address_in == 1'b0)),
        .dout(CFTP_Data),
        .full(Incoming_Full),
        .empty(Incoming_Empty),
        .rd_data_count(Incoming_FIFO_Count)
    );
    
    ARM_FIFO_out OUTGOING ( //Uses regular FIFO
        .rst(CFTP_Reset_in),
        .wr_clk(CFTP_BCLK_in),
        .rd_clk(ARM_BCLK_in),
        .din(CFTP_Data_in),
        .wr_en((CFTP_CurrentState == CFTP_STATE_WRITE)  && (CFTP_Address_in == 1'b0)),
        .rd_en((ARM_CurrentState == ARM_STATE_READ) && (ARM_Address_in == 11'h341)),
        .dout(ARM_Data_FIFO),
        .full(Outgoing_Full),
        .empty(Outgoing_Empty),
        .rd_data_count(Outgoing_FIFO_Count)
    );
    
    //ARM Interface Assignments
    assign ARM_Status = {3'b0, Outgoing_FIFO_Count, Incoming_Full, ~Outgoing_Empty};
    assign ARM_Data_inout = (Decode && ~ARM_Read_in) ? ARM_Data_out : 16'dz;
    assign Decode = (((ARM_Address_in >= 11'h340) && (ARM_Address_in <= 11'h34F)) && ~ARM_CS_in);
    assign ARM_Data_Direction = ~(Decode&&~ARM_Read_in); //High is into FPGA, Low is out of FPGA...
//  assign ARM_IRQ_out = ~Outgoing_Empty; 
    
    //ARM Interface Synchronous Transitions
    always@(posedge ARM_BCLK_in) ARM_Data_out = (ARM_CurrentState == ARM_STATE_READ) ? (ARM_Address_in == 11'h340) ? {ARM_Data_FIFO[7:0],ARM_Data_FIFO[15:8]} :
                                                (ARM_Address_in == 11'h341) ? {ARM_Data_FIFO[7:0],ARM_Data_FIFO[15:8]} :
                                                (ARM_Address_in == 11'h342) ? ARM_Status : ARM_Data_out : ARM_Data_out;
    always@(negedge ARM_BCLK_in) ARM_CurrentState = ARM_NextState;
    always@(posedge ARM_BCLK_in) Top8 = ((ARM_CurrentState == ARM_STATE_WRITE) && (ARM_Address_in == 11'h341)) ? ARM_Data_inout[15:8] : Top8; //Temporarily Store the High Byte Since the ARM is doing 8-bit transactions
    
    //ARM Interface State Transitions
    always@(*) begin
        case (ARM_CurrentState) 
            ARM_STATE_IDLE:         ARM_NextState = (Decode) ? (~ARM_Write_in) ? ARM_STATE_WRITE : (~ARM_Read_in) ? ARM_STATE_HIZ : ARM_STATE_IDLE : ARM_STATE_IDLE;
            ARM_STATE_WRITE:        ARM_NextState = ARM_STATE_WRITE_WAIT; 
            ARM_STATE_WRITE_WAIT:   ARM_NextState = (ARM_Write_in) ? ARM_STATE_IDLE : ARM_STATE_WRITE_WAIT; 
            ARM_STATE_HIZ:          ARM_NextState = ARM_STATE_READ; //Allow one clock cycle to transition the bus transcievers to prevent driving bus from both the FPGA and Bus Transcievers.
            ARM_STATE_READ:         ARM_NextState = ARM_STATE_READ_WAIT; 
            ARM_STATE_READ_WAIT:    ARM_NextState = (ARM_Read_in) ? ARM_STATE_IDLE : ARM_STATE_READ_WAIT;
            default :               ARM_NextState = ARM_STATE_IDLE; 
        endcase
    end    
 
    
    //CFTP Interface Assignments
    assign CFTP_IRQ_out = ~Incoming_Empty;
    assign CFTP_Ready_out = (CFTP_CurrentState == CFTP_STATE_ACK);
    assign CFTP_Data_out = (CFTP_Address_in) ? {22'd0 ,Incoming_FIFO_Count} : CFTP_Data; 
        
    //CFTP Interface Synchronous Transitions
    always@(negedge CFTP_BCLK_in) CFTP_CurrentState = CFTP_NextState; 
        
    //CFTP Interface State Transitions
    always@(*) begin
        case (CFTP_CurrentState) 
            CFTP_STATE_IDLE:    CFTP_NextState = (CFTP_Write_in) ? CFTP_STATE_WRITE : (CFTP_Read_in) ? CFTP_STATE_READ : CFTP_STATE_IDLE; 
            CFTP_STATE_WRITE:   CFTP_NextState = CFTP_STATE_ACK; 
            CFTP_STATE_READ:    CFTP_NextState = CFTP_STATE_ACK; 
            CFTP_STATE_ACK:     CFTP_NextState = ~(CFTP_Write_in || CFTP_Read_in) ? CFTP_STATE_IDLE : CFTP_STATE_ACK; 
            default :           CFTP_NextState = CFTP_STATE_IDLE; 
        endcase
    end
    
endmodule
`default_nettype wire