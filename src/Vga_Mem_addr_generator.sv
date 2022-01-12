// this module will input pixel coordinate from vga controller(VGA), 
// map, pacman, ghost coordinate, and output corresponding memory selector
// and address

`include "params.vh"

module Vga_Mem_addr_generator(
    input          i_clk,
	input          i_rst_n,
	input          i_show_en,
	input  [9:0]   i_x_cord,               // 0~479
	input  [9:0]   i_y_cord,               // 0~639
	input  [7:0]   i_map[0:35][0:27],      // a 2D array rows=36, cols=28 and each 8-bit wide
    input  [1:0]   i_items[0:35][0:27],    // a 2D array rows=36, cols=28 and each 2-bit wide
	input  [9:0]   i_pacman_x,             // 0~479
	input  [9:0]   i_pacman_y,             // 0~639
	// input  [9:0]   i_ghost1_x,             // 0~479
	// input  [9:0]   i_ghost1_y,             // 0~639
    input  [9:0]   i_blinky_x,
	input  [9:0]   i_blinky_y,
	input  [9:0]   i_pinky_x,
	input  [9:0]   i_pinky_y,
	input  [9:0]   i_inky_x,
	input  [9:0]   i_inky_y,
	input  [9:0]   i_clyde_x,
	input  [9:0]   i_clyde_y,

	output [1:0]   o_mem_select,           // MEM_MAP or MEM_CHAR
	output [7:0]   o_address_map,          // TBD
	output [3:0]   o_which_char,         // TBD
    output [1:0]   o_address_item,
    output [5:0]   o_tile_offset,          // for rgb decoder choose which pixel, tile
    output [7:0]   o_char_offset           // for rgb decoder choose which pixel, character
);

wire [2:0] x_offset, y_offset;
assign x_offset = i_x_cord[2:0];
assign y_offset = i_y_cord[2:0];
assign o_tile_offset = x_offset * 8 + y_offset;

wire       overlap_blinky,     overlap_pinky,     overlap_inky,     overlap_clyde;
wire [7:0] char_offset_blinky, char_offset_pinky, char_offset_inky, char_offset_clyde;

Show_char show_char_blinky(
    .i_x_cord(i_x_cord),
	.i_y_cord(i_y_cord),
	.i_char_x(i_blinky_x),
	.i_char_y(i_blinky_y),     

    .o_overlap(overlap_blinky),
    .o_char_offset(char_offset_blinky)
);

Show_char show_char_pinky(
    .i_x_cord(i_x_cord),
	.i_y_cord(i_y_cord),
	.i_char_x(i_pinky_x),
	.i_char_y(i_pinky_y),     

    .o_overlap(overlap_pinky),
    .o_char_offset(char_offset_pinky)
);

Show_char show_char_inky(
    .i_x_cord(i_x_cord),
	.i_y_cord(i_y_cord),
	.i_char_x(i_inky_x),
	.i_char_y(i_inky_y),     

    .o_overlap(overlap_inky),
    .o_char_offset(char_offset_inky)
);

Show_char show_char_clyde(
    .i_x_cord(i_x_cord),
	.i_y_cord(i_y_cord),
	.i_char_x(i_clyde_x),
	.i_char_y(i_clyde_y),     

    .o_overlap(overlap_clyde),
    .o_char_offset(char_offset_clyde)
);

wire       overlap_pacman;
wire [7:0] char_offset_pacman;

Show_char show_char_pacman(
    .i_x_cord(i_x_cord),
	.i_y_cord(i_y_cord),
	.i_char_x(i_pacman_x),
	.i_char_y(i_pacman_y),     

    .o_overlap(overlap_pacman),
    .o_char_offset(char_offset_pacman)
);

always_comb begin
    if (i_show_en) begin
        if (i_x_cord < 288 & i_y_cord < 224) begin
            // characters
            if (overlap_blinky) begin
                o_mem_select[1] = 1;
                o_char_offset = char_offset_blinky;
                o_which_char = 1;
            end
            else if (overlap_pinky) begin
                o_mem_select[1] = 1;
                o_char_offset = char_offset_pinky;
                o_which_char = 2;
            end
            else if (overlap_inky) begin
                o_mem_select[1] = 1;
                o_char_offset = char_offset_inky;
                o_which_char = 3;
            end
            else if (overlap_clyde) begin
                o_mem_select[1] = 1;
                o_char_offset = char_offset_clyde;
                o_which_char = 4;
            end
            else if (overlap_pacman) begin
                o_mem_select[1] = 1;
                o_char_offset = char_offset_pacman;
                o_which_char = 0;
            end
            else begin
                o_mem_select[1] = 0;
                o_char_offset = 0;
                o_which_char = 0;
            end

            // board
            o_mem_select[0] = 1;
            o_address_map = i_map[i_x_cord>>3][i_y_cord>>3];

            // items
            o_address_item = i_items[i_x_cord>>3][i_y_cord>>3];
            // case (i_map[i_x_cord>>3][i_y_cord>>3])
            //     TILE_BLANK: begin
            //         o_address_map = 0;   // TBD
            //     end
            //     TILE_WALL : begin
            //         o_address_map = 1;   // TBD
            //     end
            //     default   : begin
            //         o_address_map = 0;
            //     end
            // endcase
        end
        else begin
            o_mem_select = 2'd0;
            o_address_map = 0;
            o_which_char = 0;
            o_address_item = 0;
            o_char_offset = 0;
        end
    end
    else begin
        o_mem_select = 2'd0;
        o_address_map = 0;
        o_which_char = 0;
        o_address_item = 0;
        o_char_offset = 0;
    end
end

endmodule