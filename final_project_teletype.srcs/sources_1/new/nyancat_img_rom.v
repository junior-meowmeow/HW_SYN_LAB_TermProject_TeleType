`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.12.2024 21:07:55
// Design Name: 
// Module Name: nyancat_img_rom
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


module nyancat_img_rom(
    input  [ 2:0]  frame,
    input  [ 4:0]  img_y,
    input  [ 5:0]  img_x,
    output [11:0]  color_out,
    output         no_color
    );
    
    reg [34*3-1:0]  line_out;
    reg [     5:0]  x_select;
    reg [     2:0] color_code;
    
    //////////////////////
    // Color Definition
    wire [11:0] color_1;
    wire [11:0] color_2;
    wire [11:0] color_3;
    wire [11:0] color_4;
    wire [11:0] color_5;
    wire [11:0] color_6;
    wire [11:0] color_7;
    assign color_1 = 12'h000;
    assign color_2 = 12'hAAA;
    assign color_3 = 12'hFFF;
    assign color_4 = 12'hF3A;
    assign color_5 = 12'hFAA;
    assign color_6 = 12'hFCA;
    assign color_7 = 12'hFAF;
    
    assign no_color = color_code == 0;
    assign color_out =  (color_code == 1) ? color_1 :
                        (color_code == 2) ? color_2 :
                        (color_code == 3) ? color_3 :
                        (color_code == 4) ? color_4 :
                        (color_code == 5) ? color_5 :
                        (color_code == 6) ? color_6 :
                        (color_code == 7) ? color_7 :
                        12'h0F0; // This shouldn't be displayed
    
    
    always @(frame, img_y, img_x) begin
        line_out = 0;
        x_select = img_x;
        case({frame, img_y})
            {3'd0, 5'd0} : line_out = 102'o0000000001111111111111111100000000;
            {3'd0, 5'd1} : line_out = 102'o0000000016666666666666666610000000;
            {3'd0, 5'd2} : line_out = 102'o0000000166677777777777776661000000;
            {3'd0, 5'd3} : line_out = 102'o0000000166777777477477777661000000;
            {3'd0, 5'd4} : line_out = 102'o0000000167747777777777777761000000;
            {3'd0, 5'd5} : line_out = 102'o0000000167777777777117747761011000;
            {3'd0, 5'd6} : line_out = 102'o0000000167777777771221777761122100;
            {3'd0, 5'd7} : line_out = 102'o0111100167777774771222177761222100;
            {3'd0, 5'd8} : line_out = 102'o0122110167777777771222211112222100;
            {3'd0, 5'd9} : line_out = 102'o0112211167774777771222222222222100;
            {3'd0, 5'd10} : line_out = 102'o0011221167777777412222222222222210;
            {3'd0, 5'd11} : line_out = 102'o0001122167477777712223122222312210;
            {3'd0, 5'd12} : line_out = 102'o0000111167777777712221122212112210;
            {3'd0, 5'd13} : line_out = 102'o0000001167777747712552222222225510;
            {3'd0, 5'd14} : line_out = 102'o0000000166747777712552122122125510;
            {3'd0, 5'd15} : line_out = 102'o0000000166677777771222111111122100;
            {3'd0, 5'd16} : line_out = 102'o0000001116666666666122222222221000;
            {3'd0, 5'd17} : line_out = 102'o0000012221111111111111111111110000;
            {3'd0, 5'd18} : line_out = 102'o0000012211012210000012210122100000;
            {3'd0, 5'd19} : line_out = 102'o0000011110011100000001110011000000;
            {3'd0, 5'd20} : line_out = 102'o0000000000000000000000000000000000;
            
            {3'd1, 5'd0} : line_out = 102'o0000000001111111111111111100000000;
            {3'd1, 5'd1} : line_out = 102'o0000000016666666666666666610000000;
            {3'd1, 5'd2} : line_out = 102'o0000000166677777777777776661000000;
            {3'd1, 5'd3} : line_out = 102'o0000000166777777477477777661000000;
            {3'd1, 5'd4} : line_out = 102'o0000000167747777777777777761000000;
            {3'd1, 5'd5} : line_out = 102'o0000000167777777777711747761001100;
            {3'd1, 5'd6} : line_out = 102'o0000000167777777777122177761012210;
            {3'd1, 5'd7} : line_out = 102'o0000000167777774777122217761122210;
            {3'd1, 5'd8} : line_out = 102'o0011000167777777777122221111222210;
            {3'd1, 5'd9} : line_out = 102'o0122100167774777777122222222222210;
            {3'd1, 5'd10} : line_out = 102'o0122111167777777471222222222222221;
            {3'd1, 5'd11} : line_out = 102'o0012222167477777771222312222231221;
            {3'd1, 5'd12} : line_out = 102'o0001122167777777771222112221211221;
            {3'd1, 5'd13} : line_out = 102'o0000011167777747771255222222222551;
            {3'd1, 5'd14} : line_out = 102'o0000000166747777771255212212212551;
            {3'd1, 5'd15} : line_out = 102'o0000000166677777777122211111112210;
            {3'd1, 5'd16} : line_out = 102'o0000000116666666666612222222222100;
            {3'd1, 5'd17} : line_out = 102'o0000001221111111111111111111111000;
            {3'd1, 5'd18} : line_out = 102'o0000001221012210000001221012210000;
            {3'd1, 5'd19} : line_out = 102'o0000001110001110000000111001110000;
            {3'd1, 5'd20} : line_out = 102'o0000000000000000000000000000000000;
            
            {3'd2, 5'd0} : line_out = 102'o0000000000000000000000000000000000;
            {3'd2, 5'd1} : line_out = 102'o0000000001111111111111111100000000;
            {3'd2, 5'd2} : line_out = 102'o0000000016666666666666666610000000;
            {3'd2, 5'd3} : line_out = 102'o0000000166677777777777776661000000;
            {3'd2, 5'd4} : line_out = 102'o0000000166777777477477777661000000;
            {3'd2, 5'd5} : line_out = 102'o0000000167747777777777777761000000;
            {3'd2, 5'd6} : line_out = 102'o0000000167777777777711747761001100;
            {3'd2, 5'd7} : line_out = 102'o0000000167777777777122177761012210;
            {3'd2, 5'd8} : line_out = 102'o0000000167777774777122217761122210;
            {3'd2, 5'd9} : line_out = 102'o0000000167777777777122221111222210;
            {3'd2, 5'd10} : line_out = 102'o0000000167774777777122222222222210;
            {3'd2, 5'd11} : line_out = 102'o0000001167777777471222222222222221;
            {3'd2, 5'd12} : line_out = 102'o0001111167477777771222312222231221;
            {3'd2, 5'd13} : line_out = 102'o0112222167777777771222112221211221;
            {3'd2, 5'd14} : line_out = 102'o0122211167777747771255222222222551;
            {3'd2, 5'd15} : line_out = 102'o0011110166747777771255212212212551;
            {3'd2, 5'd16} : line_out = 102'o0000000166677777777122211111112210;
            {3'd2, 5'd17} : line_out = 102'o0000000116666666666612222222222100;
            {3'd2, 5'd18} : line_out = 102'o0000000121111111111111111111111000;
            {3'd2, 5'd19} : line_out = 102'o0000000122101221000000122101221000;
            {3'd2, 5'd20} : line_out = 102'o0000000111000111000000011100111000;
            
            {3'd3, 5'd0} : line_out = 102'o0000000000000000000000000000000000;
            {3'd3, 5'd1} : line_out = 102'o0000000001111111111111111100000000;
            {3'd3, 5'd2} : line_out = 102'o0000000016666666666666666610000000;
            {3'd3, 5'd3} : line_out = 102'o0000000166677777777777776661000000;
            {3'd3, 5'd4} : line_out = 102'o0000000166777777477477777661000000;
            {3'd3, 5'd5} : line_out = 102'o0000000167747777777777777761000000;
            {3'd3, 5'd6} : line_out = 102'o0000000167777777777711747761001100;
            {3'd3, 5'd7} : line_out = 102'o0000000167777777777122177761012210;
            {3'd3, 5'd8} : line_out = 102'o0000000167777774777122217761122210;
            {3'd3, 5'd9} : line_out = 102'o0000000167777777777122221111222210;
            {3'd3, 5'd10} : line_out = 102'o0000000167774777777122222222222210;
            {3'd3, 5'd11} : line_out = 102'o0000011167777777471222222222222221;
            {3'd3, 5'd12} : line_out = 102'o0001122167477777771222312222231221;
            {3'd3, 5'd13} : line_out = 102'o0012222167777777771222112221211221;
            {3'd3, 5'd14} : line_out = 102'o0122111167777747771255222222222551;
            {3'd3, 5'd15} : line_out = 102'o0122100166747777771255212212212551;
            {3'd3, 5'd16} : line_out = 102'o0011000166677777777122211111112210;
            {3'd3, 5'd17} : line_out = 102'o0000000116666666666612222222222100;
            {3'd3, 5'd18} : line_out = 102'o0000001221111111111111111111111000;
            {3'd3, 5'd19} : line_out = 102'o0000001221012210000001221012210000;
            {3'd3, 5'd20} : line_out = 102'o0000001110001110000000111001110000;
            
            {3'd4, 5'd0} : line_out = 102'o0000000000000000000000000000000000;
            {3'd4, 5'd1} : line_out = 102'o0000000001111111111111111100000000;
            {3'd4, 5'd2} : line_out = 102'o0000000016666666666666666610000000;
            {3'd4, 5'd3} : line_out = 102'o0000000166677777777777776661000000;
            {3'd4, 5'd4} : line_out = 102'o0000000166777777477477777661000000;
            {3'd4, 5'd5} : line_out = 102'o0000000167747777777777777761000000;
            {3'd4, 5'd6} : line_out = 102'o0000000167777777777117747761011000;
            {3'd4, 5'd7} : line_out = 102'o0000000167777777771221777761122100;
            {3'd4, 5'd8} : line_out = 102'o0000000167777774771222177761222100;
            {3'd4, 5'd9} : line_out = 102'o0111100167777777771222211112222100;
            {3'd4, 5'd10} : line_out = 102'o1222111167774777771222222222222100;
            {3'd4, 5'd11} : line_out = 102'o1122221167777777412222222222222210;
            {3'd4, 5'd12} : line_out = 102'o0011112167477777712223122222312210;
            {3'd4, 5'd13} : line_out = 102'o0000011167777777712221122212112210;
            {3'd4, 5'd14} : line_out = 102'o0000000167777747712552222222225510;
            {3'd4, 5'd15} : line_out = 102'o0000000166747777712552122122125510;
            {3'd4, 5'd16} : line_out = 102'o0000001166677777771222111111122100;
            {3'd4, 5'd17} : line_out = 102'o0000011116666666666122222222221000;
            {3'd4, 5'd18} : line_out = 102'o0000122211111111111111111111110000;
            {3'd4, 5'd19} : line_out = 102'o0000122101221000000122101221000000;
            {3'd4, 5'd20} : line_out = 102'o0000111000111000000011100111000000;
            
            {3'd5, 5'd0} : line_out = 102'o0000000000000000000000000000000000;
            {3'd5, 5'd1} : line_out = 102'o0000000001111111111111111100000000;
            {3'd5, 5'd2} : line_out = 102'o0000000016666666666666666610000000;
            {3'd5, 5'd3} : line_out = 102'o0000000166677777777777776661000000;
            {3'd5, 5'd4} : line_out = 102'o0000000166777777477477777661000000;
            {3'd5, 5'd5} : line_out = 102'o0000000167747777777117777761011000;
            {3'd5, 5'd6} : line_out = 102'o0000000167777777771221747761122100;
            {3'd5, 5'd7} : line_out = 102'o0000000167777777771222177761222100;
            {3'd5, 5'd8} : line_out = 102'o0011000167777774771222211112222100;
            {3'd5, 5'd9} : line_out = 102'o0122100167777777771222222222222100;
            {3'd5, 5'd10} : line_out = 102'o0122111167774777712222222222222210;
            {3'd5, 5'd11} : line_out = 102'o0012222167777777412223122222312210;
            {3'd5, 5'd12} : line_out = 102'o0001122167477777712221122212112210;
            {3'd5, 5'd13} : line_out = 102'o0000011167777777712552222222225510;
            {3'd5, 5'd14} : line_out = 102'o0000000167777747712552122122125510;
            {3'd5, 5'd15} : line_out = 102'o0000000166747777771222111111122100;
            {3'd5, 5'd16} : line_out = 102'o0000001166677777777122222222221000;
            {3'd5, 5'd17} : line_out = 102'o0000012116666666666611111111110000;
            {3'd5, 5'd18} : line_out = 102'o0000122211111111111111111121000000;
            {3'd5, 5'd19} : line_out = 102'o0000122101221000000122101221000000;
            {3'd5, 5'd20} : line_out = 102'o0000111001110000000111000111000000;
    
        endcase
    end
    
    always @(line_out, x_select) begin
        color_code = 0;
        case(x_select)
            6'd0  : color_code = line_out[101:99];
            6'd1  : color_code = line_out[98:96];
            6'd2  : color_code = line_out[95:93];
            6'd3  : color_code = line_out[92:90];
            6'd4  : color_code = line_out[89:87];
            6'd5  : color_code = line_out[86:84];
            6'd6  : color_code = line_out[83:81];
            6'd7  : color_code = line_out[80:78];
            6'd8  : color_code = line_out[77:75];
            6'd9  : color_code = line_out[74:72];
            6'd10 : color_code = line_out[71:69];
            6'd11 : color_code = line_out[68:66];
            6'd12 : color_code = line_out[65:63];
            6'd13 : color_code = line_out[62:60];
            6'd14 : color_code = line_out[59:57];
            6'd15 : color_code = line_out[56:54];
            6'd16 : color_code = line_out[53:51];
            6'd17 : color_code = line_out[50:48];
            6'd18 : color_code = line_out[47:45];
            6'd19 : color_code = line_out[44:42];
            6'd20 : color_code = line_out[41:39];
            6'd21 : color_code = line_out[38:36];
            6'd22 : color_code = line_out[35:33];
            6'd23 : color_code = line_out[32:30];
            6'd24 : color_code = line_out[29:27];
            6'd25 : color_code = line_out[26:24];
            6'd26 : color_code = line_out[23:21];
            6'd27 : color_code = line_out[20:18];
            6'd28 : color_code = line_out[17:15];
            6'd29 : color_code = line_out[14:12];
            6'd30 : color_code = line_out[11:9];
            6'd31 : color_code = line_out[8:6];
            6'd32 : color_code = line_out[5:3];
            6'd33 : color_code = line_out[2:0];
            default : color_code = 0;
        endcase
    end


endmodule