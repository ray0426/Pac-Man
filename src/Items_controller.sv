`include "params.vh"

module Items_controller(
    input        i_clk,
    input        i_rst_n,
    input        i_items_reload,             // i_items_map must be ready when i_items_relaod
    input        i_item_eaten,
    input [1:0]  i_item_eaten_type,
    input [5:0]  i_item_x,
    input [5:0]  i_item_y,

    output       o_reload_done,
    output [1:0] o_items[0:35][0:27],   // 0: none, 1: dot, 2:energizer
    output [7:0] o_dots_counter,
    output [7:0] o_dots_eaten_counter,
    output [3:0] o_energizer_counter
);

reg       r_state;
reg [1:0] items_w[0:35][0:27];
reg [1:0] items_r[0:35][0:27];
reg [7:0] r_dots_counter, r_dots_eaten_counter;
reg [3:0] r_energizer_counter;   // 4 bit for tidy
reg [9:0] r_counter;
reg       r_reload_done;
assign o_dots_counter = r_dots_counter;
assign o_dots_eaten_counter = r_dots_eaten_counter;
assign o_energizer_counter = r_energizer_counter;
assign o_reload_done = r_reload_done;

enum {
    S_IDLE,
    S_RELOAD
} STATES;

wire [9:0] w_address;
wire [7:0] empty_data;
wire       never_write;
wire [1:0] w_data;
assign w_address = r_counter;
assign empty_data = 1'b0;
assign never_write = 1'b0;

Item_Ram item_ram(
	.address(w_address),
	.clock(~i_clk),   // usage of ram
	.data(empty_data),
	.wren(never_write),
	.q(w_data)
);

integer i, j;

always_comb begin
	for (i = 0; i < 36; i = i + 1) begin
		for (j = 0; j < 28; j = j + 1) begin
			items_w[i][j] = ((r_state == S_RELOAD) & ((i * 28 + j) == r_counter - 1)) ? w_data : items_r[i][j];
		end
	end
end

always_comb begin
	for (i = 0; i < 36; i = i + 1) begin
		for (j = 0; j < 28; j = j + 1) begin
			o_items[i][j] = items_r[i][j];
		end
	end
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        r_state <= S_IDLE;
        items_r <= '{default:2'd0};
        r_dots_counter <= 0;
        r_dots_eaten_counter <= 0;
        r_energizer_counter <= 0;
        r_counter <= 0;
        r_reload_done <= 0;
    end
    else begin
        case (r_state)
            S_IDLE: begin
                if (i_items_reload) begin
                    r_state <= S_RELOAD;
                    r_dots_counter <= 8'd220;
                    r_dots_eaten_counter <= 0;
                    r_energizer_counter <= 0;
                    r_reload_done <= 0;
                    r_counter <= 0;
                end
                else begin
                    r_reload_done <= 0;
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
                                items_r[i][j] <= ((i_item_x == i) && (i_item_y == j)) ? I_NONE : items_r[i][j];
                            end
                        end
                    end
                    else begin
                        items_r <= items_r;
                    end
                end
            end
            S_RELOAD: begin
                if (r_counter == 1009) begin
                    items_r <= items_w;
                    r_counter <= 0;
                    r_state <= S_IDLE;
                    r_reload_done <= 1;
                end
                else begin
                    items_r <= items_w;
                    r_counter <= r_counter + 1;
                    r_state <= r_state;
                    r_reload_done <= r_reload_done;
                end
            end
            default: begin
                r_counter <= r_counter;
                r_state <= r_state;
                r_reload_done <= r_reload_done;
            end
        endcase

    end
end

endmodule