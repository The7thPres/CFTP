`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2015 09:54:27 AM
// Design Name: 
// Module Name: Bus_Arbiter
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


module Bus_Arbiter(
    input Clock_in,
    input Reset_in,
    input Inst_Read_in,
    input Inst_Write_in,
    input [29:0] Inst_Address_in,
    input [4095:0] Inst_Data_in,
    output reg Inst_Ready_out,
    output reg [4095:0] Inst_Data_out,
    input Data_Read_in,
    input Data_Write_in,
    input [29:0] Data_Address_in,
    input [4095:0] Data_Data_in,
    output reg Data_Ready_out,
    output reg[4095:0] Data_Data_out,
    output reg SD_Read_in,
    output reg SD_Write_in,
    output reg [29:0] SD_Address_in,
    output reg [4095:0] SD_Data_in,
    input SD_Ready_out,
    input [4095:0] SD_Data_out
    );

    reg [1:0] Bus_Locked;
    reg Bus_Select;
    
    
    
    always@(posedge Clock_in)
        begin
            if (Reset_in)
                Bus_Locked = 2'b00;
            else begin
                if (Bus_Locked == 2'b00) begin
                    if ((Inst_Read_in | Inst_Write_in) && !SD_Ready_out)
                       Bus_Locked = 2'b10;
                    if ((Data_Read_in | Data_Write_in) && !SD_Ready_out)
                       Bus_Locked = 2'b01; 
                end
                if (Bus_Locked == 2'b01) begin
                    if (~(Data_Read_in | Data_Write_in) && !SD_Ready_out && (Inst_Read_in | Inst_Write_in))
                       Bus_Locked = 2'b10;
                    if (~(Data_Read_in | Data_Write_in) && !SD_Ready_out && ~(Inst_Read_in | Inst_Write_in))
                       Bus_Locked = 2'b00;
                end
                if (Bus_Locked == 2'b10) begin
                    if ((Data_Read_in | Data_Write_in) && !SD_Ready_out && ~(Inst_Read_in | Inst_Write_in))
                       Bus_Locked = 2'b01;
                    if (~(Data_Read_in | Data_Write_in) && !SD_Ready_out && ~(Inst_Read_in | Inst_Write_in))
                       Bus_Locked = 2'b00;
                end
            end
            Bus_Select = (!Reset_in) ? (Bus_Locked == 2'b10) ? 1'b0 : (Bus_Locked == 2'b01) ? 1'b1 : Bus_Select : 1'b0;
            Inst_Ready_out = (!Reset_in) ? (!Bus_Select) ? SD_Ready_out : 1'b0 : 1'b0;
            Inst_Data_out = (!Reset_in) ? SD_Data_out : 4096'd0;
            Data_Ready_out = (!Reset_in) ? (Bus_Select) ? SD_Ready_out : 1'b0 : 1'b0;
            Data_Data_out = (!Reset_in) ? SD_Data_out :4096'd0;
            SD_Read_in = (!Reset_in) ? (Bus_Select) ? Data_Read_in : Inst_Read_in : 1'b0;
            SD_Write_in = (!Reset_in) ? (Bus_Select) ? Data_Write_in : Inst_Write_in : 1'b0;
            SD_Address_in = (!Reset_in) ? (Bus_Select) ? Data_Address_in : Inst_Address_in : 30'd0;
            SD_Data_in = (!Reset_in) ? (Bus_Select) ? Data_Data_in : Inst_Data_in : 4096'd0;
        end
        

                     
endmodule
