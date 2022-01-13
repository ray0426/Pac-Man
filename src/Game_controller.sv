`include "params.vh"

module Game_controller(
    input i_clk,
    input i_rst_n,
    input i_game_start,
    input i_game_pause,
    input i_board_reload_done,
    input i_items_reload_done,
    input i_pacman_eaten,
    input i_dot_clear,
    output [3:0] o_game_state,
    output       o_board_reload,
    output       o_items_reload,
    output       o_ghost_reload,
    output       o_pacman_reload,
    output [7:0] o_level,

    output [3:0] d_lives,

    output [1:0] d_reloads
);

reg [3:0] r_state;
reg       r_ghost_reload;
reg       r_pacman_reload;
reg       r_board_reload;
reg       r_items_reload;
reg [7:0] r_level;
reg [3:0] r_lives;
reg [1:0] r_reloads;     // each bit represent whether a reload is done, board, items

assign o_game_state = r_state;
assign o_board_reload = r_board_reload;
assign o_items_reload = r_items_reload;
assign o_ghost_reload = r_ghost_reload;
assign o_pacman_reload = r_pacman_reload;
assign o_level = r_level;
assign d_lives = r_lives;
assign d_reloads = r_reloads;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        r_state <= GS_IDLE;
        r_board_reload <= 0;
        r_items_reload <= 0;
        r_ghost_reload <= 0;
        r_pacman_reload <= 0;
        r_level <= 1;
        r_lives <= 3;
        r_reloads <= 2'b0;
    end
    else begin
        case (r_state)
            // GS_INIT   : begin
            //     r_board_reload <= 1;
            //     r_state <= GS_RELOAD;
            // end
            GS_IDLE      : begin
                if (i_game_start) begin
                    r_state <= GS_RELOAD;
                    r_board_reload <= 1;
                    r_items_reload <= 1;
                    r_level <= 1;
                    r_lives <= 3;
                    r_reloads <= 2'b0;
                end
                else begin
                    r_state <= r_state;
                end
            end
            GS_RELOAD    : begin
                r_reloads <= {r_reloads[1] | 1, r_reloads[0] | i_items_reload_done};
                if (r_reloads == 2'b11) begin
                    r_board_reload <= 0;
                    r_items_reload <= 0;
                    r_ghost_reload <= 1;
                    r_pacman_reload <= 1;
                    r_state <= GS_PLAY;
                end
                else begin
                    r_state <= r_state;
                end
            end
            GS_PLAY     : begin
                r_ghost_reload <= 0;
                r_pacman_reload <= 0;
                if (i_game_pause) begin
                    r_state <= GS_PAUSE;
                end
                else if (i_pacman_eaten) begin
                    if (r_lives >= 1) begin
                        r_lives <= r_lives - 1;
                        r_state <= r_state;
                        r_pacman_reload <= 1;
                    end
                    else begin
                        r_state <= GS_GAMEOVER;
                    end
                end
                else if (i_dot_clear) begin
                    r_state <= GS_CLEAR;
                end
                else begin
                    r_state <= r_state;
                end
            end
            GS_PAUSE    : begin
                if (i_game_pause) begin
                    r_state <= GS_PLAY;
                end
                else begin
                    r_state <= r_state;
                end
            end
            GS_CLEAR    : begin
                if (i_game_start) begin
                    r_state <= GS_RELOAD;
                    r_reloads <= 2'b0;
                    r_board_reload <= 1;
                    r_items_reload <= 1;
                    r_level <= r_level + 1;
                end
                else begin
                    r_state <= r_state;
                end
            end
            GS_GAMEOVER : begin
                if (i_game_start) begin
                    r_state <= GS_IDLE;
                end
                else begin
                    r_state <= r_state;
                end
            end
            default     : begin
                r_state <= r_state;
            end
        endcase
    end
end

endmodule