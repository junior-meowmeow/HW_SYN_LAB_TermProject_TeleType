`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.12.2024 04:57:45
// Design Name: 
// Module Name: keycode_to_ascii_th
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


//converts the real data from kb module to ASCII
module keycode_to_ascii_th(
	input[8:0] rd_data,
	output reg[7:0] ascii
    );
 always @* begin
		ascii = 0;
		case(rd_data)
			{1'b1,8'h45}: ascii = 8'h32; //๗
			{1'b1,8'h16}: ascii = 8'h52; //+
			{1'b1,8'h1e}: ascii = 8'h2c; //๑
			{1'b1,8'h26}: ascii = 8'h2d; //๒
			{1'b1,8'h25}: ascii = 8'h2e; //๓
			{1'b1,8'h2e}: ascii = 8'h2f; //๔
			{1'b1,8'h36}: ascii = 8'h3e; //อู
			{1'b1,8'h3d}: ascii = 8'h54; //฿
			{1'b1,8'h3e}: ascii = 8'h30; //๕
			{1'b1,8'h46}: ascii = 8'h31; //๖
			
			{1'b0,8'h1c}: ascii = 8'h1e; //ฟ
			{1'b0,8'h32}: ascii = 8'h39; //อิ
			{1'b0,8'h21}: ascii = 8'h41; //แ
			{1'b0,8'h23}: ascii = 8'h00; //ก
			{1'b0,8'h24}: ascii = 8'h43; //อำ
			{1'b0,8'h2b}: ascii = 8'h13; //ด
			{1'b0,8'h34}: ascii = 8'h40; //เ
			{1'b0,8'h33}: ascii = 8'h4b; //อ้
			{1'b0,8'h43}: ascii = 8'h22; //ร
			{1'b0,8'h3b}: ascii = 8'h4a; //อ่
			{1'b0,8'h42}: ascii = 8'h38; //า
			{1'b0,8'h4b}: ascii = 8'h27; //ส
			{1'b0,8'h3a}: ascii = 8'h16; //ท
			{1'b0,8'h31}: ascii = 8'h3c; //อื
			{1'b0,8'h44}: ascii = 8'h18; //น
			{1'b0,8'h4d}: ascii = 8'h21; //ย
			{1'b0,8'h15}: ascii = 8'h46; //ๆ
			{1'b0,8'h2d}: ascii = 8'h1d; //พ
			{1'b0,8'h1b}: ascii = 8'h28; //ห
			{1'b0,8'h2c}: ascii = 8'h36; //ะ
			{1'b0,8'h3c}: ascii = 8'h3a; //อี
			{1'b0,8'h2a}: ascii = 8'h2a; //อ
			{1'b0,8'h1d}: ascii = 8'h44; //ไ
			{1'b0,8'h22}: ascii = 8'h1a; //ป
			{1'b0,8'h35}: ascii = 8'h37; //อั
			{1'b0,8'h1a}: ascii = 8'h1b; //ผ

            {1'b1,8'h0e}: ascii = 8'h52; // `
			{1'b1,8'h4e}: ascii = 8'h33; // ๘ 
			{1'b1,8'h55}: ascii = 8'h34; // ๙
			{1'b1,8'h54}: ascii = 8'h0f; // ฐ
			{1'b1,8'h5b}: ascii = 8'h52; // ,
			{1'b1,8'h5d}: ascii = 8'h04; // ฅ
			{1'b1,8'h4c}: ascii = 8'h0a; // ซ
			{1'b1,8'h52}: ascii = 8'h52; // .
			{1'b1,8'h41}: ascii = 8'h11; // ฒ
			{1'b1,8'h49}: ascii = 8'h29; // ฬ
			{1'b1,8'h4a}: ascii = 8'h48; // ฦ

            {1'b0,8'h45}: ascii = 8'h07; //จ
			{1'b0,8'h16}: ascii = 8'h49; //ๅ
			{1'b0,8'h1e}: ascii = 8'h3f; ///
			{1'b0,8'h26}: ascii = 8'h52; //-
			{1'b0,8'h25}: ascii = 8'h1f; //ภ
			{1'b0,8'h2e}: ascii = 8'h15; //ถ
			{1'b0,8'h36}: ascii = 8'h3d; //อุ
			{1'b0,8'h3d}: ascii = 8'h3b; //อึ
			{1'b0,8'h3e}: ascii = 8'h03; //ค
			{1'b0,8'h46}: ascii = 8'h14; //ต
			
			{1'b1,8'h1c}: ascii = 8'h47; //ฤ
			{1'b1,8'h32}: ascii = 8'h51; //อฺ
			{1'b1,8'h21}: ascii = 8'h08; //ฉ
			{1'b1,8'h23}: ascii = 8'h0e; //ฏ
			{1'b1,8'h24}: ascii = 8'h0d; //ฎ
			{1'b1,8'h2b}: ascii = 8'h42; //โ
			{1'b1,8'h34}: ascii = 8'h0b; //ฌ
			{1'b1,8'h33}: ascii = 8'h4e; //อ็
			{1'b1,8'h43}: ascii = 8'h12; //ณ
			{1'b1,8'h3b}: ascii = 8'h4d; //อ๋
			{1'b1,8'h42}: ascii = 8'h26; //ษ
			{1'b1,8'h4b}: ascii = 8'h25; //ศ
			{1'b1,8'h3a}: ascii = 8'h52; //?
			{1'b1,8'h31}: ascii = 8'h4f; //อ์
			{1'b1,8'h44}: ascii = 8'h53; //ฯ
			{1'b1,8'h4d}: ascii = 8'h0c; //ญ
			{1'b1,8'h15}: ascii = 8'h35; //๐
			{1'b1,8'h2d}: ascii = 8'h10; //ฑ
			{1'b1,8'h1b}: ascii = 8'h05; //ฆ
			{1'b1,8'h2c}: ascii = 8'h17; //ธ
			{1'b1,8'h3c}: ascii = 8'h4c; //อ๊
			{1'b1,8'h2a}: ascii = 8'h2b; //ฮ
			{1'b1,8'h1d}: ascii = 8'h52; //"
			{1'b1,8'h22}: ascii = 8'h52; //)
			{1'b1,8'h35}: ascii = 8'h50; //อํ
			{1'b1,8'h1a}: ascii = 8'h52; //(
			
			{1'b0,8'h0e}: ascii = 8'h52; // `
			{1'b0,8'h4e}: ascii = 8'h01; // ข
			{1'b0,8'h55}: ascii = 8'h09; // ช
			{1'b0,8'h54}: ascii = 8'h19; // บ
			{1'b0,8'h5b}: ascii = 8'h23; // ล
			{1'b0,8'h5d}: ascii = 8'h02; // ฃ
			{1'b0,8'h4c}: ascii = 8'h24; // ว
			{1'b0,8'h52}: ascii = 8'h06; // ง
			{1'b0,8'h41}: ascii = 8'h20; // ม
			{1'b0,8'h49}: ascii = 8'h45; // ใ
			{1'b0,8'h4a}: ascii = 8'h1c; // ฝ
			
			{1'b0,8'h29}: ascii = 8'h3f; //space
			{1'b1,8'h29}: ascii = 8'h3f; //space
			{1'b0,8'h5a}: ascii = 8'h3f; //enter
			{1'b1,8'h5a}: ascii = 8'h3f; //enter
			{1'b0,8'h66}: ascii = 8'h3f; //backspace
			{1'b1,8'h66}: ascii = 8'h3f; //backspace
            
			{1'b0,8'h00}: ascii = 8'h3f; // ' '
			default: ascii = 8'h52; //
			
		endcase
	 end

endmodule
