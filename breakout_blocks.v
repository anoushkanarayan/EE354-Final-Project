`timescale 1ns / 1ps

module breakout_blocks(
    input clk,
    input [9:0] hCount, // Horizontal pixel count from the display_controller
    input [9:0] vCount, // Vertical pixel count from the display_controller
    output reg block_on, // Output to indicate whether we're on a block pixel
    output reg [11:0] color // Output color based on block state
    );

    // Parameters for block size and positioning
    parameter block_width = 40;
    parameter block_height = 20;
    parameter num_blocks_x = 10;
    parameter num_blocks_y = 4; // Adjusted to fill top third of the screen
    parameter block_spacing = 5; // Spacing between blocks
    parameter start_x = 50; // X position to start drawing blocks
    parameter start_y = 30; // Y position to start drawing blocks

    // Colors for the blocks
    parameter BLACK = 12'b0000_0000_0000;
    parameter WHITE = 12'b1111_1111_1111;
    parameter RED   = 12'b1111_0000_0000;
    parameter GREEN = 12'b0000_1111_0000;

    // Calculate the end positions dynamically based on start and number of blocks
    integer end_x = start_x + num_blocks_x * (block_width + block_spacing) - block_spacing;
    integer end_y = start_y + num_blocks_y * (block_height + block_spacing) - block_spacing;

    // Generate signal for block visibility and assign color
    always @(posedge clk) begin
        block_on <= 0;
        color <= BLACK;

        if ((hCount >= start_x && hCount < end_x) && (vCount >= start_y && vCount < end_y)) begin
            // Calculate the current row and column
            integer current_row = (vCount - start_y) / (block_height + block_spacing);
            integer current_col = (hCount - start_x) / (block_width + block_spacing);

            // Check if the current pixel is within a block (excluding spacing)
            if (((hCount - start_x) % (block_width + block_spacing)) < block_width &&
                ((vCount - start_y) % (block_height + block_spacing)) < block_height) begin
                block_on <= 1;
                // Assign color alternately for each row
                if (current_row % 2 == 0) color <= RED;
                else color <= GREEN;
                end
        end
    end

endmodule

