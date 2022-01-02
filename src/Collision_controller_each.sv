module Collision_controller_each(
    input [5:0]  i_pacman_x,
    input [5:0]  i_pacman_y,
    input [5:0]  i_ghost_x,
    input [5:0]  i_ghost_y,
    input [3:0]  i_ghost_state,

    output       o_pacman_eaten,
    output       o_ghost_eaten
);

always_comb begin
    case (i_ghost_state)
        G_IDLE       : begin
            o_pacman_eaten = 0;
            o_ghost_eaten = 0;
        end
        G_CHASE      : begin
            if ((i_pacman_x == i_ghost_x) && (i_pacman_y == i_ghost_y)) begin
                o_pacman_eaten = 1;
                o_ghost_eaten = 0;
            end
            else begin
                o_pacman_eaten = 0;
                o_ghost_eaten = 0;
            end
        end
        G_SCATTER    : begin
            if ((i_pacman_x == i_ghost_x) && (i_pacman_y == i_ghost_y)) begin
                o_pacman_eaten = 1;
                o_ghost_eaten = 0;
            end
            else begin
                o_pacman_eaten = 0;
                o_ghost_eaten = 0;
            end
        end
        G_FRIGHTENED : begin
            if ((i_pacman_x == i_ghost_x) && (i_pacman_y == i_ghost_y)) begin
                o_pacman_eaten = 0;
                o_ghost_eaten = 1;
            end
            else begin
                o_pacman_eaten = 0;
                o_ghost_eaten = 0;
            end
        end
        G_DIE        : begin
            o_pacman_eaten = 0;
            o_ghost_eaten = 0;
        end
        default      : begin
            o_pacman_eaten = 0;
            o_ghost_eaten = 0;
        end
    endcase
end

endmodule