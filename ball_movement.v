`timescale 1ns / 1ps

module ball_movement(
	input clk, //this clock must be a slow enough clock to view the changing positions of the objects
    input rst, 
	input [9:0] hCount, vCount,
	input paddle_on,
	input [9:0] paddle_xpos, paddle_ypos,
	input [55:0] visible,
	output reg [11:0] ball_pixel,
    output reg ball_on, // Output to indicate whether we're on a block pixel
	output reg [3:0] lives,
	output reg [55:0] visible_out,
	output reg [15:0] score
   );

	// wire block_fill; our value is ball_on 
    integer down;
    integer right;
	integer state;

    parameter BLACK = 12'b0000_0000_0000;
	parameter WHITE = 12'b1111_1111_1111;
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;

	parameter num_blocks_x = 14;
    parameter num_blocks_y = 4;
	parameter block_spacing = 5;
	parameter block_width = 40;
    parameter block_height = 20;
	parameter start_x = 152;
    parameter start_y = 150;
	
	//these two values dictate the center of the block, incrementing and decrementing them leads the block to move in certain directions
	reg [9:0] xpos, ypos; // position of center of the block. We will also have a block type thing
    reg[49:0] greenMiddleSquareSpeed; 
    wire greenMiddleSquare;
	reg livesFlag;
	integer block_idx, block_x, block_y;

		//the +-5 for the positions give the dimension of the block (i.e. it will be 10x10 pixels)
    //assign down = 1;
    assign greenMiddleSquare =(vCount>=(ypos-5) && vCount<=(ypos+5) && hCount>=(xpos-5) && hCount<=(xpos+5))?1:0; // dimensions of the block, we will want to make it smaller. 

        // need to put this in the always (clk edge) *****************
	// assign ball_on =(vCount>=(ypos-5) && vCount<=(ypos+5) && hCount>=(xpos-25) && hCount<=(xpos+25))?1:0; // dimensions of the block, we will want to make it smaller. 
	// will this be set to 0 otherwise

    initial begin
		xpos<=450;
		ypos<=700;
		down = 1;
		lives = 3;
		livesFlag = 1;
		visible_out = 56'b11111111111111111111111111111111111111111111111111111111;
        right = 2;
		state = 1;
		score = 15'd0;
		// reset = 1'b0;
	end
	
	always@(posedge clk) 
	begin
		if(rst || (state == 0))
		begin 
			//rough values for center of screen
            visible_out = 56'b11111111111111111111111111111111111111111111111111111111;
            lives = 3;
            right = 2;
			xpos<=450;
			ypos<=700;
            down = 1;
			state = 1;
			score = 15'd0;
		end
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
            if (greenMiddleSquareSpeed >= 50'd750000) //500 thousand
                begin
                    if (down==1) ypos = ypos + 10'd1;
                    else if (down==0) ypos = ypos - 10'd1;
                    if (right ==1) xpos = xpos + 10'd1;
                    else if (right == 0) xpos = xpos - 10'd1;
					// ypos = ypos + 10'd1;
					greenMiddleSquareSpeed = 50'd0; // setting it back to 0 so we can restart the counter
					
					if (ypos+5 >= paddle_ypos - 5 && ypos+5 <= paddle_ypos + 5 && xpos >= paddle_xpos - 9 && xpos <= paddle_xpos + 9)
						begin
							down <= 0;
                            right <= 2;
						end
                    else if (ypos+5 >= paddle_ypos - 5 && ypos+5 <= paddle_ypos + 5 && xpos >= paddle_xpos - 30 && xpos <= paddle_xpos - 10)
                        begin   
                            right <= 0;
                            down <= 0;
                        end
                    else if (ypos+5 >= paddle_ypos - 5 && ypos+5 <= paddle_ypos + 5 && xpos <= paddle_xpos + 30 && xpos >= paddle_xpos + 10)
                    begin   
                        right <= 1;
                        down <= 0;
                    end
					else if ((ypos > paddle_ypos + 8) && livesFlag) 
						begin
							lives <= lives-1;
							livesFlag <= 0;
							down <= 0;	// can we try xpos and ypos resetting
						end			
						if (lives == 0)
						begin
							state = 0;
						end	
					/*else if (ypos == 10'd600)
						begin
							down <= 0;
						end*/
					else if (ypos == 10'd0)
						begin
							down <= 1;
						end
                    else if (xpos >= 800)
                        begin 
                            right <=0;
                        end
                    else if (xpos <= 150)
                        begin
                            right <= 1;
                        end
					if (ypos <= paddle_ypos + 8)
						livesFlag <= 1;

					for (block_idx = 0; block_idx < num_blocks_x * num_blocks_y; block_idx=block_idx+1) 
						begin
							block_x = start_x + (block_idx % num_blocks_x) * (block_width + block_spacing);
							block_y = start_y + (block_idx / num_blocks_x) * (block_height + block_spacing);

							if (visible[block_idx] && xpos >= block_x && xpos < block_x + block_width && ypos >= block_y && ypos < block_y + block_height) 
								begin
									visible_out[block_idx] <= 0; // Block hit
									down <= !down; // Change direction
									score = score + 16'd1;
								end
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
