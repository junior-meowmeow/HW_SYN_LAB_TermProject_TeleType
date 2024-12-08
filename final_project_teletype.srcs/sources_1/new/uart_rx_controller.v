`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.12.2024 17:59:45
// Design Name: 
// Module Name: uart_rx_controller
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


module uart_rx_controller(
    input             clk,
    input             reset,
    input             rx,
    output            tx_rs232,
    output reg [7:0]  flag_out,
    output reg [7:0]  keycode_out,
    output reg        data_out_tick = 0
    );
    
    wire clk_baudrate;
    clk_to_baudrate baudrate_clk_divider(
        .clk(clk),
        .clk_baudrate(clk_baudrate)
    );
    
    wire [7:0] data_from_rx;
    wire finish_rx;
    reg finish_rx_prev = 0;
    
    uart_rx receiver(
        .clk_baudrate(clk_baudrate),
        .reset(reset),
        .signal_in(rx),
        .data_out(data_from_rx),
        .finish_receive(finish_rx)
    );
    
    reg [7:0] data_prev = 0;
    reg state = 0; // 0 = receiving flag, 1 = receiving keycode
    
    // for tx (RS-232) <- for debug in console
    reg debug_tx_start = 0;
    
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            finish_rx_prev <= 0;
            data_prev <= 0;
            state <= 0;
            flag_out <= 0;
            keycode_out <= 0;
        end
        else begin
            // if finished rx signal change from 0 -> 1
            if (finish_rx && ~finish_rx_prev) begin
                data_prev <= data_from_rx;
                // confirm if state is correct
                if(state == 1 && data_from_rx != 0) begin
                    if(data_prev[7:2] != 6'b000000) begin
                        state <= 1;
                        data_out_tick <= 0;
                    end else begin
                        flag_out <= data_prev;
                        keycode_out <= data_from_rx;
                        data_out_tick <= 1;
                        state <= ~state;
                    end
                end else begin
                    state <= ~state;
                    data_out_tick <= 0;
                end
            end else begin
                data_out_tick <= 0;
            end
            // keep track of finish_rx signal
            finish_rx_prev <= finish_rx;
        end
    end
    
    ////////////////////////////////////
    // send data to RS-232 for debugging
    reg         tx_con_start = 0;
    wire        tx_con_ready;
    wire        tx_start;
    wire        tx_ready;
    wire [31:0] tx_buffer;
    wire [ 7:0] data_to_tx;
    reg  [ 2:0] byte_to_send = 3'd5;
    
    bin_to_ascii #(.NBYTES(2)) converter(
        .bin_data({flag_out, keycode_out}),
        .ascii_data(tx_buffer)
    );
    
    tx_rs232_controller tx_controller (
        .clk            (clk),
        .reset          (reset),
        .byte_to_send   (byte_to_send),
        .tx_buffer_in   (tx_buffer),
        .start          (data_out_tick), 
        .ready          (tx_con_ready), 
        .tx_start       (tx_start),
        .tx_ready       (tx_ready),
        .data_to_tx     (data_to_tx)
    );
    
    uart_tx tx_sender (
        .clk            (clk),
        .reset          (reset),
        .start          (tx_start),
        .data_to_send   (data_to_tx),
        .tx             (tx_rs232),
        .ready          (tx_ready)
    );
    
endmodule
