`timescale 1ns / 1ps
module counter(
    input clk,
    input [15:0] displayNumber,
    input [1:0] displayScore,  // Assumed to fit in one digit (0-7)
    output reg [7:0] anode,    // Corrected to handle 8 separate displays
    output reg [6:0] ssdOut
);

    reg [20:0] refresh;
    reg [4:0] LEDNumber;
    wire [2:0] LEDCounter;

    always @ (posedge clk) begin
        refresh <= refresh + 21'd1;
    end

    assign LEDCounter = refresh[20:17];

    always @ (*) begin
        case (LEDCounter)
        3'b000: begin
            anode = 8'b11111110; 
            LEDNumber = displayNumber % 10;
        end
        3'b001: begin
            anode = 8'b11111101; 
            LEDNumber = (displayNumber % 100) / 10; 
        end
        3'b010: begin
            anode = 8'b11111011; 
            LEDNumber = (displayNumber % 1000) / 100;  
        end
        3'b011: begin
            anode = 8'b11110111; 
            LEDNumber = displayScore; 
        end
        3'b100: begin
            anode = 8'b11101111; 
            if (displayScore==0) begin
                LEDNumber = 15;  //E
            end  
            else
                LEDNumber = 16;
        end
        3'b101: begin
            anode = 8'b11011111; 
            if (displayNumber==56) begin
                LEDNumber = 10;  //Y
            end else if (displayScore==0) begin
                LEDNumber = 14;  //S
            end 
            else
                LEDNumber = 16;
        end
        3'b110: begin
            anode = 8'b10111111; 
            if (displayNumber==56) begin
                LEDNumber = 11;  //A
            end else if (displayScore==0) begin
                LEDNumber = 13;  //O
            end
            else
                LEDNumber = 16;
        end
        3'b111: begin
            anode = 8'b01111111; 
            if (displayNumber==56) begin
                LEDNumber = 10;  //Y
            end else if (displayScore==0) begin
                LEDNumber = 12;  //L
            end
            else
                LEDNumber = 16;
        end
        default: begin
            anode = 8'b11111111; // Turn off all displays in other states
        end
        endcase
    end

    always @ (*) begin
        case (LEDNumber)
        0: ssdOut = 7'b0000001; // 0
        1: ssdOut = 7'b1001111; // 1
        2: ssdOut = 7'b0010010; // 2
        3: ssdOut = 7'b0000110; // 3
        4: ssdOut = 7'b1001100; // 4
        5: ssdOut = 7'b0100100; // 5
        6: ssdOut = 7'b0100000; // 6
        7: ssdOut = 7'b0001111; // 7
        8: ssdOut = 7'b0001111; // 7
        9: ssdOut = 7'b0001111; // 7
        10: ssdOut = 7'b1000100; // Y
        11: ssdOut = 7'b0001000; // A
        12: ssdOut = 7'b1110001; // L
        13: ssdOut = 7'b0000001; // O
        14: ssdOut = 7'b0100100; // S
        15: ssdOut = 7'b0110000; // E
        default: ssdOut = 7'b1111111; // Clear or off state
        endcase
    end
endmodule
