`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.12.2024 14:46:01
// Design Name: 
// Module Name: bin_to_ascii
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


module bin_to_ascii #(parameter NBYTES=2)(
    input [NBYTES*8-1:0] bin_data,
    output reg [NBYTES*16-1:0] ascii_data=0
    );
    genvar i;
    generate for (i=0; i<NBYTES*2; i=i+1)
        always@(bin_data)
        if (bin_data[4*i+3:4*i] >= 4'h0 && bin_data[4*i+3:4*i] <= 4'h9)
            ascii_data[8*i+7:8*i] = 8'd48 + bin_data[4*i+3:4*i];
        else
            ascii_data[8*i+7:8*i] = 8'd55 + bin_data[4*i+3:4*i];
    endgenerate
endmodule
