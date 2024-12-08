`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.12.2024 16:18:51
// Design Name: 
// Module Name: tx_rs232_controller
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


module tx_rs232_controller(
    input             clk,
    input             reset,
    input      [ 2:0] byte_to_send, // byte count
    input      [31:0] tx_buffer_in, // transmit buffer = data to send
    input             start, // when buffer is ready
    output            ready, // when controller(this) is ready
    output reg        tx_start = 0, // transmit start (to uart_tx)
    input             tx_ready, // ready to transmit next char (receive from uart_tx)
    output reg [ 7:0] data_to_tx = 0 // send to uart_tx
    );

    reg [2:0] pointer = 0; // point to current character to tx
    reg [31:0] data_buffer = 0; // save buffer input
    reg running = 0; // is sending last request
    initial tx_start <= 'b0;
    initial data_to_tx <= 'b0;
    
    always@(posedge clk, posedge reset) begin
        if(reset) begin
            pointer <= 0;
            data_buffer <= 0;
            running <= 0;
            tx_start <= 0;
        end
        else begin
            // if uart_tx is ready
            if (tx_ready == 1'b1) begin
                // if there are char to send
                if (running == 1'b1) begin
                    // last char sent (\r)
                    if (pointer == 4'd1) begin
                        // end and reset pointer
                        running <= 1'b0;
                        pointer <= byte_to_send + 2'd2;
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
                    if (byte_to_send != 2'b0) begin
                        // save data to register
                        data_buffer <= tx_buffer_in;
                        // send first char to tx
                        tx_start <= start;
                        running <= start;
                        // set start pointer
                        pointer <= byte_to_send + 2'd2;
                    end
                end
            end else
                tx_start <= 1'b0;
        end
    end

    assign ready = ~running;

    always@(pointer, data_buffer) begin
        case (pointer)
        // carriage return = \r
        1: data_to_tx <= 8'd13;
        // line feed = \n
        2: data_to_tx <= 8'd10;
        3: data_to_tx <= data_buffer[7:0];
        4: data_to_tx <= data_buffer[15:8];
        // space = ' '
        5: data_to_tx <= 8'd32;
        6: data_to_tx <= data_buffer[23:16];
        7: data_to_tx <= data_buffer[31:24];
        default: data_to_tx <= 8'd0;
        endcase
    end

endmodule
