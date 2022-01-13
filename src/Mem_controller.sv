`include "params.vh"

module Mem_controller(
    input        i_clk,
    input        i_rst_n,

    input [1:0]  i_mem_select,
	input [7:0]  i_address_map,
	input [3:0]  i_which_char,
    input [1:0]  i_address_item,
	input [5:0]  i_tile_offset,
	input [7:0]  i_char_offset,

    input [3:0]  i_blinky_state,
    input [3:0]  i_pinky_state,
    input [3:0]  i_inky_state,
    input [3:0]  i_clyde_state,
    input [1:0]  i_pacman_direction,
	input [1:0]  i_blinky_direction,
	input [1:0]  i_pinky_direction,
	input [1:0]  i_inky_direction,
	input [1:0]  i_clyde_direction,

    output [7:0] o_VGA_R,
	output [7:0] o_VGA_G,
	output [7:0] o_VGA_B
);

wire [11:0] w_address_tile;
wire [12:0] w_address_ghost, w_address_pacman;
wire [3:0]  empty_data;
wire        never_write;
wire [3:0]  w_data, w_data_tile, w_data_ghost_process, w_data_pacman_process;
wire [1:0]  w_data_ghost;
wire        w_data_pacman;
assign empty_data = 8'b0000;
assign never_write = 1'b0;
assign w_data = (i_mem_select[1] == 0) ? w_data_tile : ((i_which_char == 0) ? w_data_pacman_process : w_data_ghost_process);

// input	[11:0]  address;
// input	  clock;
// input	[3:0]  data;
// input	  wren;
// output	[3:0]  q;

Tileset_Ram tileset_ram(
	.address(w_address_tile),
	.clock(~i_clk),   // usage of ram
	.data(empty_data),
	.wren(never_write),
	.q(w_data_tile)
);

wire [3:0] w_pacman_pose;
wire [3:0] w_ghost_pose;

Ghost_anime_select ghost_anime_select(  // to be do
    .i_clk(CLOCK_50),
	.i_rst_n(i_rst_n),

    .i_which_char(i_which_char),
    .i_blinky_state(i_blinky_state),
    .i_pinky_state(i_pinky_state),
    .i_inky_state(i_inky_state),
    .i_clyde_state(i_clyde_state),

	.i_pacman_direction(i_pacman_direction),
	.i_blinky_direction(i_blinky_direction),
	.i_pinky_direction(i_pinky_direction),
	.i_inky_direction(i_inky_direction),
	.i_clyde_direction(i_clyde_direction),

    .o_pacman_pose(w_pacman_pose),
    .o_ghost_pose(w_ghost_pose)
);

// Char_Ram
Ghost_Ram ghost_ram(
	.address(w_address_ghost),
	.clock(~i_clk),
	.data(empty_data),
	.wren(never_write),
	.q(w_data_ghost)
);

Pacman_Ram pacman_ram(
	.address(w_address_pacman),
	.clock(~i_clk),
	.data(empty_data),
	.wren(never_write),
	.q(w_data_pacman)
);

Char_color_decoder char_color_decoder(
    .i_which_char(i_which_char),
    .i_data_ghost(w_data_ghost),
    .i_data_pacman(w_data_pacman),
    .o_data_ghost_process(w_data_ghost_process),
    .o_data_pacman_process(w_data_pacman_process)
);

wire [7:0] w_VGA_R;
wire [7:0] w_VGA_G;
wire [7:0] w_VGA_B;

RGB_decoder rgb_decoder(
    .i_data(w_data),
    .o_VGA_R(w_VGA_R),
	.o_VGA_G(w_VGA_G),
	.o_VGA_B(w_VGA_B)
);

wire [63:0] w_energizer;
wire [63:0] w_dot;
assign w_energizer = ENERGIZER;
assign w_dot = DOT;

always_comb begin
    if (i_mem_select == 2'b11) begin
        w_address_tile = 0;
        case (i_which_char)
            4'd0: begin  // pacman
                w_address_ghost = 0;
                w_address_pacman = (w_pacman_pose << 8) + i_char_offset;
            end
            4'd1: begin  // blinky
                w_address_ghost = (w_ghost_pose << 8) + i_char_offset;
                w_address_pacman = 0;
            end
            4'd2: begin  // pinky
                w_address_ghost = (w_ghost_pose << 8) + i_char_offset;
                w_address_pacman = 0;
            end
            4'd3: begin  // inky
                w_address_ghost = (w_ghost_pose << 8) + i_char_offset;
                w_address_pacman = 0;
            end
            4'd4: begin  // clyde
                w_address_ghost = (w_ghost_pose << 8) + i_char_offset;
                w_address_pacman = 0;
            end
            default: begin
                w_address_ghost = 0;
                w_address_pacman = 0;
            end
        endcase
        o_VGA_R = w_VGA_R;
        o_VGA_G = w_VGA_G;
        o_VGA_B = w_VGA_B;
    end
    else if (i_mem_select == 2'b01) begin
        if (i_address_item == I_DOT && 
            // ((i_tile_offset[5:3] == 3) || (i_tile_offset[5:3] == 4)) && 
            // ((i_tile_offset[2:0] == 3) || (i_tile_offset[2:0] == 4))
            w_dot[i_tile_offset] == 1
        ) begin
            w_address_tile = 0;
            w_address_ghost = 0;
            w_address_pacman = 0;
            o_VGA_R = 8'd255;
            o_VGA_G = 8'd255;
            o_VGA_B = 8'd255;
        end
        else if (i_address_item == I_ENERGIZER && 
            w_energizer[i_tile_offset] == 1
        ) begin
            w_address_tile = 0;
            w_address_ghost = 0;
            w_address_pacman = 0;
            o_VGA_R = 8'd255;
            o_VGA_G = 8'd255;
            o_VGA_B = 8'd255;
        end
        else begin
            w_address_tile = i_address_map[5:0] * 64 + i_tile_offset;
            w_address_ghost = 0;
            w_address_pacman = 0;
            o_VGA_R = w_VGA_R;
            o_VGA_G = w_VGA_G;
            o_VGA_B = w_VGA_B;
        end
        // case (i_address_map)
        //     5'd0: begin
        //         o_VGA_R = 8'b00000000;
        //         o_VGA_G = 8'b00000000;
        //         o_VGA_B = 8'b00000000;
        //     end
        //     5'd1: begin
        //         o_VGA_R = 8'b10100110;
        //         o_VGA_G = 8'b10100110;
        //         o_VGA_B = 8'b10100110;
        //     end
        //     default: begin
        //         o_VGA_R = 8'b00000000;
        //         o_VGA_G = 8'b00000000;
        //         o_VGA_B = 8'b11111111;
        //     end
        // endcase
    end
    else begin
        w_address_tile = 0;
        w_address_ghost = 0;
        w_address_pacman = 0;
        o_VGA_R = 8'b11111111;  // for debug, may be 00000000
        o_VGA_G = 8'b11111111;
        o_VGA_B = 8'b11111111;
    end
end

endmodule