`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.12.2024 04:57:45
// Design Name: 
// Module Name: dual_port_ram
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


module dual_port_ram
    #(
        parameter DATA_SIZE = 7,
        parameter ADDR_SIZE = 12
    )
    (
    input clk,
    input reset,
    input write_enable,
    input [ADDR_SIZE-1:0] addr_a, addr_b,
    input [DATA_SIZE-1:0] din_a,
    output [DATA_SIZE-1:0] dout_a, dout_b
    );
    
    // Infer the RAM as block ram
    (* ram_style = "block" *) reg [DATA_SIZE-1:0] ram [2**ADDR_SIZE-1:0];
    
    reg [ADDR_SIZE-1:0] addr_a_reg, addr_b_reg;
    
    reg [ADDR_SIZE-1:0] temp_addr; // for flushing ram
    always @(posedge clk) begin
        if (reset) begin
            // Clear each ram for each clock
            ram[temp_addr] <= 0;
            temp_addr <= temp_addr + 1;
            addr_a_reg <= 0;
            addr_b_reg <= 0;
        end else begin
            if (write_enable) begin      
                // write operation
                ram[addr_a] <= din_a;
            end
            addr_a_reg <= addr_a;
            addr_b_reg <= addr_b;
        end
    end
    
    // two read operations        
    assign dout_a = ram[addr_a_reg];
    assign dout_b = ram[addr_b_reg];
    
endmodule
