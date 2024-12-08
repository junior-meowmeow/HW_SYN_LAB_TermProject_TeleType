`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.12.2024 16:10:20
// Design Name: 
// Module Name: keyboard_controller
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


module keyboard_controller(
    input             clk,
    input             reset,
    input             PS2Clk,
    input             PS2Data,
    output            tx_rs232,
    output reg [15:0] keycode_out,
    output reg        data_out_tick = 0,
    output            shift_flag,
    output reg        thai_flag = 0
    );
    
    // for ps2
    reg         clk_50MHz = 0;
    wire        ps2_flag;
    wire [15:0] keycode;
    reg  [15:0] keycode_prev = 0;
    reg         keycode_valid = 0;
    // for tx (RS-232) <- for debug in console
    reg         tx_con_start = 0;
    wire        tx_con_ready;
    wire        tx_start;
    wire        tx_ready;
    wire [31:0] tx_buffer;
    wire [ 7:0] data_to_tx;
    reg  [ 2:0] byte_to_send = 0;
    
    always @(posedge(clk)) begin
        clk_50MHz <= ~clk_50MHz;
    end
    
    ps2_receiver ps2 (
        .clk(clk_50MHz),
        .reset(reset),
        .kb_clk(PS2Clk),
        .kb_data(PS2Data),
        .keycode(keycode),
        .flag_out(ps2_flag)
    );
    
    // detect keyboard release
    reg is_release = 0;
    reg is_shifting = 0;
    reg is_capslock = 0;
    
    assign shift_flag = is_capslock ^ is_shifting;
    
    always@(keycode, reset) begin
        // after release
        if (keycode[7:0] == 8'hf0 || reset) begin
            keycode_valid <= 1'b0;
            byte_to_send <= 3'd0;
        // release
        end else if (keycode[15:8] == 8'hf0) begin
            keycode_valid <= keycode != keycode_prev;
            byte_to_send <= 3'd5;
            is_release <= 1;
        // press (detect if it's after release)
        end else begin
            keycode_valid <= keycode[7:0] != keycode_prev[7:0] || keycode_prev[15:8] == 8'hf0;
            byte_to_send <= 3'd2;
            is_release <= 0;
        end
    end
    
    always@(posedge clk, posedge reset) begin
        if (reset) begin
            tx_con_start <= 0;
            keycode_prev <= 0;
            data_out_tick <= 1'b0;
            thai_flag <= 0;
            keycode_out <= 0;
            is_shifting <= 0;
            is_capslock <= 0;
        end else if (ps2_flag == 1'b1 && keycode_valid == 1'b1) begin
            // send keycode to RS-232
            tx_con_start <= 1'b1;
            // release key -> don't send data
            if (is_release) begin
                // shift
                if(keycode[7:0] == 8'h12) begin
                    is_shifting <= 0;
                end
            end
            // press key
            else begin
                // send data
                data_out_tick <= 1'b1;
                keycode_out <= keycode;
                // caplocks
                if(keycode[7:0] == 8'h58) begin
                    is_capslock <= ~is_capslock;
                    data_out_tick <= 1'b0;
                end
                // shift
                if(keycode[7:0] == 8'h12) begin
                    is_shifting <= 1;
                    data_out_tick <= 1'b0;
                end
                // change language
                if(keycode[7:0] == 8'h0e) begin
                    thai_flag <= ~thai_flag;
                    data_out_tick <= 1'b0;
                end
            end
            keycode_prev <= keycode;
        end else begin
            tx_con_start <= 1'b0;
            data_out_tick <= 1'b0;
        end
    end
    
    ////////////////////////////////////
    // send data to RS-232 for debugging

    bin_to_ascii #(.NBYTES(2)) converter 
    (
        .bin_data(keycode_prev),
        .ascii_data(tx_buffer)
    );
    
    tx_rs232_controller tx_controller (
        .clk            (clk),
        .reset          (reset),
        .byte_to_send   (byte_to_send),
        .tx_buffer_in   (tx_buffer),
        .start          (tx_con_start), 
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
