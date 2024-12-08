`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.12.2024 12:37:31
// Design Name: 
// Module Name: data_to_rgb
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


module data_to_rgb 
    #(
        // 80-by-30 tile map (need to be the same as screen_data_controller)
        parameter MAX_X = 80,   // 640 pixels / 8 data bits = 80
        parameter MAX_Y = 30,   // 480 pixels / 16 data rows = 30
        parameter START_X = 20, 
        parameter START_Y = 5,
        parameter END_X = 60,
        parameter END_Y = 20
    )(
        input               clk,
        input               reset,
        input       [ 9:0]  x_logic_before,
        input       [ 9:0]  x_logic,
        input       [ 9:0]  y_logic,
        input       [ 9:0]  current_x,
        input       [ 9:0]  current_y,
        input       [ 6:0]  cursor_x,
        input       [ 4:0]  cursor_y,
        input               font_bit,
        input               highlight_text,
        input               command_text,
        input               cmd_signal_in,
        input       [ 2:0]  cmd_code_in,
        output reg  [11:0]  rgb_out,
        output      [11:0]  image_color
    );
    
    //////////////////////
    // Color Definition
    wire [11:0] light_yellow;
    wire [11:0] dark_blue;
    wire [11:0] green;
    wire [11:0] pink;
    wire [11:0] red;
    wire [11:0] blue;
    wire [11:0] white;
    wire [11:0] black;
    wire [11:0] dark_purple;
    assign light_yellow = 12'hFFB;
    assign dark_blue = 12'h113;
    assign green = 12'h1F1;
    assign pink = 12'hF0C;
    assign red = 12'hF11;
    assign blue = 12'h11F;
    assign white = 12'hFFF;
    assign black = 12'h000;
    assign dark_purple = 12'h212;
    
    reg [11:0] fg_color = 12'hFFB; // foreground color = light yellow
    reg [11:0] bg_color = 12'h113; // background color = dark blue
    reg [11:0] hl_color = 12'h1F1; // highlight color = green
    reg [11:0] cmd_color = 12'hF0C; // command color = pink
    assign image_color = fg_color;
    
    //////////////////////
    // Logic Parameter
    wire on_cursor;
    assign on_cursor = (current_y[8:4] == cursor_y) &&
                       (current_x[9:3] == cursor_x);
                       
    wire [9:0] leftmost_x; assign leftmost_x = START_X*8;
    wire [9:0] rightmost_x; assign rightmost_x = END_X*8-1;
    wire [9:0] top_y; assign top_y = START_Y*16;
    wire [9:0] bottom_y; assign bottom_y = END_Y*16-1;
    
    // Keep in register to meet the timing requirement
    reg inside_text_area = 0;
    reg text_area_frame = 0;
    reg top_area = 0;
    reg [95:0] title_line_reg = 0;
    
    wire [95:0] title_img_line;
    title_img_rom title_img(
        .y(y_logic-2*16),
        .line_out(title_img_line)
    );
    
    // for nyan cat    
    reg nyancat_area_prepare = 0;
    reg nyancat_area = 0;
    reg        nyancat_start_signal = 0;
    reg        nyancat_start_prev = 0;
    reg        running_nyancat = 0;
    reg [ 9:0] nyancat_start_x = -128;
    reg [ 2:0] nyancat_frame = 0;
    reg [ 7:0] nyancat_y = 0;
    reg [ 7:0] nyancat_x = 0;
            
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            inside_text_area <= 0;
            text_area_frame <= 0;
            top_area <= 0;
            nyancat_area_prepare <= 0;
            nyancat_area_prepare <= 0;
            title_line_reg <= 0;
        end
        else begin
            // draw text font inside text area
            inside_text_area <= x_logic[9:3] >= START_X && x_logic[9:3] < END_X
                    && current_y[8:4] >= START_Y && current_y[8:4] < END_Y;
                    
            // draw a border outside text area
            text_area_frame <= (x_logic >= leftmost_x-8 && x_logic <= rightmost_x+8
                    && y_logic >= top_y-8 && y_logic <= bottom_y+8) &&
                    ~(x_logic >= leftmost_x-4 && x_logic <= rightmost_x+4
                    && y_logic >= top_y-4 && y_logic <= bottom_y+4);
                 
            // draw top area   
            top_area <= y_logic >= 32 && y_logic < 64 && x_logic >= 272 && x_logic < 368;
            title_line_reg <= title_img_line;
            
            // set nyancat position -> 2x2 pixel
            nyancat_y <= y_logic[9:2] - 8'd88; // 352/(2x2)
            nyancat_x <= x_logic[9:2] - nyancat_start_x[9:2]; // start_x/(2x2)
            // draw nyancat area
            nyancat_area_prepare <=   ((nyancat_start_x < MAX_X*8+10) ? (x_logic_before >= nyancat_start_x) : (x_logic_before >= 0)) && 
                            ((nyancat_start_x < MAX_X*8+10) ? (x_logic_before < nyancat_start_x + 34*4) : (x_logic_before < nyancat_start_x - 1024 + 34*4));
            nyancat_area <=   y_logic >= 352 && y_logic < 436 && nyancat_area_prepare;
        end
    end
    
    wire [ 11:0] nyancat_bit_color;
    wire         nyancat_no_color;
    nyancat_img_rom nyancat_img(
        .frame(nyancat_frame ),
        .img_y(nyancat_y),
        .img_x(nyancat_x),
        .color_out(nyancat_bit_color),
        .no_color(nyancat_no_color)
    );
    
    //////////////////////
    // Set RGB Output
    
    always @* begin
        if (inside_text_area) begin
            if(on_cursor)
                rgb_out <= (font_bit) ? bg_color : fg_color;
            else
                rgb_out <= (~font_bit) ? bg_color :
                            (command_text) ? cmd_color : 
                            (highlight_text) ? hl_color : fg_color;
        end
        else if (text_area_frame) begin
            rgb_out <= fg_color;
        end
        else if (top_area) begin
            rgb_out <= (title_line_reg[367-current_x]) ? fg_color : bg_color;
        end
        else if (running_nyancat && nyancat_area) begin
            rgb_out <= (nyancat_no_color) ? bg_color : nyancat_bit_color;
        end 
        else begin
            rgb_out <= bg_color;
        end
    end
    
    //////////////////////
    // Logic for Commands
    
    // Clock for Nyan Cat 10ns * 2^19 ~ 5ms
    wire clk_5ms;
    clock_divider_n #(19) clk_cat_div(.clk_in(clk), .clk_out(clk_5ms));
    
    // Run nyan_cat
    always @(posedge clk_5ms or posedge reset) begin
        if(reset) begin
            nyancat_start_x <= -128;
            nyancat_frame <= 0;
            nyancat_start_prev <= 0;
            running_nyancat <= 0;
        end    
        else begin
            if (nyancat_start_prev != nyancat_start_signal) begin
                running_nyancat <= 1;
                nyancat_start_x <= -128;
            end
            if (running_nyancat) begin
                nyancat_start_x <= nyancat_start_x + 1;
                if (nyancat_start_x % 20 == 0) begin
                    nyancat_frame <= (nyancat_frame == 5) ? 0 : nyancat_frame + 1;
                end
                if (nyancat_start_x == MAX_X*8 + 1) begin
                    running_nyancat <= 0;
                end
            end
            nyancat_start_prev <= nyancat_start_signal;
        end
    end
    
    always @(posedge cmd_signal_in, posedge reset) begin
        if (reset) begin
            fg_color = light_yellow;
            bg_color = dark_blue;
            hl_color = green;
            cmd_color = pink;
            nyancat_start_signal <= 0;
        end else if (cmd_signal_in) begin
            case(cmd_code_in)
                3'd1 : begin
                        // Use flipping bit to start nyan cat
                        nyancat_start_signal <= ~nyancat_start_signal;
                    end
                3'd2 : begin
                        // Toggle show author <- logic is transfered to screen_data_controller
                    end
                3'd3 : begin // red theme        
                        fg_color = red;
                        bg_color = dark_purple;
                        hl_color = light_yellow;
                
                    end
                3'd4 : begin // green theme
                        fg_color = green;
                        bg_color = black;
                        hl_color = white;
                
                    end
                3'd5 : begin // blue theme
                        fg_color = blue;
                        bg_color = white;
                        hl_color = red;
                    end
                3'd6 : begin // default theme
                        fg_color = light_yellow;
                        bg_color = dark_blue;
                        hl_color = green;
                    end
            endcase
        end
    end
    
endmodule
