`include "params.vh"

module Char_color_decoder(
    input  [3:0] i_which_char,
    input  [1:0] i_data_ghost,
    input        i_data_pacman,
    output [3:0] o_data_ghost_process,
    output [3:0] o_data_pacman_process
);

assign o_data_pacman_process = (i_data_pacman == 1) ? COLOR_YELLOW : COLOR_BLACK;

wire [3:0] body;

always_comb begin
    case (i_which_char)
        4'd1   : begin  // blinky
            body = COLOR_RED;
        end
        4'd2   : begin  // pinky
            body = COLOR_PINK;
        end
        4'd3   : begin  // inky
            body = COLOR_LBLUE;
        end
        4'd4   : begin  // clyde
            body = COLOR_ORANGE;
        end
        default: begin
            body = COLOR_WHITE;
        end
    endcase
end

always_comb begin
    case (i_data_ghost)
        4'd0   : begin
            o_data_ghost_process = COLOR_BLACK;
        end
        4'd1   : begin
            o_data_ghost_process = COLOR_BLUE;
        end
        4'd2   : begin
            o_data_ghost_process = COLOR_WHITE;
        end
        4'd3   : begin
            o_data_ghost_process = body;
        end
        default: begin
            o_data_ghost_process = COLOR_WHITE;
        end
    endcase
end

endmodule