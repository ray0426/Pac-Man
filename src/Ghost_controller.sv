`include "params.vh"

module Ghost_controller(
    input        i_clk,
    input        i_rst_n,
    input [7:0]  i_game_state,
    input        i_ghost_reload,
    input        i_energizers_eaten,   // 大力丸   tbd
    input        i_blinky_eaten,
    input        i_pinky_eaten,
    input        i_inky_eaten,
    input        i_clyde_eaten,
    input        i_blinky_returned,
    input        i_pinky_returned,
    input        i_inky_returned,
    input        i_clyde_returned,

    output [3:0] o_blinky_state,
    output [3:0] o_pinky_state,
    output [3:0] o_inky_state,
    output [3:0] o_clyde_state,
);

reg [3:0]  r_ghost_state, r_ghost_state_prev;  // for chase and scatter and general frighten
reg [31:0] r_counter, r_counter_fri;

Ghost_controller_each ghost_controller_blinky(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_game_state(i_game_state),
    .i_ghost_state(r_ghost_state),
    .i_ghost_reload(i_ghost_reload),
    .i_eaten(i_blinky_eaten),
    .i_returned(i_blinky_returned),

    .o_state(o_blinky_state)
);

Ghost_controller_each ghost_controller_pinky(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_game_state(i_game_state),
    .i_ghost_state(r_ghost_state),
    .i_ghost_reload(i_ghost_reload),
    .i_eaten(i_pinky_eaten),
    .i_returned(i_pinky_returned),

    .o_state(o_pinky_state)
);

Ghost_controller_each ghost_controller_inky(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_game_state(i_game_state),
    .i_ghost_state(r_ghost_state),
    .i_ghost_reload(i_ghost_reload),
    .i_eaten(i_inky_eaten),
    .i_returned(i_inky_returned),

    .o_state(o_inky_state)
);

Ghost_controller_each ghost_controller_clyde(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_game_state(i_game_state),
    .i_ghost_state(r_ghost_state),
    .i_ghost_reload(i_ghost_reload),
    .i_eaten(i_clyde_eaten),
    .i_returned(i_clyde_returned),

    .o_state(o_clyde_state)
);

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        r_ghost_state <= CHASE;
        r_ghost_state_prev <= CHASE;
        r_counter <= 0;
        r_counter_fri <= 0;
    end
    else begin
        if (i_ghost_reload) begin
            r_counter <= 0;
            r_ghost_state <= CHASE;
            r_ghost_state_prev <= CHASE;
        end
        else begin
            case (r_ghost_state)
                CHASE      : begin
                    if (i_energizers_eaten) begin
                        r_ghost_state <= FRIGHTENED;
                        r_ghost_state_prev <= CHASE;
                        r_counter_fri <= 0;
                    end
                    else if (r_counter == 350000000) begin
                        r_ghost_state <= SCATTER;
                        r_counter <= 0;
                    end
                    else begin
                        r_ghost_state <= r_ghost_state;
                        r_counter <= r_counter + 1;
                    end
                end
                SCATTER    : begin
                    if (i_energizers_eaten) begin
                        r_ghost_state <= FRIGHTENED;
                        r_ghost_state_prev <= SCATTER;
                        r_counter_fri <= 0;
                    end
                    else if (r_counter == 1000000000) begin
                        r_ghost_state <= CHASE;
                        r_counter <= 0;
                    end
                    else begin
                        r_ghost_state <= r_ghost_state;
                        r_counter <= r_counter + 1;
                    end
                end
                FRIGHTENED : begin
                    if (r_counter_fri == 500000000) begin
                        r_ghost_state <= r_ghost_state_prev;
                        r_counter_fri <= 0;
                    end
                    else begin
                        r_ghost_state <= r_ghost_state;
                        r_counter_fri <= r_counter_fri + 1;
                    end
                end
                default    : begin
                    r_ghost_state <= r_ghost_state;
                    r_ghost_state_prev <= r_ghost_state_prev;
                    r_counter_fri <= r_counter_fri;
                    r_counter <= r_counter;
                end
            endcase
        end
    end
end

endmodule







    // input i_binky_die,
    // input i_pinky_die,
    // input i_inky_die,
    // input i_clyde_die,