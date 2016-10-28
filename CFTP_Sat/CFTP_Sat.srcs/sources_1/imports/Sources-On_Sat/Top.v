`timescale 1ns / 1ps
/*
 * File         : Top.v
 * Project      : University of Utah, XUM Project MIPS32 core
 * Creator(s)   : Grant Ayers (ayers@cs.utah.edu)
 *
 * Modification History:
 *   Rev   Date         Initials  Description of Change
 *   1.0   8-Jul-2011   GEA       Initial design.
 *
 * Standards/Formatting:
 *   Verilog 2001, 4 soft tab, wide column.
 *
 * Description:
 *   The top-level file for the FPGA. Also known as the 'motherboard,' this
 *   file connects all processor, memory, clocks, and I/O devices together.
 *   All inputs and outputs correspond to actual FPGA pins.
 */
module Top(
    input  clock_200MHz_p,
    input  clock_200MHz_n,
//    input  reset_n,
    // I/O
/*    input  UART_Rx,
    output UART_Tx,
    inout  i2c_scl,
    inout  i2c_sda,*/
    output Heartbeat_out,
    //Memory
/*    inout [15:0] ddr2_dq,
    inout [1:0] ddr2_dqs_n,
    inout [1:0] ddr2_dqs_p,
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
    output SD2_MOSI,
    input SD2_MISO,
    output SD2_CSn,
    output SD_PWRn,
    output SD2_SClk,
//  output [4:0] Current_State
    // PC104 Interface
    inout [15:0] ARM_Data_inout,
    input [10:0] ARM_Address_in,
    input ARM_Read_in, //active-low
    input ARM_Write_in, //active-low
    input ARM_CS_in, //active-low
    input ARM_BCLK_in, //51MHz
    output ARM_IRQ_out, //active-high(???)
    output ARM_Data_Direction //High_in, Low_out
    );


    // Clock signals
    wire clock, Scrub_Clock, Memory_Clock;
    wire PLL_Locked;
    reg reset;
    
    always @(posedge clock) begin
        reset = /*~reset_n |*/ ~PLL_Locked;
    end

    // MIPS Processor Signals
    reg  [31:0] MIPS32_DataMem_In;
    wire [31:0] MIPS32_DataMem_Out, MIPS32_InstMem_In;
    wire [29:0] MIPS32_DataMem_Address, MIPS32_InstMem_Address;
    wire [3:0]  MIPS32_DataMem_WE;
    wire        MIPS32_DataMem_Read, MIPS32_InstMem_Read;
    reg         MIPS32_DataMem_Ready;
    wire [4:0]  MIPS32_Interrupts;
    wire        MIPS32_NMI;
    wire        MIPS32_IO_WE;

    // Memory Signals
    reg  [3:0] Inst_Write;
    reg  Inst_Read;
    reg  [29:0] Inst_Address;
    reg  [31:0] Inst_Data_in;
    wire Inst_Ready;
    wire Flush;
    wire Flush_Complete;
    wire Data_Read;
    wire [3:0] Data_Write;
    wire [31:0] Data_Data_out;
    wire Data_Ready;

/*  // UART Bootloader Signals
    wire UART_RE;
    wire UART_WE;
    wire [16:0] UART_DOUT;
    wire UART_Ack;
    wire UART_Interrupt;
    wire UART_BootResetCPU;
    wire [29:0] UART_BootAddress;
    wire [31:0] UART_BootData;
    wire UART_BootWriteMem_pre;
    wire [3:0] UART_BootWriteMem = (UART_BootWriteMem_pre) ? 4'hF : 4'h0; */
    
    // PC104 Signals
    wire [31:0] PC104_DOUT;
    wire PC104_RE, PC104_WE, PC104_Ready, PC104_Interrupt;

/*  // I2C Signals
    wire I2C_Ready;
    wire [10:0] I2C_DOUT;
    wire I2C_RE, I2C_WE;*/

    // Clock Generation
    Master_Clock_Divider Clock_Generator (
        .clk_in1_p   (clock_200MHz_p),
        .clk_in1_n   (clock_200MHz_n),
        .reset       (1'b0),
        .clk_out1  (clock),
        .clk_out2  (Scrub_Clock),
        .clk_out3   (Memory_Clock),
        .locked   (PLL_Locked)
    );
    
    // MIPS-32 Core
    ITMR_Processor ITMR_MIPS32 (
        .clock            (clock),
        .reset            (Init_Mem | UART_BootResetCPU),
        .Interrupts       (MIPS32_Interrupts),
        .NMI              (MIPS32_NMI),
        .DataMem_In       (MIPS32_DataMem_In),
        .DataMem_Ready    (MIPS32_DataMem_Ready),
        .DataMem_Read     (MIPS32_DataMem_Read),
        .DataMem_Write    (MIPS32_DataMem_WE),
        .DataMem_Address  (MIPS32_DataMem_Address),
        .DataMem_Out      (MIPS32_DataMem_Out),
        .InstMem_In       (MIPS32_InstMem_In),
        .InstMem_Address  (MIPS32_InstMem_Address),
        .InstMem_Ready    (Inst_Ready),
        .InstMem_Read     (MIPS32_InstMem_Read)
    );

    // On-Chip Block RAM
    System_Memory Memory (
        .clock          (clock),
        .reset          (reset),
        .Inst_Read_in   (Inst_Read),
        .Inst_Write_in  (Inst_Write),
        .Inst_Address_in(Inst_Address),
        .Inst_Data_in   (Inst_Data_in),
        .Inst_Data_out  (MIPS32_InstMem_In),
        .Inst_Ready_out (Inst_Ready),
        .flush          (Flush),
        .flushcomplete  (Flush_Complete),
        .Data_Read_in   (Data_Read),
        .Data_Write_in  (Data_Write),
        .Data_Address_in(MIPS32_DataMem_Address),
        .Data_Data_in   (MIPS32_DataMem_Out),
        .Data_Data_out  (Data_Data_out),
        .Data_Ready_out (Data_Ready),
        .Init_Mem_out   (Init_Mem),
        //DDR Signals
        .Memory_Clock_in(Scrub_Clock),
/*        .DDR_Reset_in   (~PLL_Locked), 
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
        .ddr2_odt       (ddr2_odt) */
        .MISO           (SD2_MISO),
        .MOSI           (SD2_MOSI),
        .CSn            (SD2_CSn),
        .SClk           (SD2_SClk),
        .CurrentState   ()
    );
    
    assign SD_PWRn = 1'b0;

    // UART + Boot Loader (v2)
/*    uart_bootloader UART (
        .clock              (clock),
        .reset              (reset),
        .Read               (UART_RE),
        .Write              (UART_WE),
        .DataIn             (MIPS32_DataMem_Out[8:0]),
        .DataOut            (UART_DOUT),
        .Ack                (UART_Ack),
        .DataReady          (UART_Interrupt),
        .BootResetCPU       (UART_BootResetCPU),
        .BootWriteMem       (UART_BootWriteMem_pre),
        .BootAddr           (UART_BootAddress),
        .BootData           (UART_BootData),
        .RxD                (UART_Rx),
        .TxD                (UART_Tx),
        .Inst_Ready         (Inst_Ready),
        .Flush_out          (Flush),
        .Flush_Complete_in  (Flush_Complete)
    );

    // I2C Module
    I2C_Controller I2C (
        .clock    (clock),  //Need to adjust timeing internally.
        .reset    (reset),
        .Read     (I2C_RE),
        .Write    (I2C_WE),
        .DataIn   (MIPS32_DataMem_Out[12:0]),
        .DataOut  (I2C_DOUT),
        .Ack      (I2C_Ready),
        .i2c_scl  (i2c_scl),
        .i2c_sda  (i2c_sda)
    );*/
    
    NPSAT1_ARM_CFTP_Interface PC104(
        // ARM Interface
        .ARM_Data_inout     (ARM_Data_inout),
        .ARM_Address_in     (ARM_Address_in),
        .ARM_Read_in        (ARM_Read_in), //active-low
        .ARM_Write_in       (ARM_Write_in), //active-low
        .ARM_CS_in          (ARM_CS_in), //active-low
        .ARM_BCLK_in        (ARM_BCLK_in), //51MHz
        .ARM_IRQ_out        (ARM_IRQ_out), //active-high(???)
        .ARM_Data_Direction (ARM_Data_Direction), //High_in, Low_out
        // CFTP Interface
        .CFTP_Address_in    (1'b0),
        .CFTP_Data_in       (MIPS32_DataMem_Out),
        .CFTP_Data_out      (PC104_DOUT),
        .CFTP_Read_in       (PC104_RE), //active-high
        .CFTP_Write_in      (PC104_WE), //active-high
        .CFTP_Ready_out     (PC104_Ready), //active-high
        .CFTP_BCLK_in       (clock), //50MHz
        .CFTP_Reset_in      (reset), //active-high
        .CFTP_IRQ_out       (PC104_Interrupt) //active-high
        );

    assign MIPS32_IO_WE = (MIPS32_DataMem_WE == 4'hF) ? 1 : 0;
    assign MIPS32_Interrupts[4:1] = 0;
    assign MIPS32_Interrupts[0]   = /*UART_Interrupt*/PC104_Interrupt;
    assign MIPS32_NMI             = 0;

    // Allow writes to Instruction Memory Port when bootloading
    always @(*) begin
        Inst_Read   <= /*(UART_BootResetCPU) ? 0 :*/ MIPS32_InstMem_Read;
        Inst_Write   <= /*(UART_BootResetCPU) ? UART_BootWriteMem :*/ 4'h0;
        Inst_Address <= /*(UART_BootResetCPU) ? UART_BootAddress :*/ MIPS32_InstMem_Address;
        Inst_Data_in  <= /*(UART_BootResetCPU) ? UART_BootData :*/ 32'h0000_0000;
    end


    always @(*) begin
        case (MIPS32_DataMem_Address[29])
            0 : begin
                    MIPS32_DataMem_In    <= Data_Data_out;
                    MIPS32_DataMem_Ready <= Data_Ready;
                end
            1 : begin
                    // Memory-mapped I/O
                    case (MIPS32_DataMem_Address[28:26])
                        // I2C
/*                        3'b001 :    begin
                                        MIPS32_DataMem_In    <= {21'h000000, I2C_DOUT[10:0]};
                                        MIPS32_DataMem_Ready <= I2C_Ready;
                                    end */
                        // I2C
                          3'b010 :    begin
                                        MIPS32_DataMem_In    <= PC104_DOUT;
                                        MIPS32_DataMem_Ready <= PC104_Ready;
                                    end            
                        // UART
/*                        3'b011 :    begin
                                        MIPS32_DataMem_In    <= {15'h0000, UART_DOUT[16:0]};
                                        MIPS32_DataMem_Ready <= UART_Ack;
                                    end*/
                        default:    begin
                                        MIPS32_DataMem_In    <= 32'h0000_0000;
                                        MIPS32_DataMem_Ready <= 0;
                                    end
                    endcase
                end
        endcase
    end

    // Memory
    assign Data_Read    = (MIPS32_DataMem_Address[29]) ? 0    : MIPS32_DataMem_Read;
    assign Data_Write    = (MIPS32_DataMem_Address[29]) ? 4'h0 : MIPS32_DataMem_WE;
    // I/O
/*  assign I2C_WE      = (MIPS32_DataMem_Address[29:26] == 4'b1001) ? MIPS32_IO_WE : 0;
    assign I2C_RE      = (MIPS32_DataMem_Address[29:26] == 4'b1001) ? MIPS32_DataMem_Read : 0; */
    assign PC104_WE     = (MIPS32_DataMem_Address[29:26] == 4'b1010) ? MIPS32_IO_WE : 0;
    assign PC104_RE     = (MIPS32_DataMem_Address[29:26] == 4'b1010) ? MIPS32_DataMem_Read : 0;
/*  assign UART_WE     = (MIPS32_DataMem_Address[29:26] == 4'b1011) ? MIPS32_IO_WE : 0;
    assign UART_RE     = (MIPS32_DataMem_Address[29:26] == 4'b1011) ? MIPS32_DataMem_Read : 0;*/
    
Configuration_Scrubber Config_Scrub(
        .CLK            (Scrub_Clock),
        .HEARTBEAT_out  (Heartbeat_out));

endmodule

