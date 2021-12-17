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
	input  [9:0]   i_pacman_x,             // 0~479
	input  [9:0]   i_pacman_y,             // 0~639
	input  [9:0]   i_ghost1_x,             // 0~479
	input  [9:0]   i_ghost1_y,             // 0~639
	output [1:0]   o_mem_select,           // MEM_MAP or MEM_CHAR
	output [4:0]   o_address_map,          // TBD
	output [7:0]   o_address_char,         // TBD
    output [5:0]   o_tile_offset,           // for rgb decoder choose which pixel, tile
    output [5:0]   o_char_offset           // for rgb decoder choose which pixel, character
);

wire [2:0] x_offset, y_offset;
assign x_offset = i_x_cord[2:0];
assign y_offset = i_y_cord[2:0];
assign o_tile_offset = x_offset * 8 + y_offset;

wire       overlap_ghost1;
wire [1:0] part_offset_ghost1;
wire [5:0] char_offset_ghost1;

Show_char show_char_ghost1(
    .i_x_cord(i_x_cord),
	.i_y_cord(i_y_cord),
	.i_char_x(i_ghost1_x),
	.i_char_y(i_ghost1_y),     

    .o_overlap(overlap_ghost1),
    .o_part_offset(part_offset_ghost1),
    .o_char_offset(char_offset_ghost1)
);

wire       overlap_pacman;
wire [1:0] part_offset_pacman;
wire [5:0] char_offset_pacman;

Show_char show_char_pacman(
    .i_x_cord(i_x_cord),
	.i_y_cord(i_y_cord),
	.i_char_x(i_pacman_x),
	.i_char_y(i_pacman_y),     

    .o_overlap(overlap_pacman),
    .o_part_offset(part_offset_pacman),
    .o_char_offset(char_offset_pacman)
);

always_comb begin
    if (i_show_en) begin
        if (i_x_cord < 288 & i_y_cord < 224) begin
            // characters
            if (overlap_ghost1) begin
                o_mem_select[1] = 1;
                o_char_offset = char_offset_ghost1;
                o_address_char = 4 + part_offset_ghost1;
            end
            else if (overlap_pacman) begin
                o_mem_select[1] = 1;
                o_char_offset = char_offset_pacman;
                o_address_char = part_offset_pacman;
            end
            else begin
                o_mem_select[1] = 0;
                o_char_offset = 0;
                o_address_char = 0;
            end

            // board
            o_mem_select[0] = 1;
            case (i_map[i_x_cord>>3][i_y_cord>>3])
                TILE_BLANK: begin
                    o_address_map = 0;   // TBD
                end
                TILE_WALL : begin
                    o_address_map = 1;   // TBD
                end
                default   : begin
                    o_address_map = 0;
                end
            endcase
        end
        else begin
            o_mem_select = 2'd0;
            o_address_map = 0;
            o_address_char = 0;
            o_char_offset = 0;
        end
    end
    else begin
        o_mem_select = 2'd0;
        o_address_map = 0;
        o_address_char = 0;
        o_char_offset = 0;
    end
end

endmodule