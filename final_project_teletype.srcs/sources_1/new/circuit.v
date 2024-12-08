`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.12.2024 14:32:57
// Design Name: 
// Module Name: circuit
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


module circuit(
    input       clk,
    input       reset,
    input [7:0] sw,         // Ascii data
    input       sw_thai,    // Thai signal
    input       btnC,       // Button to send data
    input       rx_pmod,    // Serial input port
    input       PS2Data,    // Keyboard data port
    input       PS2Clk,     // Keyboard clock port
    output      tx_rs232,   // UART for debug
    output      tx_pmod,    // Serial output port
    output      debug_led_1,// Keyboard shift led
    output      debug_led_2,// Keyboard thai led
    output[8:0] led,        // Switch data
    // VGA Port
    output[3:0] vga_r,
    output[3:0] vga_g,
    output[3:0] vga_b,
    output      hsync,
    output      vsync,
    // 7-Segment for debug switch value in BCD
    output [6:0] seg,
    output dp,
    output [3:0] an
    );
    
    // Debounce Reset Signal
    wire reset_stable;
    debouncer #(.COUNT_MAX(19), .COUNT_WIDTH(5)) debouncer_reset
    (
        .clk(clk),
        .bit_in(reset),
        .bit_out(reset_stable)
    );
    
    ////////////////////////////////////
    // Tx Controller Register and Wire
    
    reg  [15:0] tx_buffer = 0;
    reg         tx_con_start = 0;
    wire        tx_con_ready;
    
    wire        tx_start;
    wire        tx_ready;
    wire [ 7:0] data_to_tx;
    
    ////////////////////////////////////
    // Keyboard Signal
    
    wire [15:0] kb_data;
    wire kb_send_signal;
    wire kb_shift;
    wire kb_thai;
    
    assign debug_led_1 = kb_shift;
    assign debug_led_2 = kb_thai;
    
    keyboard_controller kb_controller(
        .clk(clk),
        .reset(reset_stable),
        .PS2Clk(PS2Clk),
        .PS2Data(PS2Data),
//        .tx_rs232(tx_rs232),
        .tx_rs232(),
        .keycode_out(kb_data),
        .data_out_tick(kb_send_signal),
        .shift_flag(kb_shift),
        .thai_flag(kb_thai)
    );
    
    ////////////////////////////////////
    // Switch Signal
    
    // Debounce Send Button (btnC)
    wire send_btn;
    debouncer #(.COUNT_MAX(2**7-1), .COUNT_WIDTH(7)) debouncer_btnC(
        .clk(clk),
        .bit_in(btnC),
        .bit_out(send_btn)
    );
    
    reg send_btn_prev = 0;
    
    ////////////////////////////////////
    // Tx Controller
    
    wire [7:0] sw_keycode;
    wire sw_shift;
    
    ascii_to_keycode sw_atc_converter(
        .ascii(sw[7:0]),
        .keycode(sw_keycode),
        .shift(sw_shift)
    );
    
    always@(posedge clk) begin
        if (reset) begin
            tx_con_start <= 0;
            tx_buffer <= 0;
        end else if (kb_send_signal) begin
            tx_con_start <= 1;
            tx_buffer <= {6'b000000,kb_shift,kb_thai,kb_data[7:0]};
//            tx_buffer <= kb_ascii;
        // simple single pulser
        end else if (send_btn && (send_btn_prev == 0)) begin
            tx_con_start <= 1;
            tx_buffer <= {6'b000000,sw_shift,sw_thai,sw_keycode};
            // for debugging
//            tx_buffer <= sw_ascii;
        end else begin
            tx_con_start <= 0;
            tx_buffer <= 0;
        end
        send_btn_prev <= send_btn;
    end
    
    uart_tx_controller tx_controller (
        .clk            (clk),
        .reset          (reset_stable),
        .tx_buffer_in   (tx_buffer),
        .start          (tx_con_start), 
        .ready          (tx_con_ready), 
        .tx_start       (tx_start),
        .tx_ready       (tx_ready),
        .data_to_tx     (data_to_tx)
    );
    
    uart_tx tx_sender (
        .clk            (clk),
        .reset          (reset_stable),
        .start          (tx_start),
        .data_to_send   (data_to_tx),
        .tx             (tx_pmod),
//        .tx             (tx_rs232),
        .ready          (tx_ready)
    );
    
    ////////////////////////////////////
    // switch light for better visual
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin
            assign led[i] = sw[i];
        end
    endgenerate
    
    assign led[8] = sw_thai;
    
    ////////////////////////////////////
    // Rx Controller
    
    wire [7:0] rx_flag;
    wire [7:0] rx_keycode;
    wire       rx_out_tick;
    
    uart_rx_controller rx_controller(
        .clk(clk),
        .reset(reset_stable),
        .rx(rx_pmod),
        .tx_rs232(tx_rs232),
        .flag_out(rx_flag),
        .keycode_out(rx_keycode),
        .data_out_tick(rx_out_tick)
    );
    
    ////////////////////////////////////
    // VGA Controller
    
    wire [9:0] current_x, current_y;
    wire video_tick;
    wire rgb_tick;
    reg [11:0] rgb_reg;
    wire [11:0] rgb_next;
    assign {vga_r,vga_g,vga_b} = rgb_reg;
    
    vga_controller vga(
        .clk_100MHz(clk),
        .reset(reset_stable),
//        .reset(),
        .video_on(video_tick),
        .hsync(hsync),
        .vsync(vsync),
        .p_tick(rgb_tick), 
        .x(current_x),
        .y(current_y)
    );
    
    screen_data_controller sdc(
        .clk(clk),
        .reset(reset_stable),
        .video_on(video_tick),
        .x(current_x),
        .y(current_y),
        .type_signal(rx_out_tick),
        .thai_flag_in(rx_flag[0]),
        .shift_flag_in(rx_flag[1]),
        .keycode_in(rx_keycode),
        .rgb_out(rgb_next)
    );
    
    always @(posedge clk) begin
        if(rgb_tick)
            rgb_reg <= rgb_next;
    end
    
    ////////////////////////////////////
    // Display Switch value on 7-Segment
    
    reg [3:0] num3,num2,num1,num0 = 0; // left to right
    wire an0,an1,an2,an3;
    assign an={an3,an2,an1,an0};
    
    // Clock (For TDM) 10ns * 2^19 ~ 5ms
    // (All four digits should be driven once every 1-16 ms)
    wire clk_tdm;
    clock_divider_n #(19) tdm_clk_div(.clk_in(clk), .clk_out(clk_tdm));
    
    quad_7seg_controller q7seg(seg,dp,an0,an1,an2,an3,num0,num1,num2,num3,clk_tdm);
    
    always @(posedge clk_tdm) begin
        num3 = sw_thai;
        if(sw[7:0] > 999)
        begin
            num2 = 10;
            num1 = 10;
            num0 = 10;
        end else begin
            num2 = (sw[7:0] % 1000) / 100;
            num1 = (sw[7:0] % 100) / 10;
            num0 = (sw[7:0] % 10);
        end
    end
    
endmodule
