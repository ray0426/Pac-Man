`include "params.vh"

module Collision_controller(
    input        i_clk,
    input        i_rst_n,
    input [3:0]  i_game_state,
    input [1:0]  i_items[0:35][0:27],
    input [5:0]  i_pacman_x,
    input [5:0]  i_pacman_y,
    input [5:0]  i_blinky_x,
    input [5:0]  i_blinky_y,
    input [5:0]  i_pinky_x,
    input [5:0]  i_pinky_y,
    input [5:0]  i_inky_x,
    input [5:0]  i_inky_y,
    input [5:0]  i_clyde_x,
    input [5:0]  i_clyde_y,
    input [3:0]  i_blinky_state,
    input [3:0]  i_pinky_state,
    input [3:0]  i_inky_state,
    input [3:0]  i_clyde_state,

    output       o_item_eaten,
    output [1:0] o_item_eaten_type,
    output [5:0] o_item_eaten_x,
    output [5:0] o_item_eaten_y,
    output       o_pacman_eaten,
    output       o_blinky_eaten,
    output       o_pinky_eaten,
    output       o_inky_eaten,
    output       o_clyde_eaten
);

wire w_pacman_eaten_blinky, w_pacman_eaten_pinky, w_pacman_eaten_inky, w_pacman_eaten_clyde;
assign o_pacman_eaten = w_pacman_eaten_blinky | w_pacman_eaten_pinky | 
                        w_pacman_eaten_inky | w_pacman_eaten_clyde;
assign o_item_eaten_x = i_pacman_x;
assign o_item_eaten_y = i_pacman_y;

Collision_controller_each collision_controller_blinky(
    .i_pacman_x(i_pacman_x),
    .i_pacman_y(i_pacman_y),
    .i_ghost_x(i_blinky_x),
    .i_ghost_y(i_blinky_y),
    .i_ghost_state(i_blinky_state),

    .o_pacman_eaten(w_pacman_eaten_blinky),
    .o_ghost_eaten(o_blinky_eaten)
);

Collision_controller_each collision_controller_pinky(
    .i_pacman_x(i_pacman_x),
    .i_pacman_y(i_pacman_y),
    .i_ghost_x(i_pinky_x),
    .i_ghost_y(i_pinky_y),
    .i_ghost_state(i_pinky_state),

    .o_pacman_eaten(w_pacman_eaten_pinky),
    .o_ghost_eaten(o_pinky_eaten)
);

Collision_controller_each collision_controller_inky(
    .i_pacman_x(i_pacman_x),
    .i_pacman_y(i_pacman_y),
    .i_ghost_x(i_inky_x),
    .i_ghost_y(i_inky_y),
    .i_ghost_state(i_inky_state),

    .o_pacman_eaten(w_pacman_eaten_inky),
    .o_ghost_eaten(o_inky_eaten)
);

Collision_controller_each collision_controller_clyde(
    .i_pacman_x(i_pacman_x),
    .i_pacman_y(i_pacman_y),
    .i_ghost_x(i_clyde_x),
    .i_ghost_y(i_clyde_y),
    .i_ghost_state(i_clyde_state),

    .o_pacman_eaten(w_pacman_eaten_clyde),
    .o_ghost_eaten(o_clyde_eaten)
);

integer i, j;

always_comb begin
    if (i_game_state == GS_PLAY) begin
        if (i_items[i_pacman_x][i_pacman_y] == I_DOT) begin
            o_item_eaten = 1;
            o_item_eaten_type = I_DOT;
        end
        else if (i_items[i_pacman_x][i_pacman_y] == I_ENERGIZER) begin
            o_item_eaten = 1;
            o_item_eaten_type = I_ENERGIZER;
        end
        else begin
            o_item_eaten = 0;
            o_item_eaten_type = I_NONE;
        end
    end
    else begin
        o_item_eaten = 0;
        o_item_eaten_type = I_NONE;
    end
end

endmodule