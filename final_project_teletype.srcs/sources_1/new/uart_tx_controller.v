`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.12.2024 14:46:01
// Design Name: 
// Module Name: uart_tx_controller
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

// Control uart_tx and handle multiple data at once
module uart_tx_controller(
    input             clk,
    input             reset,
    input      [15:0] tx_buffer_in, // transmit buffer = data to send
    input             start, // when buffer is ready
    output            ready, // when controller(this) is ready
    output reg        tx_start = 0, // transmit start (to uart_tx)
    input             tx_ready, // ready to transmit next char (receive from uart_tx)
    output reg [ 7:0] data_to_tx = 0 // send to uart_tx
    );

    reg [2:0] pointer = 0; // point to current character to tx
    reg [7:0] keycode_data = 0; // save buffer input
    reg [7:0] flag_data = 0; // save buffer input
    reg running = 0; // is sending last request
    initial tx_start <= 'b0;
    initial data_to_tx <= 'b0;
    
    always@(posedge clk, posedge reset) begin
        if(reset) begin
            pointer <= 0;
            keycode_data <= 0;
            flag_data <= 0;
            running <= 0;
            tx_start <= 0;
        end
        else begin
            // if uart_tx is ready
            if (tx_ready == 1'b1) begin
                // if there are data left to send
                if (running == 1'b1) begin
                    // last byte sent
                    if (pointer == 4'd1) begin
                        // end and reset pointer
                        running <= 1'b0;
                        pointer <= 2'd2;
                    // not last char
                    end else begin
                        // move pointer to next char
                        pointer <= pointer - 1'b1;
                        // send data to uart_tx
                        tx_start <= 1'b1;
                        running <= 1'b1;
                    end
                // no request right now
                end else begin
                    // receive tx request
                    if (start) begin
                        // save data to register
                        keycode_data <= tx_buffer_in[7:0];
                        flag_data <= tx_buffer_in[15:8];
                        // send first char to tx
                        tx_start <= start;
                        running <= start;
                        // set start pointer
                        pointer <= 2'd2;
                    end
                end
            end else
                tx_start <= 1'b0;
        end
    end

    assign ready = ~running;

    always@(pointer, keycode_data, flag_data) begin
        case (pointer)
        1: data_to_tx <= keycode_data;
        2: data_to_tx <= flag_data;
        default: data_to_tx <= 8'd0;
        endcase
    end

endmodule
