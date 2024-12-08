`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.12.2024 01:20:30
// Design Name: 
// Module Name: clk_to_baudrate
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


module clk_to_baudrate(
    input clk,
    output reg clk_baudrate
    );
    
    integer counter;
    always @(posedge clk) begin
        counter = counter + 1;
        if (counter == 325) begin 
        // Divide clock by 325
            counter = 0;
            clk_baudrate = ~clk_baudrate; 
        end 
        // Basys3 Clock = 10ns
        // Clock Frequency = 100 MHz
        // Target baudrate = 9600 Hz
        // counter = ClockFreq/Baudrate/16/2 = 325.5
        // 16: sampling every 16 ticks
        // 2: ?
    end
    
endmodule
