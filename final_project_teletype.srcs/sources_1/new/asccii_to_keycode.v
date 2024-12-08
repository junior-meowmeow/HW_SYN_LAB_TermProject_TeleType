`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.12.2024 23:22:45
// Design Name: 
// Module Name: asccii_to_keycode
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


module ascii_to_keycode( // Converts ASCII to keycode + shift
    input [7:0] ascii,         // ASCII input
    output reg [7:0] keycode,  // PS/2 keycode output
    output reg shift           // Shift flag output
);
    always @* begin
        // Default values
        keycode = 8'h00;
        shift = 1'b0;

        case (ascii)
            // Numbers (0-9, no shift needed)
            8'h30: keycode = 8'h45; // 0
            8'h31: keycode = 8'h16; // 1
            8'h32: keycode = 8'h1E; // 2
            8'h33: keycode = 8'h26; // 3
            8'h34: keycode = 8'h25; // 4
            8'h35: keycode = 8'h2E; // 5
            8'h36: keycode = 8'h36; // 6
            8'h37: keycode = 8'h3D; // 7
            8'h38: keycode = 8'h3E; // 8
            8'h39: keycode = 8'h46; // 9

            // Uppercase letters (require shift)
            8'h41: begin shift = 1'b1; keycode = 8'h1C; end // A
            8'h42: begin shift = 1'b1; keycode = 8'h32; end // B
            8'h43: begin shift = 1'b1; keycode = 8'h21; end // C
            8'h44: begin shift = 1'b1; keycode = 8'h23; end // D
            8'h45: begin shift = 1'b1; keycode = 8'h24; end // E
            8'h46: begin shift = 1'b1; keycode = 8'h2B; end // F
            8'h47: begin shift = 1'b1; keycode = 8'h34; end // G
            8'h48: begin shift = 1'b1; keycode = 8'h33; end // H
            8'h49: begin shift = 1'b1; keycode = 8'h43; end // I
            8'h4A: begin shift = 1'b1; keycode = 8'h3B; end // J
            8'h4B: begin shift = 1'b1; keycode = 8'h42; end // K
            8'h4C: begin shift = 1'b1; keycode = 8'h4B; end // L
            8'h4D: begin shift = 1'b1; keycode = 8'h3A; end // M
            8'h4E: begin shift = 1'b1; keycode = 8'h31; end // N
            8'h4F: begin shift = 1'b1; keycode = 8'h44; end // O
            8'h50: begin shift = 1'b1; keycode = 8'h4D; end // P
            8'h51: begin shift = 1'b1; keycode = 8'h15; end // Q
            8'h52: begin shift = 1'b1; keycode = 8'h2D; end // R
            8'h53: begin shift = 1'b1; keycode = 8'h1B; end // S
            8'h54: begin shift = 1'b1; keycode = 8'h2C; end // T
            8'h55: begin shift = 1'b1; keycode = 8'h3C; end // U
            8'h56: begin shift = 1'b1; keycode = 8'h2A; end // V
            8'h57: begin shift = 1'b1; keycode = 8'h1D; end // W
            8'h58: begin shift = 1'b1; keycode = 8'h22; end // X
            8'h59: begin shift = 1'b1; keycode = 8'h35; end // Y
            8'h5A: begin shift = 1'b1; keycode = 8'h1A; end // Z

            // Lowercase letters (no shift)
            8'h61: keycode = 8'h1C; // a
            8'h62: keycode = 8'h32; // b
            8'h63: keycode = 8'h21; // c
            8'h64: keycode = 8'h23; // d
            8'h65: keycode = 8'h24; // e
            8'h66: keycode = 8'h2B; // f
            8'h67: keycode = 8'h34; // g
            8'h68: keycode = 8'h33; // h
            8'h69: keycode = 8'h43; // i
            8'h6A: keycode = 8'h3B; // j
            8'h6B: keycode = 8'h42; // k
            8'h6C: keycode = 8'h4B; // l
            8'h6D: keycode = 8'h3A; // m
            8'h6E: keycode = 8'h31; // n
            8'h6F: keycode = 8'h44; // o
            8'h70: keycode = 8'h4D; // p
            8'h71: keycode = 8'h15; // q
            8'h72: keycode = 8'h2D; // r
            8'h73: keycode = 8'h1B; // s
            8'h74: keycode = 8'h2C; // t
            8'h75: keycode = 8'h3C; // u
            8'h76: keycode = 8'h2A; // v
            8'h77: keycode = 8'h1D; // w
            8'h78: keycode = 8'h22; // x
            8'h79: keycode = 8'h35; // y
            8'h7A: keycode = 8'h1A; // z

            // Space, Enter, Backspace
            8'h20: keycode = 8'h29; // Space
            8'h0D: keycode = 8'h5A; // Enter
            8'h08: keycode = 8'h66; // Backspace

            // Special characters (add more cases as needed)
            8'h2D: keycode = 8'h4E; // -
            8'h3D: keycode = 8'h55; // =
            8'h5B: keycode = 8'h54; // [
            8'h5D: keycode = 8'h5B; // ]
            8'h5C: keycode = 8'h5D; // \
            8'h3B: keycode = 8'h4C; // ;
            8'h27: keycode = 8'h52; // '
            8'h2C: keycode = 8'h41; // ,
            8'h2E: keycode = 8'h49; // .
            8'h2F: keycode = 8'h4A; // /

            default: keycode = 8'h00; // Unknown key
        endcase
    end
endmodule
