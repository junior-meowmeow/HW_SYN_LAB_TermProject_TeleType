`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.12.2024 05:06:18
// Design Name: 
// Module Name: font_rom
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


module font_rom(
        input        clk,
        input        thai_flag,
        input [10:0] addr, //[10:4] for ASCII char code, [3:0] for choosing what row to read on a given character code  
        output[7:0]  data
    );
    
    wire [7:0] data_th;
    wire [7:0] data_en;
    assign data = (thai_flag) ? data_th : data_en;
    
    font_rom_th fr_th(
        .clk(clk),
        .addr(addr),
        .data(data_th)
    );
    
    font_rom_en fr_en(
        .clk(clk),
        .addr(addr),
        .data(data_en)
    );
    
endmodule
