`include "params.vh"

module Ghost_anime_select(
    input         i_clk,
    input         i_rst_n,

    input  [3:0]  i_which_char,
    input  [3:0]  i_blinky_state,
    input  [3:0]  i_pinky_state,
    input  [3:0]  i_inky_state,
    input  [3:0]  i_clyde_state,
    input  [1:0]  i_pacman_direction,
	input  [1:0]  i_blinky_direction,
	input  [1:0]  i_pinky_direction,
	input  [1:0]  i_inky_direction,
	input  [1:0]  i_clyde_direction,

    output [3:0] o_pacman_pose,
    output [3:0] o_ghost_pose
);

assign o_pacman_pose = i_pacman_direction;

wire [3:0] ghost_state;
wire [1:0] ghost_direction;

always_comb begin
    case (i_which_char)
        4'd1   : begin  // blinky
            ghost_direction = i_blinky_direction;
            ghost_state = i_blinky_state;
        end
        4'd2   : begin  // pinky
            ghost_direction = i_pinky_direction;
            ghost_state = i_pinky_state;
        end
        4'd3   : begin  // inky
            ghost_direction = i_inky_direction;
            ghost_state = i_inky_state;
        end
        4'd4   : begin  // clyde
            ghost_direction = i_clyde_direction;
            ghost_state = i_clyde_state;
        end
        default: begin
            ghost_direction = 0;
            ghost_state = 0;
        end
    endcase
end

always_comb begin
    case (ghost_state)
        G_IDLE       : begin
            o_ghost_pose = ghost_direction << 1;
        end
        G_CHASE      : begin
            o_ghost_pose = ghost_direction << 1;
        end
        G_SCATTER    : begin
            o_ghost_pose = ghost_direction << 1;
        end
        G_FRIGHTENED : begin
            o_ghost_pose = 4'd8;
        end
        G_DIE        : begin
            o_ghost_pose = 4'd12 + ghost_direction;
        end
        default      : begin
            o_ghost_pose = 4'd0;
        end
    endcase
end

endmodule