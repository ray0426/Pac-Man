module Board_controller(
	input        i_clk,
    input        i_rst_n,

	input        i_reload,
	output       o_reload_done,
    output [7:0] o_board[0:35][0:27]
);

reg [7:0] board_r[0:35][0:27];
reg [7:0] board_w[0:35][0:27];
reg [9:0] counter_r, counter_w;
reg       state_r, state_w;
reg       reload_done_r, reload_done_w;
assign o_reload_done = reload_done_r;

enum {
	S_IDLE,
	S_RELOAD
} STATES;

// input	[9:0]  address;
// input	  clock;
// input	[7:0]  data;
// input	  wren;
// output	[7:0]  q;

wire [9:0] w_address;
wire [7:0] empty_data;
wire       never_write;
wire [7:0] w_data;
assign w_address = counter_r;
assign empty_data = 8'b0;
assign never_write = 1'b0;

Board_Ram board_ram(
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
			board_w[i][j] = ((state_r == S_RELOAD) & ((i * 28 + j) == counter_r - 1)) ? w_data : board_r[i][j];
		end
	end
end

always_comb begin
	for (i = 0; i < 36; i = i + 1) begin
		for (j = 0; j < 28; j = j + 1) begin
			o_board[i][j] = board_r[i][j];
		end
	end
end

always_comb begin
	case (state_r)
		S_IDLE: begin
			if (i_reload) begin
				counter_w = 0;
				state_w = S_RELOAD;
				reload_done_w = 0;
			end
			else begin
				counter_w = counter_r;
				state_w = state_r;
				reload_done_w = 0;
			end
		end
		S_RELOAD: begin
			if (counter_r == 1009) begin
				counter_w = 0;
				state_w = S_IDLE;
				reload_done_w = 1;
			end
			else begin
				counter_w = counter_r + 1;
				state_w = state_r;
				reload_done_w = reload_done_r;
			end
		end
		default: begin
			counter_w = counter_r;
			state_w = state_r;
			reload_done_w = reload_done_r;
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (~i_rst_n) begin
		state_r <= S_IDLE;
		board_r <= '{default:8'd0};
		counter_r <= 10'd0;
		reload_done_r <= 0;
	end	
	else begin
		state_r <= state_w;
		board_r <= board_w;
		counter_r <= counter_w;
		reload_done_r <= reload_done_w;
	end
end

endmodule