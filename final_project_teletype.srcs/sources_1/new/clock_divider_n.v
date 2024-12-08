`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.12.2024 23:38:36
// Design Name: 
// Module Name: clk_divider_n
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


module clock_divider_n #(parameter N=19)(
    input clk_in,
    output clk_out
    );
    
    wire [N-1:0] tclk;
    
    assign tclk[0]= clk_in;
    
    genvar c;
    generate for(c=0;c<N-1;c=c+1) begin
        clk_divider fDiv(.clk(tclk[c]),.clk_div(tclk[c+1]));
    end endgenerate
    
    clk_divider fdivTarget(.clk(tclk[N-1]),.clk_div(clk_out));
    
endmodule
