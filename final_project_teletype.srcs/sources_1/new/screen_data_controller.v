`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.12.2024 04:41:57
// Design Name: 
// Module Name: screen_data_controller
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


module screen_data_controller(
    input          clk,
    input          reset,
    input          video_on,
    input  [ 9:0]  x,
    input  [ 9:0]  y,
    input          type_signal,
    input          thai_flag_in,
    input          shift_flag_in,
    input  [ 7:0]  keycode_in,
    output [11:0]  rgb_out
    );
    
    // ROM
    wire [10:0] rom_addr;
    wire        thai_flag_ram;
    wire        shift_flag_ram;
    wire [ 7:0] keycode_ram;
    wire [ 7:0] char_addr;
    wire [ 3:0] row_addr;
    wire [ 2:0] bit_addr;
    
    wire [ 7:0] ascii_code;
    wire [ 7:0] font_word;
    wire        font_bit;
    // Dual-port RAM
    wire write_enable;
    wire [11:0] addr_r, addr_w;
    wire [9:0] din, dout;
    // 80-by-30 tile map
    parameter MAX_X = 80;   // 640 pixels / 8 data bits = 80
    parameter MAX_Y = 30;   // 480 pixels / 16 data rows = 30
    
    parameter START_X = 20; 
    parameter START_Y = 5;
    parameter END_X = 60;
    parameter END_Y = 20;
    
    // Cursor position
    reg [6:0] cursor_x = START_X;
    wire [6:0] cursor_x_next;
    reg [4:0] cursor_y = START_Y;
    wire [4:0] cursor_y_next;
    // Delayed x,y position
    reg [9:0] current_x, current_y;
    reg [9:0] current_x_delayed, current_y_delayed;
    
    //////////////////////////
    // Special Character & Functions
    wire is_leftmost;
    assign is_leftmost = cursor_x == START_X;
    wire is_rightmost;
    assign is_rightmost = cursor_x == END_X - 1;
    wire is_top;
    assign is_top = cursor_y == START_Y;
    wire is_bottom;
    assign is_bottom = cursor_y == END_Y - 1;
    wire carriage_return;
    assign carriage_return = keycode_in == 8'h5a;
    wire delete_back;
    assign delete_back = type_signal && (keycode_in == 8'h66);
    wire new_line ;
    assign new_line = type_signal && ~delete_back && (is_rightmost || carriage_return);
    reg         new_line_prev = 0;
    reg         is_flushing_line = 0;
    reg [ 4:0]  line_to_flush = 0;
    reg [ 6:0]  col_to_flush = 0;
    
    // check first 8 characters in the line
    // for command (/nyancat and /author)
    reg [ 4:0]  char_count;
    reg [ 8:0]  first_8char [ 7:0];
    
    keycode_to_ascii(
        .thai_flag(thai_flag_ram),
        .shift_flag(shift_flag_ram),
        .keycode(keycode_ram),
        .ascii(ascii_code)
    );
    font_rom ascii_to_font(
        .clk(clk),
        .thai_flag(thai_flag_ram),
        .addr(rom_addr),  
        .data(font_word)
    );
    
    dual_port_ram #(.DATA_SIZE(10), .ADDR_SIZE(12)) dp_ram(
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .addr_a(addr_w),
        .addr_b(addr_r),
        .din_a(din),
        .dout_a(),
        .dout_b(dout)
    );
    
    // cursor and position
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            cursor_x <= START_X;
            cursor_y <= START_Y;
            current_x <= 0;
            current_x_delayed <= 0;
            current_y <= 0;
            current_y_delayed <= 0;
            char_count <= 0;
        end    
        else begin
            cursor_x <= cursor_x_next;
            cursor_y <= cursor_y_next;
            current_x <= x;
            current_x_delayed <= current_x;
            current_y <= y;
            current_y_delayed <= current_y;
            // for command
            if (cursor_y != cursor_y_next) begin
                char_count <= 0;
            end else if (cursor_x_next > START_X+8) begin
                char_count <= 0;
            end else if (cursor_x - 1 == cursor_x_next) begin
                if (cursor_x_next == START_X+8)
                    char_count <= 8;
                else
                    char_count <= char_count - 1;
                    first_8char[char_count - 1] <= 0;
            end else if (cursor_x + 1 == cursor_x_next) begin
                char_count <= char_count + 1;
                first_8char[char_count] <= {thai_flag_in,keycode_in};
            end
        end
    end
    
    // RAM write
    assign addr_w = (is_flushing_line) ? {line_to_flush, col_to_flush} : 
                    (delete_back) ? {cursor_y_next, cursor_x_next} : 
                    {cursor_y, cursor_x};
    assign write_enable = type_signal || is_flushing_line;
    assign din = (is_flushing_line) ? 10'd0 : {thai_flag_in,shift_flag_in,keycode_in};
    // RAM read
    // use nondelayed coordinates to form tile RAM address
    assign addr_r = {y[8:4], x[9:3]};
    assign {thai_flag_ram,shift_flag_ram,keycode_ram} = dout;
    assign char_addr = ascii_code;
    // font ROM
    assign row_addr = y[3:0];
    assign rom_addr = {char_addr, row_addr};
    // use delayed coordinate to select a bit
    assign bit_addr = current_x_delayed[2:0];
    assign font_bit = font_word[~bit_addr];
    // new cursor position
    
    assign cursor_x_next = (new_line) ? START_X :   // back to left side
                        (delete_back && is_leftmost && ~is_top) ? END_X-1 :         // move to right side
                        (delete_back && ~is_leftmost) ? cursor_x - 1 :              // move left
                        (type_signal && ~delete_back) ? cursor_x + 1 :              // move right
                        cursor_x;                                                   // no move
                             
    assign cursor_y_next = (new_line && is_bottom) ? START_Y :                      // back to top         
                        (delete_back && is_leftmost && ~is_top) ? cursor_y - 1 :    // move up 
                        (new_line) ? cursor_y + 1 :                                 // move down
                        cursor_y;                                                   // no move               
    
    //////////////////////
    // Flush Line when new_line
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            new_line_prev <= 0;
            line_to_flush <= 0;
            col_to_flush <= 0;
        end    
        else begin
            if (new_line && ~new_line_prev) begin
                is_flushing_line <= 1;
                line_to_flush <= cursor_y;
                col_to_flush <= cursor_x+1;
            end
            if (is_flushing_line) begin
                col_to_flush <= col_to_flush + 1;
                if(col_to_flush == END_X) begin
                    is_flushing_line <= 0;
                end
            end
            new_line_prev <= new_line;
        end
    end
    
    // for command (/{command_name})
    wire nyan_cat_cmd;
    wire show_author_cmd;
    wire red_color_cmd;
    wire green_color_cmd;
    wire blue_color_cmd;
    wire default_color_cmd;
    // need to save in register because too much logic gate (VGA timing delay)
    reg  cmd_match;
    reg  cmd_execute_signal;
    reg  [2:0] cmd_code = 0;
    
    // showing author will be running here instead
    reg showing_author = 0;
                            
    // For update command
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            cmd_execute_signal <= 0;
            cmd_match <= 0;
            showing_author <= 0;
        end    
        else begin
            if (new_line && ~new_line_prev && cmd_match) begin
                cmd_execute_signal <= 1;
                if(cmd_code == 3'd2) begin
                    showing_author <= ~showing_author;
                end
            end else begin
                cmd_execute_signal <= 0;
            end
            
            cmd_code <=  (nyan_cat_cmd)     ?   3'd1 :
                         (show_author_cmd)  ?   3'd2 :
                         (red_color_cmd)    ?   3'd3 :
                         (green_color_cmd)  ?   3'd4 :
                         (blue_color_cmd)   ?   3'd5 :
                         (default_color_cmd)?   3'd6 : 3'd0;
            
            // Avoid gate delay by storing in register
            cmd_match <= nyan_cat_cmd       ||
                         show_author_cmd    ||
                         red_color_cmd      ||
                         green_color_cmd    ||
                         blue_color_cmd     ||
                         default_color_cmd;
        end
    end
    
    wire highlight_text;
    assign highlight_text = cursor_y == current_y[8:4] && current_x[9:3] < cursor_x;
    wire command_text;
    assign command_text = cmd_match && highlight_text;
    
    //////////////////////
    // Convert Data to RGB
    
    // Some images are here to meet the timing requirements
    wire [127:0] pathorn_img_line;
    pathorn_img_rom pathorn_img(
        .y(y - 160),
        .line_out(pathorn_img_line)
    );
    
    wire [127:0] pacharaphon_img_line;
    pacharaphon_img_rom pacharaphon_img(
        .y(y - 160),
        .line_out(pacharaphon_img_line)
    );
    
    // for showing author
    reg pathorn_area = 0;
    reg pacharaphon_area = 0;
    reg [127:0] pathorn_img_line_reg = 0;
    reg [127:0] pacharaphon_img_line_reg = 0;
    reg [ 9:0] pathorn_bit = 0;
    reg [ 9:0] pacharaphon_bit = 0;
    reg [ 9:0] pathorn_bit_delayed = 0;
    reg [ 9:0] pacharaphon_bit_delayed = 0;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            pathorn_area = 0;
            pacharaphon_area = 0;
            pathorn_img_line_reg = 0;
            pacharaphon_img_line_reg = 0;
            pathorn_bit = 0;
            pacharaphon_bit = 0;
            pathorn_bit_delayed = 0;
            pacharaphon_bit_delayed = 0;
        end
        else begin
            // t = 0
            pathorn_img_line_reg <= pathorn_img_line;
            pacharaphon_img_line_reg <= pacharaphon_img_line;
            // draw pathorn area   
            pathorn_area <= showing_author && y >= 10'd160 && y < 10'd288 && x >= 10'd16 && x < 10'd144;
            // draw pacharaphon area    
            pacharaphon_area <= showing_author && y >= 10'd160 && y < 10'd288 && x >= 10'd496 && x < 10'd624;
            
            // t = 1
            pathorn_bit <= pathorn_img_line_reg[10'd143 - current_x] && pathorn_area;
            pacharaphon_bit <= pacharaphon_img_line_reg[10'd623 - current_x] && pacharaphon_area;
            
            // t = 2
            pathorn_bit_delayed <= pathorn_bit;
            pacharaphon_bit_delayed <= pacharaphon_bit;
        end
    end
    
    wire [11:0] image_color;
    wire [11:0] rgb_data;
    
    data_to_rgb
    #(
        .MAX_X(MAX_X),
        .MAX_Y(MAX_Y),
        .START_X(START_X), 
        .START_Y(START_Y),
        .END_X(END_X),
        .END_Y(END_Y)
    ) rgb_controller (
        .clk(clk),
        .reset(reset),
        .x_logic_before(x),
        .x_logic(current_x),
        .y_logic(current_y),
        .current_x(current_x_delayed),
        .current_y(current_y_delayed),
        .cursor_x(cursor_x),
        .cursor_y(cursor_y),
        .font_bit(font_bit),
        .highlight_text(highlight_text),
        .command_text(command_text),
        .cmd_signal_in(cmd_execute_signal),
        .cmd_code_in(cmd_code),
        .rgb_out(rgb_data),
        .image_color(image_color)
    );
    
    assign rgb_out = (~video_on || reset) ? 12'h000 : 
                    (pathorn_bit_delayed || pacharaphon_bit_delayed) ? image_color :
                    rgb_data;
    
    //////////////////////
    // Commands
    
    assign nyan_cat_cmd =       char_count == 8 &&
                            first_8char[0] == {1'b0, 8'h4a} && // '/'
                            first_8char[1] == {1'b0, 8'h31} && // N/n
                            first_8char[2] == {1'b0, 8'h35} && // Y/y
                            first_8char[3] == {1'b0, 8'h1c} && // A/a
                            first_8char[4] == {1'b0, 8'h31} && // N/n
                            first_8char[5] == {1'b0, 8'h21} && // C/c
                            first_8char[6] == {1'b0, 8'h1c} && // A/a
                            first_8char[7] == {1'b0, 8'h2c};   // T/t
                            
    assign show_author_cmd =    char_count == 7 &&
                            first_8char[0] == {1'b0, 8'h4a} && // '/'
                            first_8char[1] == {1'b0, 8'h1c} && // A/a
                            first_8char[2] == {1'b0, 8'h3c} && // U/u
                            first_8char[3] == {1'b0, 8'h2c} && // T/t
                            first_8char[4] == {1'b0, 8'h33} && // H/h
                            first_8char[5] == {1'b0, 8'h44} && // O/o
                            first_8char[6] == {1'b0, 8'h2d};   // R/r
                            
    assign red_color_cmd =      char_count == 4 &&
                            first_8char[0] == {1'b0, 8'h4a} && // '/'
                            first_8char[1] == {1'b0, 8'h2d} && // R/r
                            first_8char[2] == {1'b0, 8'h24} && // E/e
                            first_8char[3] == {1'b0, 8'h23};   // D/d
    
    assign green_color_cmd =    char_count == 6 &&
                            first_8char[0] == {1'b0, 8'h4a} && // '/'
                            first_8char[1] == {1'b0, 8'h34} && // G/g
                            first_8char[2] == {1'b0, 8'h2d} && // R/r
                            first_8char[3] == {1'b0, 8'h24} && // E/e
                            first_8char[4] == {1'b0, 8'h24} && // E/e
                            first_8char[5] == {1'b0, 8'h31};   // N/n
                            
    assign blue_color_cmd =     char_count == 5 &&
                            first_8char[0] == {1'b0, 8'h4a} && // '/'
                            first_8char[1] == {1'b0, 8'h32} && // B/b
                            first_8char[2] == {1'b0, 8'h4b} && // L/l
                            first_8char[3] == {1'b0, 8'h3c} && // U/u
                            first_8char[4] == {1'b0, 8'h24};   // E/e
                            
    assign default_color_cmd =    char_count == 8 &&
                            first_8char[0] == {1'b0, 8'h4a} && // '/'
                            first_8char[1] == {1'b0, 8'h23} && // D/d
                            first_8char[2] == {1'b0, 8'h24} && // E/e
                            first_8char[3] == {1'b0, 8'h2b} && // F/f
                            first_8char[4] == {1'b0, 8'h1c} && // A/a
                            first_8char[5] == {1'b0, 8'h3c} && // U/u
                            first_8char[6] == {1'b0, 8'h4b} && // L/l
                            first_8char[7] == {1'b0, 8'h2c};   // T/t

endmodule
