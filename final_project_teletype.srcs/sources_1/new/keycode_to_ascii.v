`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.12.2024 05:06:18
// Design Name: 
// Module Name: keycode_to_ascii
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


module keycode_to_ascii(
        input       thai_flag,
        input       shift_flag,
        input [7:0] keycode,
        output[7:0] ascii
    );
    
    wire [7:0] ascii_th;
    wire [7:0] ascii_en;
    assign ascii = (thai_flag) ? ascii_th : ascii_en;
    
    keycode_to_ascii_th kta_th(
        .rd_data({shift_flag,keycode}),
        .ascii(ascii_th)
    );
    
    keycode_to_ascii_en kta_en(
        .rd_data({shift_flag,keycode}),
        .ascii(ascii_en)
    );
    
endmodule