`include "params.vh"

module Ghost_controller_each(
    input        i_clk,
    input        i_rst_n,
    input [7:0]  i_game_state,
    input [3:0]  i_ghost_state,
    input        i_ghost_reload,
    input        i_eaten,
    input        i_returned,

    output [3:0] o_state
);

reg [3:0] r_state;
assign o_state = r_state;

reg r_revived;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        r_state <= G_IDLE;
        r_revived <= 0;
    end
    else begin
        if (i_game_state == GS_PLAY || i_game_state == GS_PAUSE || 
            i_game_state == GS_IDLE || i_game_state == GS_RELOAD) begin
            case (r_state)
                G_IDLE       : begin
                    if (i_ghost_reload) begin
                        r_state <= G_CHASE;
                        r_revived <= 0;
                    end
                    else begin
                        r_state <= r_state;
                    end
                end
                G_CHASE      : begin
                    if (i_ghost_state == FRIGHTENED && r_revived == 0) begin
                        r_state <= G_FRIGHTENED;
                    end
                    else if (i_ghost_state == G_CHASE) begin
                        r_state <= G_CHASE;
                        r_revived <= 0;
                    end
                    else if (i_ghost_state == SCATTER) begin
                        r_state <= G_SCATTER;
                        r_revived <= 0;
                    end
                    else begin
                        r_state <= r_state;
                    end
                end
                G_SCATTER    : begin
                    if (i_ghost_state == FRIGHTENED && r_revived == 0) begin
                        r_state <= G_FRIGHTENED;
                    end
                    else if (i_ghost_state == CHASE) begin
                        r_state <= G_CHASE;
                        r_revived <= 0;
                    end
                    else if (i_ghost_state == SCATTER) begin
                        r_state <= G_SCATTER;
                        r_revived <= 0;
                    end
                    else begin
                        r_state <= r_state;
                    end
                end
                G_FRIGHTENED : begin
                    if (i_ghost_state == CHASE) begin
                        r_state <= G_CHASE;
                    end
                    else if (i_ghost_state == SCATTER) begin
                        r_state <= G_SCATTER;
                    end
                    else if (i_eaten) begin
                        r_state <= G_DIE;
                    end
                    else begin
                        r_state <= r_state;
                    end
                end
                G_DIE        : begin
                    if (i_returned) begin
                        r_revived <= 1;
                        if (i_ghost_state == CHASE) begin
                            r_state <= G_CHASE;
                        end
                        else if (i_ghost_state == SCATTER) begin
                            r_state <= G_SCATTER;
                        end
                        else begin
                            r_state <= G_CHASE;
                        end
                    end
                    else begin
                        r_state <= r_state;
                    end
                end
                default      : begin
                    r_state <= r_state;
                end
            endcase
        end
        else if (i_game_state == GS_CLEAR || i_game_state == GS_GAMEOVER) begin
            r_state <= G_IDLE;
        end
        else begin
            r_state <= G_IDLE;
        end
    end
end

endmodule