`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.12.2024 14:46:01
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
    input       clk,
    input       reset,
    input [7:0] data_to_send,
    input       start,
    output      tx, // tx port from Basys 3
    output      ready // is ready to send next byte
    );
    parameter CD_MAX=10416, CD_WIDTH=16;
    // Carrier Detect (CD) is a control signal present inside an RS-232
    reg [CD_WIDTH-1:0] cd_count = 0;
    reg [3:0] count = 0;
    reg running = 0;
    reg [10:0] shift = 11'h7ff;
    
    always@(posedge clk, posedge reset) begin
        if(reset) begin
            shift <= 11'h7ff;
            running <= 0;
        end
        // is standby
        else if (running == 1'b0) begin
            // setup data
            shift <= {2'b11, data_to_send, 1'b0};
            // waiting for start signal
            running <= start;
            // cd for rs-232
            cd_count <= 'b0;
            count <= 'b0;
        // is running (sending data)
        end else if (cd_count == CD_MAX) begin
            // shift data to send
            shift <= {1'b1, shift[10:1]};
            cd_count <= 'b0;
            // send 10 bit = finish
            if (count == 4'd10) begin
                running <= 1'b0;
                count <= 'b0;
            end
            else
                count <= count + 1'b1;
        end else
            cd_count <= cd_count + 1'b1;
    end

    assign tx = (running == 1'b1) ? shift[0] : 1'b1;
    assign ready = ((running == 1'b0 && start == 1'b0) || (cd_count == CD_MAX && count == 4'd10)) ? 1'b1 : 1'b0;

endmodule
