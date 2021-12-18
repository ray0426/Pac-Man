module Test_show_pacman(
    input        i_clk,
    input        i_rst_n,
    input        i_up,
    input        i_down,
    input        i_left,
    input        i_right,
    output [9:0] w_pacman_x,
    output [9:0] w_pacman_y
);

reg [9:0] r_x, r_y;
assign w_pacman_x = r_x;
assign w_pacman_y = r_y;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        r_x <= 0;
        r_y <= 0;
    end
    else begin
        if (i_left & (r_x > 0)) begin
            r_x <= r_x - 1;
            r_y <= r_y;
        end
        else if (i_right & (r_x < 479)) begin
            r_x <= r_x + 1;
            r_y <= r_y;
        end
        else if (i_up & (r_y > 0)) begin
            r_x <= r_x;
            r_y <= r_y - 1;
        end
        else if (i_down & (r_y < 639)) begin
            r_x <= r_x;
            r_y <= r_y + 1;
        end
        else begin
            r_x <= r_x;
            r_y <= r_y;
        end
    end
end

endmodule