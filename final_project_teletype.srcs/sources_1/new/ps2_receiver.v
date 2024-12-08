`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.12.2024 14:46:01
// Design Name: 
// Module Name: ps2_receiver
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


module ps2_receiver(
    input clk, // Basys 3 100MHz Clock
    input reset,
    input kb_clk, // Keyboard Port clock = PS2 Clock
    input kb_data, // Keyboard Port data = PS2 Data
    output reg [15:0] keycode = 0, // Output Data
    output reg flag_out // Signal when finish receive
    );
    
    wire kb_clk_stable, kb_data_stable;
    reg [7:0] data_current = 0;
    reg [7:0] data_prev = 0;
    reg [3:0] count = 0;
    reg flag_current = 0;
    reg flag_prev;
   
    // Debounce PS/2 Port Signal
    debouncer #(.COUNT_MAX(19), .COUNT_WIDTH(5)) debouncer_clk
    (
        .clk(clk),
        .bit_in(kb_clk),
        .bit_out(kb_clk_stable)
    );
    debouncer #(.COUNT_MAX(19), .COUNT_WIDTH(5)) debouncer_data
    (
        .clk(clk),
        .bit_in(kb_data),
        .bit_out(kb_data_stable)
    );
        
    always@(negedge kb_clk_stable, posedge reset) begin
        if (reset) begin
            data_current <= 0;
            flag_current <= 1'b0;
            count <= 0;
        end else begin
            case(count)
            0:; //Start bit
            1:data_current[0] <= kb_data_stable;
            2:data_current[1] <= kb_data_stable;
            3:data_current[2] <= kb_data_stable;
            4:data_current[3] <= kb_data_stable;
            5:data_current[4] <= kb_data_stable;
            6:data_current[5] <= kb_data_stable;
            7:data_current[6] <= kb_data_stable;
            8:data_current[7] <= kb_data_stable;
            9:flag_current <= 1'b1; // Finish receive data
            10:flag_current <= 1'b0; // Clear signal
            endcase
            // count to 10
            if(count<=9) begin 
                count<=count+1;
            end
            else if(count==10) begin
                count <= 0;
            end
        end
    end

    always@(posedge clk, posedge reset) begin
        if(reset) begin
            keycode <= 0;
            flag_out <= 1'b0;
        end
        else begin
            // if flag change from 0 -> 1 = Data ready
            if (flag_current == 1'b1 && flag_prev == 1'b0) begin
                // send both current and previous keycode
                keycode <= {data_prev, data_current};
                flag_out <= 1'b1;
                data_prev <= data_current;
            end else
                flag_out <= 1'b0;
            flag_prev <= flag_current;
        end
    end

endmodule