`include "params.vh"

module Items_controller(
    input        i_clk,
    input        i_rst_n,
    input        i_items_reload,             // i_items_map must be ready when i_items_relaod
    input [1:0]  i_items_map[0:35][0:27],
    input        i_item_eaten,
    input [1:0]  i_item_eaten_type,
    input [5:0]  i_item_x,
    input [5:0]  i_item_y,

    output [1:0] o_items[0:35][0:27],   // 0: none, 1: dot, 2:energizer
    output [7:0] o_dots_counter,
    output [7:0] o_dots_eaten_counter,
    output [3:0] o_energizer_counter
);

reg [1:0] r_items[0:35][0:27];
reg [7:0] r_dots_counter, r_dots_eaten_counter;
reg [3:0] r_energizer_counter;   // 4 bit for tidy
assign w_items = r_items;
assign o_dots_counter = r_dots_counter;
assign o_dots_eaten_counter = r_dots_eaten_counter;
assign o_energizer_counter = r_energizer_counter;

integer i, j;

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        r_items <= '{default:2'd0};
        r_dots_counter <= 0;
        r_dots_eaten_counter <= 0;
        r_energizer_counter <= 0;
    end
    else begin
        if (i_items_reload) begin
            r_items <= i_items_map;
            r_dots_counter <= 8'd220;
            r_dots_eaten_counter <= 0;
            r_energizer_counter <= 0;
        end
        else begin
            if (i_item_eaten) begin
                if (i_item_eaten_type == I_DOT) begin
                    r_dots_counter <= r_dots_counter - 1;
                    r_dots_eaten_counter <= r_dots_eaten_counter + 1;
                end
                else if (i_item_eaten_type == I_ENERGIZER) begin
                    r_energizer_counter <= r_energizer_counter + 1;
                end
                for (i = 0; i < 36; i++) begin
                    for (j = 0; j < 28; j++) begin
                        r_items[i][j] <= ((i_dot_x == i) && (i_dot_y == j)) ? I_NONE : r_items[i][j];
                    end
                end
            end
            else begin
                r_items <= r_items;
            end
        end
    end
end

endmodule