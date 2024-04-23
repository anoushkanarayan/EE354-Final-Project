`timescale 1ns / 1ps
module counter(
    input clk,
    input [15:0] displayNumber,
    input [3:0] displayScore,  // Assumed to fit in one digit (0-7)
    output reg [7:0] anode,    // Corrected to handle 8 separate displays
    output reg [6:0] ssdOut
);

    reg [20:0] refresh;
    reg [3:0] LEDNumber;
    wire [2:0] LEDCounter;

    always @ (posedge clk) begin
        refresh <= refresh + 21'd1;
    end

    assign LEDCounter = refresh[20:17];

    always @ (*) begin
        case (LEDCounter)
        3'b000: begin
            anode = 8'b11111110; 
            if (displayNUmber==56) begin
                ssdOut = 7'b1001000;  //Y
            end else begin
                LEDNumber = displayNumber / 1000;
            end
        end
        3'b001: begin
            anode = 8'b11111101; 
            if (displayNUmber==56) begin
                ssdOut = 7'b0001000; //A
            end else begin
                LEDNumber = (displayNumber % 1000) / 100;  
            end
        end
        3'b010: begin
            anode = 8'b11111011; 
            if (displayNUmber==56) begin
                ssdOut = 7'b1001000;  //Y
            end else begin
                LEDNumber = (displayNumber % 100) / 10; 
            end
        end
        3'b011: begin
            anode = 8'b11110111; 
            LEDNumber = displayNumber % 10;
        end
        3'b100: begin
            anode = 8'b11101111; 
            LEDNumber = displayScore; 
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
        default: ssdOut = 7'b1111111; // Clear or off state
        endcase
    end
endmodule
