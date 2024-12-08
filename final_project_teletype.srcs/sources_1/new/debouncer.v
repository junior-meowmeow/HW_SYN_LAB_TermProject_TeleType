`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.12.2024 14:46:01
// Design Name: 
// Module Name: debouncer
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


module debouncer(
    input clk,
    input bit_in,
    output reg bit_out
    );
    parameter COUNT_MAX=255, COUNT_WIDTH=8; // Time to count
    reg [COUNT_WIDTH-1:0] count;
    reg last_bit_in = 0;
    always@(posedge clk)
        // bit not change
        if (bit_in == last_bit_in) begin
            // wait until time > count
            if (count == COUNT_MAX)
                // bit stable -> output change
                bit_out <= bit_in;
            else
                count <= count + 1'b1;
        // bit change
        end else begin
            // reset time to 0
            count <= 'b0;
            last_bit_in <= bit_in;
        end
    
endmodule
