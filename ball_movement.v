`timescale 1ns / 1ps

module ball_movement(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input [9:0] hCount, vCount,
	input paddle_on,
	output reg [11:0] ball_pixel,
    output reg ball_on // Output to indicate whether we're on a block pixel
   );

	// wire block_fill; our value is ball_on 
    integer down;

    parameter BLACK = 12'b0000_0000_0000;
	parameter WHITE = 12'b1111_1111_1111;
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos; // position of center of the block. We will also have a block type thing
    reg[49:0] greenMiddleSquareSpeed; 
    wire greenMiddleSquare;
	


		//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
    //assign down = 1;
    assign greenMiddleSquare =(vCount>=(ypos-5) && vCount<=(ypos+5) && hCount>=(xpos-5) && hCount<=(xpos+5))?1:0; // dimensions of the block, we will want to make it smaller. 

        // need to put this in the always (clk edge) *****************
	// assign ball_on =(vCount>=(ypos-5) && vCount<=(ypos+5) && hCount>=(xpos-25) && hCount<=(xpos+25))?1:0; // dimensions of the block, we will want to make it smaller. 
	// will this be set to 0 otherwise

    initial begin
		xpos<=450;
		ypos<=514;
		down = 1;
		// score = 15'd0;
		// reset = 1'b0;
	end
	
	always@(posedge clk) 
	begin
		/*if(rst)
		begin 
			//rough values for center of screen
			xpos<=450;
			ypos<=514;
			// score = 15'd0;
		end*/
		if (clk) begin
		
		/* Note that the top left of the screen does NOT correlate to vCount=0 and hCount=0. The display_controller.v file has the 
			synchronizing pulses for both the horizontal sync and the vertical sync begin at vcount=0 and hcount=0. Recall that after 
			the length of the pulse, there is also a short period called the back porch before the display area begins. So effectively, 
			the top left corner corresponds to (hcount,vcount)~(144,35). Which means with a 640x480 resolution, the bottom right corner 
			corresponds to ~(783,515).  
		*/
        	// assign ball_on =(vCount>=(ypos-5) && vCount<=(ypos+5) && hCount>=(xpos-25) && hCount<=(xpos+25))?1:0; // dimensions of the block, we will want to make it smaller. 

            ball_on <= 0;
            greenMiddleSquareSpeed = greenMiddleSquareSpeed + 50'd1;  // this is basically a counter
            if (greenMiddleSquareSpeed >= 50'd500000) //500 thousand
                begin
                    if (down==1) ypos = ypos + 10'd1;
                    else if (down==0) ypos = ypos - 10'd1;
                // ypos = ypos + 10'd1;
                greenMiddleSquareSpeed = 50'd0; // setting it back to 0 so we can restart the counter
                
                if ((greenMiddleSquare == 1) && (paddle_on == 1))
                    down <= 0;
                else if (ypos == 10'd600)
                    begin
                        down <= 0;
                    end
                else if (ypos == 10'd0)
                    begin
                        down <= 1;
                    end
                end
            if (greenMiddleSquare == 1)
                begin
                    ball_pixel = GREEN;
                    ball_on <= 1;
                end



			// if(right) begin
			// 	xpos<=xpos+2; //change the amount you increment to make the speed faster 
			// 	if(xpos==800) //these are rough values to attempt looping around, you can fine-tune them to make it more accurate- refer to the block comment above
			// 		begin
			// 		xpos<=xpos;
			// 		score = score + 16'd1;
			// 		end
			// end
			// else if(left) begin
			// 	xpos<=xpos-2;
			// 	if(xpos==150)
			// 		begin
			// 		xpos<=xpos;
			// 		score = score + 16'd1; // if we hit the boundary should increment the counter, we'll see how this works?
			// 		end 
			// end
			// else if(up) begin
			// 	ypos<=ypos-2;
			// 	if(ypos==34)
			// 		ypos<=514;
			// end
			// else if(down) begin
			// 	ypos<=ypos+2;
			// 	if(ypos==514)
			// 		ypos<=34;
			// end
		end
	end
	
	//the background color reflects the most recent button press
	// always@(posedge clk, posedge rst) begin
	// 	if(rst)
	// 		background <= 12'b1111_1111_1111;
	// 	else 
	// 		if(right)
	// 			background <= 12'b1111_1111_0000;
	// 		else if(left)
	// 			background <= 12'b0000_1111_1111;
	// 		// else if(down)
	// 		// 	background <= 12'b0000_1111_0000;
	// 		// else if(up)
	// 		// 	background <= 12'b0000_0000_1111;
	// end

	
	
endmodule
