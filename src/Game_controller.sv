`include "params.vh"

module Game_controller(
    input i_clk,
    input i_rst_n,
    input i_board_reload_done,
    
    output [3:0] o_game_state,
    output       o_board_reload
);

reg [3:0] r_state;
reg       r_board_reload;

assign o_game_state = r_state;
assign o_board_reload = r_board_reload;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        r_state <= GS_INIT;
        r_board_reload <= 0;
    end
    else begin
        case (r_state)
            GS_INIT   : begin
                r_board_reload <= 1;
                r_state <= GS_RELOAD;
            end
            GS_IDLE   : begin
                r_state <= r_state;
            end
            GS_RELOAD : begin
                if (i_board_reload_done) begin
                    r_board_reload <= 0;
                    r_state <= GS_IDLE;
                end
                else begin
                    r_state <= r_state;
                end
            end
            default   : begin
                r_state <= r_state;
            end
        endcase
    end
end

endmodule