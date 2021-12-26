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
	.clock(i_clk),
	.data(empty_data),
	.wren(never_write),
	.q(w_data)
);

integer i, j;

always_comb begin
	for (i = 0; i < 36; i = i + 1) begin
		for (j = 0; j < 28; j = j + 1) begin
			board_w[i][j] = ((state_r == S_RELOAD) & ((i * 28 + j) == counter_r)) ? w_data : board_r[i][j];
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
				reload_done_w = reload_done_r;
			end
		end
		S_RELOAD: begin
			if (counter_w == 1007) begin
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

// assign o_board[0][0]=8'd0;
// assign o_board[0][1]=8'd0;
// assign o_board[0][2]=8'd0;
// assign o_board[0][3]=8'd0;
// assign o_board[0][4]=8'd0;
// assign o_board[0][5]=8'd0;
// assign o_board[0][6]=8'd0;
// assign o_board[0][7]=8'd0;
// assign o_board[0][8]=8'd0;
// assign o_board[0][9]=8'd0;
// assign o_board[0][10]=8'd0;
// assign o_board[0][11]=8'd0;
// assign o_board[0][12]=8'd0;
// assign o_board[0][13]=8'd0;
// assign o_board[0][14]=8'd0;
// assign o_board[0][15]=8'd0;
// assign o_board[0][16]=8'd0;
// assign o_board[0][17]=8'd0;
// assign o_board[0][18]=8'd0;
// assign o_board[0][19]=8'd0;
// assign o_board[0][20]=8'd0;
// assign o_board[0][21]=8'd0;
// assign o_board[0][22]=8'd0;
// assign o_board[0][23]=8'd0;
// assign o_board[0][24]=8'd0;
// assign o_board[0][25]=8'd0;
// assign o_board[0][26]=8'd0;
// assign o_board[0][27]=8'd0;
// assign o_board[1][0]=8'd0;
// assign o_board[1][1]=8'd0;
// assign o_board[1][2]=8'd0;
// assign o_board[1][3]=8'd0;
// assign o_board[1][4]=8'd0;
// assign o_board[1][5]=8'd0;
// assign o_board[1][6]=8'd0;
// assign o_board[1][7]=8'd0;
// assign o_board[1][8]=8'd0;
// assign o_board[1][9]=8'd0;
// assign o_board[1][10]=8'd0;
// assign o_board[1][11]=8'd0;
// assign o_board[1][12]=8'd0;
// assign o_board[1][13]=8'd0;
// assign o_board[1][14]=8'd0;
// assign o_board[1][15]=8'd0;
// assign o_board[1][16]=8'd0;
// assign o_board[1][17]=8'd0;
// assign o_board[1][18]=8'd0;
// assign o_board[1][19]=8'd0;
// assign o_board[1][20]=8'd0;
// assign o_board[1][21]=8'd0;
// assign o_board[1][22]=8'd0;
// assign o_board[1][23]=8'd0;
// assign o_board[1][24]=8'd0;
// assign o_board[1][25]=8'd0;
// assign o_board[1][26]=8'd0;
// assign o_board[1][27]=8'd0;
// assign o_board[2][0]=8'd0;
// assign o_board[2][1]=8'd0;
// assign o_board[2][2]=8'd0;
// assign o_board[2][3]=8'd0;
// assign o_board[2][4]=8'd0;
// assign o_board[2][5]=8'd0;
// assign o_board[2][6]=8'd0;
// assign o_board[2][7]=8'd0;
// assign o_board[2][8]=8'd0;
// assign o_board[2][9]=8'd0;
// assign o_board[2][10]=8'd0;
// assign o_board[2][11]=8'd0;
// assign o_board[2][12]=8'd0;
// assign o_board[2][13]=8'd0;
// assign o_board[2][14]=8'd0;
// assign o_board[2][15]=8'd0;
// assign o_board[2][16]=8'd0;
// assign o_board[2][17]=8'd0;
// assign o_board[2][18]=8'd0;
// assign o_board[2][19]=8'd0;
// assign o_board[2][20]=8'd0;
// assign o_board[2][21]=8'd0;
// assign o_board[2][22]=8'd0;
// assign o_board[2][23]=8'd0;
// assign o_board[2][24]=8'd0;
// assign o_board[2][25]=8'd0;
// assign o_board[2][26]=8'd0;
// assign o_board[2][27]=8'd0;
// assign o_board[3][0]=8'd1;
// assign o_board[3][1]=8'd1;
// assign o_board[3][2]=8'd1;
// assign o_board[3][3]=8'd1;
// assign o_board[3][4]=8'd1;
// assign o_board[3][5]=8'd1;
// assign o_board[3][6]=8'd1;
// assign o_board[3][7]=8'd1;
// assign o_board[3][8]=8'd1;
// assign o_board[3][9]=8'd1;
// assign o_board[3][10]=8'd1;
// assign o_board[3][11]=8'd1;
// assign o_board[3][12]=8'd1;
// assign o_board[3][13]=8'd1;
// assign o_board[3][14]=8'd1;
// assign o_board[3][15]=8'd1;
// assign o_board[3][16]=8'd1;
// assign o_board[3][17]=8'd1;
// assign o_board[3][18]=8'd1;
// assign o_board[3][19]=8'd1;
// assign o_board[3][20]=8'd1;
// assign o_board[3][21]=8'd1;
// assign o_board[3][22]=8'd1;
// assign o_board[3][23]=8'd1;
// assign o_board[3][24]=8'd1;
// assign o_board[3][25]=8'd1;
// assign o_board[3][26]=8'd1;
// assign o_board[3][27]=8'd1;
// assign o_board[4][0]=8'd1;
// assign o_board[4][1]=8'd0;
// assign o_board[4][2]=8'd0;
// assign o_board[4][3]=8'd0;
// assign o_board[4][4]=8'd0;
// assign o_board[4][5]=8'd0;
// assign o_board[4][6]=8'd0;
// assign o_board[4][7]=8'd0;
// assign o_board[4][8]=8'd0;
// assign o_board[4][9]=8'd0;
// assign o_board[4][10]=8'd0;
// assign o_board[4][11]=8'd0;
// assign o_board[4][12]=8'd0;
// assign o_board[4][13]=8'd1;
// assign o_board[4][14]=8'd1;
// assign o_board[4][15]=8'd0;
// assign o_board[4][16]=8'd0;
// assign o_board[4][17]=8'd0;
// assign o_board[4][18]=8'd0;
// assign o_board[4][19]=8'd0;
// assign o_board[4][20]=8'd0;
// assign o_board[4][21]=8'd0;
// assign o_board[4][22]=8'd0;
// assign o_board[4][23]=8'd0;
// assign o_board[4][24]=8'd0;
// assign o_board[4][25]=8'd0;
// assign o_board[4][26]=8'd0;
// assign o_board[4][27]=8'd1;
// assign o_board[5][0]=8'd1;
// assign o_board[5][1]=8'd0;
// assign o_board[5][2]=8'd1;
// assign o_board[5][3]=8'd1;
// assign o_board[5][4]=8'd1;
// assign o_board[5][5]=8'd1;
// assign o_board[5][6]=8'd0;
// assign o_board[5][7]=8'd1;
// assign o_board[5][8]=8'd1;
// assign o_board[5][9]=8'd1;
// assign o_board[5][10]=8'd1;
// assign o_board[5][11]=8'd1;
// assign o_board[5][12]=8'd0;
// assign o_board[5][13]=8'd1;
// assign o_board[5][14]=8'd1;
// assign o_board[5][15]=8'd0;
// assign o_board[5][16]=8'd1;
// assign o_board[5][17]=8'd1;
// assign o_board[5][18]=8'd1;
// assign o_board[5][19]=8'd1;
// assign o_board[5][20]=8'd1;
// assign o_board[5][21]=8'd0;
// assign o_board[5][22]=8'd1;
// assign o_board[5][23]=8'd1;
// assign o_board[5][24]=8'd1;
// assign o_board[5][25]=8'd1;
// assign o_board[5][26]=8'd0;
// assign o_board[5][27]=8'd1;
// assign o_board[6][0]=8'd1;
// assign o_board[6][1]=8'd0;
// assign o_board[6][2]=8'd1;
// assign o_board[6][3]=8'd0;
// assign o_board[6][4]=8'd0;
// assign o_board[6][5]=8'd1;
// assign o_board[6][6]=8'd0;
// assign o_board[6][7]=8'd1;
// assign o_board[6][8]=8'd0;
// assign o_board[6][9]=8'd0;
// assign o_board[6][10]=8'd0;
// assign o_board[6][11]=8'd1;
// assign o_board[6][12]=8'd0;
// assign o_board[6][13]=8'd1;
// assign o_board[6][14]=8'd1;
// assign o_board[6][15]=8'd0;
// assign o_board[6][16]=8'd1;
// assign o_board[6][17]=8'd0;
// assign o_board[6][18]=8'd0;
// assign o_board[6][19]=8'd0;
// assign o_board[6][20]=8'd1;
// assign o_board[6][21]=8'd0;
// assign o_board[6][22]=8'd1;
// assign o_board[6][23]=8'd0;
// assign o_board[6][24]=8'd0;
// assign o_board[6][25]=8'd1;
// assign o_board[6][26]=8'd0;
// assign o_board[6][27]=8'd1;
// assign o_board[7][0]=8'd1;
// assign o_board[7][1]=8'd0;
// assign o_board[7][2]=8'd1;
// assign o_board[7][3]=8'd1;
// assign o_board[7][4]=8'd1;
// assign o_board[7][5]=8'd1;
// assign o_board[7][6]=8'd0;
// assign o_board[7][7]=8'd1;
// assign o_board[7][8]=8'd1;
// assign o_board[7][9]=8'd1;
// assign o_board[7][10]=8'd1;
// assign o_board[7][11]=8'd1;
// assign o_board[7][12]=8'd0;
// assign o_board[7][13]=8'd1;
// assign o_board[7][14]=8'd1;
// assign o_board[7][15]=8'd0;
// assign o_board[7][16]=8'd1;
// assign o_board[7][17]=8'd1;
// assign o_board[7][18]=8'd1;
// assign o_board[7][19]=8'd1;
// assign o_board[7][20]=8'd1;
// assign o_board[7][21]=8'd0;
// assign o_board[7][22]=8'd1;
// assign o_board[7][23]=8'd1;
// assign o_board[7][24]=8'd1;
// assign o_board[7][25]=8'd1;
// assign o_board[7][26]=8'd0;
// assign o_board[7][27]=8'd1;
// assign o_board[8][0]=8'd1;
// assign o_board[8][1]=8'd0;
// assign o_board[8][2]=8'd0;
// assign o_board[8][3]=8'd0;
// assign o_board[8][4]=8'd0;
// assign o_board[8][5]=8'd0;
// assign o_board[8][6]=8'd0;
// assign o_board[8][7]=8'd0;
// assign o_board[8][8]=8'd0;
// assign o_board[8][9]=8'd0;
// assign o_board[8][10]=8'd0;
// assign o_board[8][11]=8'd0;
// assign o_board[8][12]=8'd0;
// assign o_board[8][13]=8'd0;
// assign o_board[8][14]=8'd0;
// assign o_board[8][15]=8'd0;
// assign o_board[8][16]=8'd0;
// assign o_board[8][17]=8'd0;
// assign o_board[8][18]=8'd0;
// assign o_board[8][19]=8'd0;
// assign o_board[8][20]=8'd0;
// assign o_board[8][21]=8'd0;
// assign o_board[8][22]=8'd0;
// assign o_board[8][23]=8'd0;
// assign o_board[8][24]=8'd0;
// assign o_board[8][25]=8'd0;
// assign o_board[8][26]=8'd0;
// assign o_board[8][27]=8'd1;
// assign o_board[9][0]=8'd1;
// assign o_board[9][1]=8'd0;
// assign o_board[9][2]=8'd1;
// assign o_board[9][3]=8'd1;
// assign o_board[9][4]=8'd1;
// assign o_board[9][5]=8'd1;
// assign o_board[9][6]=8'd0;
// assign o_board[9][7]=8'd1;
// assign o_board[9][8]=8'd1;
// assign o_board[9][9]=8'd0;
// assign o_board[9][10]=8'd1;
// assign o_board[9][11]=8'd1;
// assign o_board[9][12]=8'd1;
// assign o_board[9][13]=8'd1;
// assign o_board[9][14]=8'd1;
// assign o_board[9][15]=8'd1;
// assign o_board[9][16]=8'd1;
// assign o_board[9][17]=8'd1;
// assign o_board[9][18]=8'd0;
// assign o_board[9][19]=8'd1;
// assign o_board[9][20]=8'd1;
// assign o_board[9][21]=8'd0;
// assign o_board[9][22]=8'd1;
// assign o_board[9][23]=8'd1;
// assign o_board[9][24]=8'd1;
// assign o_board[9][25]=8'd1;
// assign o_board[9][26]=8'd0;
// assign o_board[9][27]=8'd1;
// assign o_board[10][0]=8'd1;
// assign o_board[10][1]=8'd0;
// assign o_board[10][2]=8'd1;
// assign o_board[10][3]=8'd1;
// assign o_board[10][4]=8'd1;
// assign o_board[10][5]=8'd1;
// assign o_board[10][6]=8'd0;
// assign o_board[10][7]=8'd1;
// assign o_board[10][8]=8'd1;
// assign o_board[10][9]=8'd0;
// assign o_board[10][10]=8'd1;
// assign o_board[10][11]=8'd1;
// assign o_board[10][12]=8'd1;
// assign o_board[10][13]=8'd1;
// assign o_board[10][14]=8'd1;
// assign o_board[10][15]=8'd1;
// assign o_board[10][16]=8'd1;
// assign o_board[10][17]=8'd1;
// assign o_board[10][18]=8'd0;
// assign o_board[10][19]=8'd1;
// assign o_board[10][20]=8'd1;
// assign o_board[10][21]=8'd0;
// assign o_board[10][22]=8'd1;
// assign o_board[10][23]=8'd1;
// assign o_board[10][24]=8'd1;
// assign o_board[10][25]=8'd1;
// assign o_board[10][26]=8'd0;
// assign o_board[10][27]=8'd1;
// assign o_board[11][0]=8'd1;
// assign o_board[11][1]=8'd0;
// assign o_board[11][2]=8'd0;
// assign o_board[11][3]=8'd0;
// assign o_board[11][4]=8'd0;
// assign o_board[11][5]=8'd0;
// assign o_board[11][6]=8'd0;
// assign o_board[11][7]=8'd1;
// assign o_board[11][8]=8'd1;
// assign o_board[11][9]=8'd0;
// assign o_board[11][10]=8'd0;
// assign o_board[11][11]=8'd0;
// assign o_board[11][12]=8'd0;
// assign o_board[11][13]=8'd1;
// assign o_board[11][14]=8'd1;
// assign o_board[11][15]=8'd0;
// assign o_board[11][16]=8'd0;
// assign o_board[11][17]=8'd0;
// assign o_board[11][18]=8'd0;
// assign o_board[11][19]=8'd1;
// assign o_board[11][20]=8'd1;
// assign o_board[11][21]=8'd0;
// assign o_board[11][22]=8'd0;
// assign o_board[11][23]=8'd0;
// assign o_board[11][24]=8'd0;
// assign o_board[11][25]=8'd0;
// assign o_board[11][26]=8'd0;
// assign o_board[11][27]=8'd1;
// assign o_board[12][0]=8'd1;
// assign o_board[12][1]=8'd1;
// assign o_board[12][2]=8'd1;
// assign o_board[12][3]=8'd1;
// assign o_board[12][4]=8'd1;
// assign o_board[12][5]=8'd1;
// assign o_board[12][6]=8'd0;
// assign o_board[12][7]=8'd1;
// assign o_board[12][8]=8'd1;
// assign o_board[12][9]=8'd1;
// assign o_board[12][10]=8'd1;
// assign o_board[12][11]=8'd1;
// assign o_board[12][12]=8'd0;
// assign o_board[12][13]=8'd1;
// assign o_board[12][14]=8'd1;
// assign o_board[12][15]=8'd0;
// assign o_board[12][16]=8'd1;
// assign o_board[12][17]=8'd1;
// assign o_board[12][18]=8'd1;
// assign o_board[12][19]=8'd1;
// assign o_board[12][20]=8'd1;
// assign o_board[12][21]=8'd0;
// assign o_board[12][22]=8'd1;
// assign o_board[12][23]=8'd1;
// assign o_board[12][24]=8'd1;
// assign o_board[12][25]=8'd1;
// assign o_board[12][26]=8'd1;
// assign o_board[12][27]=8'd1;
// assign o_board[13][0]=8'd0;
// assign o_board[13][1]=8'd0;
// assign o_board[13][2]=8'd0;
// assign o_board[13][3]=8'd0;
// assign o_board[13][4]=8'd0;
// assign o_board[13][5]=8'd1;
// assign o_board[13][6]=8'd0;
// assign o_board[13][7]=8'd1;
// assign o_board[13][8]=8'd1;
// assign o_board[13][9]=8'd1;
// assign o_board[13][10]=8'd1;
// assign o_board[13][11]=8'd1;
// assign o_board[13][12]=8'd0;
// assign o_board[13][13]=8'd1;
// assign o_board[13][14]=8'd1;
// assign o_board[13][15]=8'd0;
// assign o_board[13][16]=8'd1;
// assign o_board[13][17]=8'd1;
// assign o_board[13][18]=8'd1;
// assign o_board[13][19]=8'd1;
// assign o_board[13][20]=8'd1;
// assign o_board[13][21]=8'd0;
// assign o_board[13][22]=8'd1;
// assign o_board[13][23]=8'd0;
// assign o_board[13][24]=8'd0;
// assign o_board[13][25]=8'd0;
// assign o_board[13][26]=8'd0;
// assign o_board[13][27]=8'd0;
// assign o_board[14][0]=8'd0;
// assign o_board[14][1]=8'd0;
// assign o_board[14][2]=8'd0;
// assign o_board[14][3]=8'd0;
// assign o_board[14][4]=8'd0;
// assign o_board[14][5]=8'd1;
// assign o_board[14][6]=8'd0;
// assign o_board[14][7]=8'd1;
// assign o_board[14][8]=8'd1;
// assign o_board[14][9]=8'd0;
// assign o_board[14][10]=8'd0;
// assign o_board[14][11]=8'd0;
// assign o_board[14][12]=8'd0;
// assign o_board[14][13]=8'd0;
// assign o_board[14][14]=8'd0;
// assign o_board[14][15]=8'd0;
// assign o_board[14][16]=8'd0;
// assign o_board[14][17]=8'd0;
// assign o_board[14][18]=8'd0;
// assign o_board[14][19]=8'd1;
// assign o_board[14][20]=8'd1;
// assign o_board[14][21]=8'd0;
// assign o_board[14][22]=8'd1;
// assign o_board[14][23]=8'd0;
// assign o_board[14][24]=8'd0;
// assign o_board[14][25]=8'd0;
// assign o_board[14][26]=8'd0;
// assign o_board[14][27]=8'd0;
// assign o_board[15][0]=8'd0;
// assign o_board[15][1]=8'd0;
// assign o_board[15][2]=8'd0;
// assign o_board[15][3]=8'd0;
// assign o_board[15][4]=8'd0;
// assign o_board[15][5]=8'd1;
// assign o_board[15][6]=8'd0;
// assign o_board[15][7]=8'd1;
// assign o_board[15][8]=8'd1;
// assign o_board[15][9]=8'd0;
// assign o_board[15][10]=8'd1;
// assign o_board[15][11]=8'd1;
// assign o_board[15][12]=8'd1;
// assign o_board[15][13]=8'd1;
// assign o_board[15][14]=8'd1;
// assign o_board[15][15]=8'd1;
// assign o_board[15][16]=8'd1;
// assign o_board[15][17]=8'd1;
// assign o_board[15][18]=8'd0;
// assign o_board[15][19]=8'd1;
// assign o_board[15][20]=8'd1;
// assign o_board[15][21]=8'd0;
// assign o_board[15][22]=8'd1;
// assign o_board[15][23]=8'd0;
// assign o_board[15][24]=8'd0;
// assign o_board[15][25]=8'd0;
// assign o_board[15][26]=8'd0;
// assign o_board[15][27]=8'd0;
// assign o_board[16][0]=8'd1;
// assign o_board[16][1]=8'd1;
// assign o_board[16][2]=8'd1;
// assign o_board[16][3]=8'd1;
// assign o_board[16][4]=8'd1;
// assign o_board[16][5]=8'd1;
// assign o_board[16][6]=8'd0;
// assign o_board[16][7]=8'd1;
// assign o_board[16][8]=8'd1;
// assign o_board[16][9]=8'd0;
// assign o_board[16][10]=8'd1;
// assign o_board[16][11]=8'd0;
// assign o_board[16][12]=8'd0;
// assign o_board[16][13]=8'd0;
// assign o_board[16][14]=8'd0;
// assign o_board[16][15]=8'd0;
// assign o_board[16][16]=8'd0;
// assign o_board[16][17]=8'd1;
// assign o_board[16][18]=8'd0;
// assign o_board[16][19]=8'd1;
// assign o_board[16][20]=8'd1;
// assign o_board[16][21]=8'd0;
// assign o_board[16][22]=8'd1;
// assign o_board[16][23]=8'd1;
// assign o_board[16][24]=8'd1;
// assign o_board[16][25]=8'd1;
// assign o_board[16][26]=8'd1;
// assign o_board[16][27]=8'd1;
// assign o_board[17][0]=8'd0;
// assign o_board[17][1]=8'd0;
// assign o_board[17][2]=8'd0;
// assign o_board[17][3]=8'd0;
// assign o_board[17][4]=8'd0;
// assign o_board[17][5]=8'd0;
// assign o_board[17][6]=8'd0;
// assign o_board[17][7]=8'd0;
// assign o_board[17][8]=8'd0;
// assign o_board[17][9]=8'd0;
// assign o_board[17][10]=8'd1;
// assign o_board[17][11]=8'd0;
// assign o_board[17][12]=8'd0;
// assign o_board[17][13]=8'd0;
// assign o_board[17][14]=8'd0;
// assign o_board[17][15]=8'd0;
// assign o_board[17][16]=8'd0;
// assign o_board[17][17]=8'd1;
// assign o_board[17][18]=8'd0;
// assign o_board[17][19]=8'd0;
// assign o_board[17][20]=8'd0;
// assign o_board[17][21]=8'd0;
// assign o_board[17][22]=8'd0;
// assign o_board[17][23]=8'd0;
// assign o_board[17][24]=8'd0;
// assign o_board[17][25]=8'd0;
// assign o_board[17][26]=8'd0;
// assign o_board[17][27]=8'd0;
// assign o_board[18][0]=8'd1;
// assign o_board[18][1]=8'd1;
// assign o_board[18][2]=8'd1;
// assign o_board[18][3]=8'd1;
// assign o_board[18][4]=8'd1;
// assign o_board[18][5]=8'd1;
// assign o_board[18][6]=8'd0;
// assign o_board[18][7]=8'd1;
// assign o_board[18][8]=8'd1;
// assign o_board[18][9]=8'd0;
// assign o_board[18][10]=8'd1;
// assign o_board[18][11]=8'd0;
// assign o_board[18][12]=8'd0;
// assign o_board[18][13]=8'd0;
// assign o_board[18][14]=8'd0;
// assign o_board[18][15]=8'd0;
// assign o_board[18][16]=8'd0;
// assign o_board[18][17]=8'd1;
// assign o_board[18][18]=8'd0;
// assign o_board[18][19]=8'd1;
// assign o_board[18][20]=8'd1;
// assign o_board[18][21]=8'd0;
// assign o_board[18][22]=8'd1;
// assign o_board[18][23]=8'd1;
// assign o_board[18][24]=8'd1;
// assign o_board[18][25]=8'd1;
// assign o_board[18][26]=8'd1;
// assign o_board[18][27]=8'd1;
// assign o_board[19][0]=8'd0;
// assign o_board[19][1]=8'd0;
// assign o_board[19][2]=8'd0;
// assign o_board[19][3]=8'd0;
// assign o_board[19][4]=8'd0;
// assign o_board[19][5]=8'd1;
// assign o_board[19][6]=8'd0;
// assign o_board[19][7]=8'd1;
// assign o_board[19][8]=8'd1;
// assign o_board[19][9]=8'd0;
// assign o_board[19][10]=8'd1;
// assign o_board[19][11]=8'd1;
// assign o_board[19][12]=8'd1;
// assign o_board[19][13]=8'd1;
// assign o_board[19][14]=8'd1;
// assign o_board[19][15]=8'd1;
// assign o_board[19][16]=8'd1;
// assign o_board[19][17]=8'd1;
// assign o_board[19][18]=8'd0;
// assign o_board[19][19]=8'd1;
// assign o_board[19][20]=8'd1;
// assign o_board[19][21]=8'd0;
// assign o_board[19][22]=8'd1;
// assign o_board[19][23]=8'd0;
// assign o_board[19][24]=8'd0;
// assign o_board[19][25]=8'd0;
// assign o_board[19][26]=8'd0;
// assign o_board[19][27]=8'd0;
// assign o_board[20][0]=8'd0;
// assign o_board[20][1]=8'd0;
// assign o_board[20][2]=8'd0;
// assign o_board[20][3]=8'd0;
// assign o_board[20][4]=8'd0;
// assign o_board[20][5]=8'd1;
// assign o_board[20][6]=8'd0;
// assign o_board[20][7]=8'd1;
// assign o_board[20][8]=8'd1;
// assign o_board[20][9]=8'd0;
// assign o_board[20][10]=8'd0;
// assign o_board[20][11]=8'd0;
// assign o_board[20][12]=8'd0;
// assign o_board[20][13]=8'd0;
// assign o_board[20][14]=8'd0;
// assign o_board[20][15]=8'd0;
// assign o_board[20][16]=8'd0;
// assign o_board[20][17]=8'd0;
// assign o_board[20][18]=8'd0;
// assign o_board[20][19]=8'd1;
// assign o_board[20][20]=8'd1;
// assign o_board[20][21]=8'd0;
// assign o_board[20][22]=8'd1;
// assign o_board[20][23]=8'd0;
// assign o_board[20][24]=8'd0;
// assign o_board[20][25]=8'd0;
// assign o_board[20][26]=8'd0;
// assign o_board[20][27]=8'd0;
// assign o_board[21][0]=8'd0;
// assign o_board[21][1]=8'd0;
// assign o_board[21][2]=8'd0;
// assign o_board[21][3]=8'd0;
// assign o_board[21][4]=8'd0;
// assign o_board[21][5]=8'd1;
// assign o_board[21][6]=8'd0;
// assign o_board[21][7]=8'd1;
// assign o_board[21][8]=8'd1;
// assign o_board[21][9]=8'd0;
// assign o_board[21][10]=8'd1;
// assign o_board[21][11]=8'd1;
// assign o_board[21][12]=8'd1;
// assign o_board[21][13]=8'd1;
// assign o_board[21][14]=8'd1;
// assign o_board[21][15]=8'd1;
// assign o_board[21][16]=8'd1;
// assign o_board[21][17]=8'd1;
// assign o_board[21][18]=8'd0;
// assign o_board[21][19]=8'd1;
// assign o_board[21][20]=8'd1;
// assign o_board[21][21]=8'd0;
// assign o_board[21][22]=8'd1;
// assign o_board[21][23]=8'd0;
// assign o_board[21][24]=8'd0;
// assign o_board[21][25]=8'd0;
// assign o_board[21][26]=8'd0;
// assign o_board[21][27]=8'd0;
// assign o_board[22][0]=8'd1;
// assign o_board[22][1]=8'd1;
// assign o_board[22][2]=8'd1;
// assign o_board[22][3]=8'd1;
// assign o_board[22][4]=8'd1;
// assign o_board[22][5]=8'd1;
// assign o_board[22][6]=8'd0;
// assign o_board[22][7]=8'd1;
// assign o_board[22][8]=8'd1;
// assign o_board[22][9]=8'd0;
// assign o_board[22][10]=8'd1;
// assign o_board[22][11]=8'd1;
// assign o_board[22][12]=8'd1;
// assign o_board[22][13]=8'd1;
// assign o_board[22][14]=8'd1;
// assign o_board[22][15]=8'd1;
// assign o_board[22][16]=8'd1;
// assign o_board[22][17]=8'd1;
// assign o_board[22][18]=8'd0;
// assign o_board[22][19]=8'd1;
// assign o_board[22][20]=8'd1;
// assign o_board[22][21]=8'd0;
// assign o_board[22][22]=8'd1;
// assign o_board[22][23]=8'd1;
// assign o_board[22][24]=8'd1;
// assign o_board[22][25]=8'd1;
// assign o_board[22][26]=8'd1;
// assign o_board[22][27]=8'd1;
// assign o_board[23][0]=8'd1;
// assign o_board[23][1]=8'd0;
// assign o_board[23][2]=8'd0;
// assign o_board[23][3]=8'd0;
// assign o_board[23][4]=8'd0;
// assign o_board[23][5]=8'd0;
// assign o_board[23][6]=8'd0;
// assign o_board[23][7]=8'd0;
// assign o_board[23][8]=8'd0;
// assign o_board[23][9]=8'd0;
// assign o_board[23][10]=8'd0;
// assign o_board[23][11]=8'd0;
// assign o_board[23][12]=8'd0;
// assign o_board[23][13]=8'd1;
// assign o_board[23][14]=8'd1;
// assign o_board[23][15]=8'd0;
// assign o_board[23][16]=8'd0;
// assign o_board[23][17]=8'd0;
// assign o_board[23][18]=8'd0;
// assign o_board[23][19]=8'd0;
// assign o_board[23][20]=8'd0;
// assign o_board[23][21]=8'd0;
// assign o_board[23][22]=8'd0;
// assign o_board[23][23]=8'd0;
// assign o_board[23][24]=8'd0;
// assign o_board[23][25]=8'd0;
// assign o_board[23][26]=8'd0;
// assign o_board[23][27]=8'd1;
// assign o_board[24][0]=8'd1;
// assign o_board[24][1]=8'd0;
// assign o_board[24][2]=8'd1;
// assign o_board[24][3]=8'd1;
// assign o_board[24][4]=8'd1;
// assign o_board[24][5]=8'd1;
// assign o_board[24][6]=8'd0;
// assign o_board[24][7]=8'd1;
// assign o_board[24][8]=8'd1;
// assign o_board[24][9]=8'd1;
// assign o_board[24][10]=8'd1;
// assign o_board[24][11]=8'd1;
// assign o_board[24][12]=8'd0;
// assign o_board[24][13]=8'd1;
// assign o_board[24][14]=8'd1;
// assign o_board[24][15]=8'd0;
// assign o_board[24][16]=8'd1;
// assign o_board[24][17]=8'd1;
// assign o_board[24][18]=8'd1;
// assign o_board[24][19]=8'd1;
// assign o_board[24][20]=8'd1;
// assign o_board[24][21]=8'd0;
// assign o_board[24][22]=8'd1;
// assign o_board[24][23]=8'd1;
// assign o_board[24][24]=8'd1;
// assign o_board[24][25]=8'd1;
// assign o_board[24][26]=8'd0;
// assign o_board[24][27]=8'd1;
// assign o_board[25][0]=8'd1;
// assign o_board[25][1]=8'd0;
// assign o_board[25][2]=8'd1;
// assign o_board[25][3]=8'd1;
// assign o_board[25][4]=8'd1;
// assign o_board[25][5]=8'd1;
// assign o_board[25][6]=8'd0;
// assign o_board[25][7]=8'd1;
// assign o_board[25][8]=8'd1;
// assign o_board[25][9]=8'd1;
// assign o_board[25][10]=8'd1;
// assign o_board[25][11]=8'd1;
// assign o_board[25][12]=8'd0;
// assign o_board[25][13]=8'd1;
// assign o_board[25][14]=8'd1;
// assign o_board[25][15]=8'd0;
// assign o_board[25][16]=8'd1;
// assign o_board[25][17]=8'd1;
// assign o_board[25][18]=8'd1;
// assign o_board[25][19]=8'd1;
// assign o_board[25][20]=8'd1;
// assign o_board[25][21]=8'd0;
// assign o_board[25][22]=8'd1;
// assign o_board[25][23]=8'd1;
// assign o_board[25][24]=8'd1;
// assign o_board[25][25]=8'd1;
// assign o_board[25][26]=8'd0;
// assign o_board[25][27]=8'd1;
// assign o_board[26][0]=8'd1;
// assign o_board[26][1]=8'd0;
// assign o_board[26][2]=8'd0;
// assign o_board[26][3]=8'd0;
// assign o_board[26][4]=8'd1;
// assign o_board[26][5]=8'd1;
// assign o_board[26][6]=8'd0;
// assign o_board[26][7]=8'd0;
// assign o_board[26][8]=8'd0;
// assign o_board[26][9]=8'd0;
// assign o_board[26][10]=8'd0;
// assign o_board[26][11]=8'd0;
// assign o_board[26][12]=8'd0;
// assign o_board[26][13]=8'd0;
// assign o_board[26][14]=8'd0;
// assign o_board[26][15]=8'd0;
// assign o_board[26][16]=8'd0;
// assign o_board[26][17]=8'd0;
// assign o_board[26][18]=8'd0;
// assign o_board[26][19]=8'd0;
// assign o_board[26][20]=8'd0;
// assign o_board[26][21]=8'd0;
// assign o_board[26][22]=8'd1;
// assign o_board[26][23]=8'd1;
// assign o_board[26][24]=8'd0;
// assign o_board[26][25]=8'd0;
// assign o_board[26][26]=8'd0;
// assign o_board[26][27]=8'd1;
// assign o_board[27][0]=8'd1;
// assign o_board[27][1]=8'd1;
// assign o_board[27][2]=8'd1;
// assign o_board[27][3]=8'd0;
// assign o_board[27][4]=8'd1;
// assign o_board[27][5]=8'd1;
// assign o_board[27][6]=8'd0;
// assign o_board[27][7]=8'd1;
// assign o_board[27][8]=8'd1;
// assign o_board[27][9]=8'd0;
// assign o_board[27][10]=8'd1;
// assign o_board[27][11]=8'd1;
// assign o_board[27][12]=8'd1;
// assign o_board[27][13]=8'd1;
// assign o_board[27][14]=8'd1;
// assign o_board[27][15]=8'd1;
// assign o_board[27][16]=8'd1;
// assign o_board[27][17]=8'd1;
// assign o_board[27][18]=8'd0;
// assign o_board[27][19]=8'd1;
// assign o_board[27][20]=8'd1;
// assign o_board[27][21]=8'd0;
// assign o_board[27][22]=8'd1;
// assign o_board[27][23]=8'd1;
// assign o_board[27][24]=8'd0;
// assign o_board[27][25]=8'd1;
// assign o_board[27][26]=8'd1;
// assign o_board[27][27]=8'd1;
// assign o_board[28][0]=8'd1;
// assign o_board[28][1]=8'd1;
// assign o_board[28][2]=8'd1;
// assign o_board[28][3]=8'd0;
// assign o_board[28][4]=8'd1;
// assign o_board[28][5]=8'd1;
// assign o_board[28][6]=8'd0;
// assign o_board[28][7]=8'd1;
// assign o_board[28][8]=8'd1;
// assign o_board[28][9]=8'd0;
// assign o_board[28][10]=8'd1;
// assign o_board[28][11]=8'd1;
// assign o_board[28][12]=8'd1;
// assign o_board[28][13]=8'd1;
// assign o_board[28][14]=8'd1;
// assign o_board[28][15]=8'd1;
// assign o_board[28][16]=8'd1;
// assign o_board[28][17]=8'd1;
// assign o_board[28][18]=8'd0;
// assign o_board[28][19]=8'd1;
// assign o_board[28][20]=8'd1;
// assign o_board[28][21]=8'd0;
// assign o_board[28][22]=8'd1;
// assign o_board[28][23]=8'd1;
// assign o_board[28][24]=8'd0;
// assign o_board[28][25]=8'd1;
// assign o_board[28][26]=8'd1;
// assign o_board[28][27]=8'd1;
// assign o_board[29][0]=8'd1;
// assign o_board[29][1]=8'd0;
// assign o_board[29][2]=8'd0;
// assign o_board[29][3]=8'd0;
// assign o_board[29][4]=8'd0;
// assign o_board[29][5]=8'd0;
// assign o_board[29][6]=8'd0;
// assign o_board[29][7]=8'd1;
// assign o_board[29][8]=8'd1;
// assign o_board[29][9]=8'd0;
// assign o_board[29][10]=8'd0;
// assign o_board[29][11]=8'd0;
// assign o_board[29][12]=8'd0;
// assign o_board[29][13]=8'd1;
// assign o_board[29][14]=8'd1;
// assign o_board[29][15]=8'd0;
// assign o_board[29][16]=8'd0;
// assign o_board[29][17]=8'd0;
// assign o_board[29][18]=8'd0;
// assign o_board[29][19]=8'd1;
// assign o_board[29][20]=8'd1;
// assign o_board[29][21]=8'd0;
// assign o_board[29][22]=8'd0;
// assign o_board[29][23]=8'd0;
// assign o_board[29][24]=8'd0;
// assign o_board[29][25]=8'd0;
// assign o_board[29][26]=8'd0;
// assign o_board[29][27]=8'd1;
// assign o_board[30][0]=8'd1;
// assign o_board[30][1]=8'd0;
// assign o_board[30][2]=8'd1;
// assign o_board[30][3]=8'd1;
// assign o_board[30][4]=8'd1;
// assign o_board[30][5]=8'd1;
// assign o_board[30][6]=8'd1;
// assign o_board[30][7]=8'd1;
// assign o_board[30][8]=8'd1;
// assign o_board[30][9]=8'd1;
// assign o_board[30][10]=8'd1;
// assign o_board[30][11]=8'd1;
// assign o_board[30][12]=8'd0;
// assign o_board[30][13]=8'd1;
// assign o_board[30][14]=8'd1;
// assign o_board[30][15]=8'd0;
// assign o_board[30][16]=8'd1;
// assign o_board[30][17]=8'd1;
// assign o_board[30][18]=8'd1;
// assign o_board[30][19]=8'd1;
// assign o_board[30][20]=8'd1;
// assign o_board[30][21]=8'd1;
// assign o_board[30][22]=8'd1;
// assign o_board[30][23]=8'd1;
// assign o_board[30][24]=8'd1;
// assign o_board[30][25]=8'd1;
// assign o_board[30][26]=8'd0;
// assign o_board[30][27]=8'd1;
// assign o_board[31][0]=8'd1;
// assign o_board[31][1]=8'd0;
// assign o_board[31][2]=8'd1;
// assign o_board[31][3]=8'd1;
// assign o_board[31][4]=8'd1;
// assign o_board[31][5]=8'd1;
// assign o_board[31][6]=8'd1;
// assign o_board[31][7]=8'd1;
// assign o_board[31][8]=8'd1;
// assign o_board[31][9]=8'd1;
// assign o_board[31][10]=8'd1;
// assign o_board[31][11]=8'd1;
// assign o_board[31][12]=8'd0;
// assign o_board[31][13]=8'd1;
// assign o_board[31][14]=8'd1;
// assign o_board[31][15]=8'd0;
// assign o_board[31][16]=8'd1;
// assign o_board[31][17]=8'd1;
// assign o_board[31][18]=8'd1;
// assign o_board[31][19]=8'd1;
// assign o_board[31][20]=8'd1;
// assign o_board[31][21]=8'd1;
// assign o_board[31][22]=8'd1;
// assign o_board[31][23]=8'd1;
// assign o_board[31][24]=8'd1;
// assign o_board[31][25]=8'd1;
// assign o_board[31][26]=8'd0;
// assign o_board[31][27]=8'd1;
// assign o_board[32][0]=8'd1;
// assign o_board[32][1]=8'd0;
// assign o_board[32][2]=8'd0;
// assign o_board[32][3]=8'd0;
// assign o_board[32][4]=8'd0;
// assign o_board[32][5]=8'd0;
// assign o_board[32][6]=8'd0;
// assign o_board[32][7]=8'd0;
// assign o_board[32][8]=8'd0;
// assign o_board[32][9]=8'd0;
// assign o_board[32][10]=8'd0;
// assign o_board[32][11]=8'd0;
// assign o_board[32][12]=8'd0;
// assign o_board[32][13]=8'd0;
// assign o_board[32][14]=8'd0;
// assign o_board[32][15]=8'd0;
// assign o_board[32][16]=8'd0;
// assign o_board[32][17]=8'd0;
// assign o_board[32][18]=8'd0;
// assign o_board[32][19]=8'd0;
// assign o_board[32][20]=8'd0;
// assign o_board[32][21]=8'd0;
// assign o_board[32][22]=8'd0;
// assign o_board[32][23]=8'd0;
// assign o_board[32][24]=8'd0;
// assign o_board[32][25]=8'd0;
// assign o_board[32][26]=8'd0;
// assign o_board[32][27]=8'd1;
// assign o_board[33][0]=8'd1;
// assign o_board[33][1]=8'd1;
// assign o_board[33][2]=8'd1;
// assign o_board[33][3]=8'd1;
// assign o_board[33][4]=8'd1;
// assign o_board[33][5]=8'd1;
// assign o_board[33][6]=8'd1;
// assign o_board[33][7]=8'd1;
// assign o_board[33][8]=8'd1;
// assign o_board[33][9]=8'd1;
// assign o_board[33][10]=8'd1;
// assign o_board[33][11]=8'd1;
// assign o_board[33][12]=8'd1;
// assign o_board[33][13]=8'd1;
// assign o_board[33][14]=8'd1;
// assign o_board[33][15]=8'd1;
// assign o_board[33][16]=8'd1;
// assign o_board[33][17]=8'd1;
// assign o_board[33][18]=8'd1;
// assign o_board[33][19]=8'd1;
// assign o_board[33][20]=8'd1;
// assign o_board[33][21]=8'd1;
// assign o_board[33][22]=8'd1;
// assign o_board[33][23]=8'd1;
// assign o_board[33][24]=8'd1;
// assign o_board[33][25]=8'd1;
// assign o_board[33][26]=8'd1;
// assign o_board[33][27]=8'd1;
// assign o_board[34][0]=8'd0;
// assign o_board[34][1]=8'd0;
// assign o_board[34][2]=8'd0;
// assign o_board[34][3]=8'd0;
// assign o_board[34][4]=8'd0;
// assign o_board[34][5]=8'd0;
// assign o_board[34][6]=8'd0;
// assign o_board[34][7]=8'd0;
// assign o_board[34][8]=8'd0;
// assign o_board[34][9]=8'd0;
// assign o_board[34][10]=8'd0;
// assign o_board[34][11]=8'd0;
// assign o_board[34][12]=8'd0;
// assign o_board[34][13]=8'd0;
// assign o_board[34][14]=8'd0;
// assign o_board[34][15]=8'd0;
// assign o_board[34][16]=8'd0;
// assign o_board[34][17]=8'd0;
// assign o_board[34][18]=8'd0;
// assign o_board[34][19]=8'd0;
// assign o_board[34][20]=8'd0;
// assign o_board[34][21]=8'd0;
// assign o_board[34][22]=8'd0;
// assign o_board[34][23]=8'd0;
// assign o_board[34][24]=8'd0;
// assign o_board[34][25]=8'd0;
// assign o_board[34][26]=8'd0;
// assign o_board[34][27]=8'd0;
// assign o_board[35][0]=8'd0;
// assign o_board[35][1]=8'd0;
// assign o_board[35][2]=8'd0;
// assign o_board[35][3]=8'd0;
// assign o_board[35][4]=8'd0;
// assign o_board[35][5]=8'd0;
// assign o_board[35][6]=8'd0;
// assign o_board[35][7]=8'd0;
// assign o_board[35][8]=8'd0;
// assign o_board[35][9]=8'd0;
// assign o_board[35][10]=8'd0;
// assign o_board[35][11]=8'd0;
// assign o_board[35][12]=8'd0;
// assign o_board[35][13]=8'd0;
// assign o_board[35][14]=8'd0;
// assign o_board[35][15]=8'd0;
// assign o_board[35][16]=8'd0;
// assign o_board[35][17]=8'd0;
// assign o_board[35][18]=8'd0;
// assign o_board[35][19]=8'd0;
// assign o_board[35][20]=8'd0;
// assign o_board[35][21]=8'd0;
// assign o_board[35][22]=8'd0;
// assign o_board[35][23]=8'd0;
// assign o_board[35][24]=8'd0;
// assign o_board[35][25]=8'd0;
// assign o_board[35][26]=8'd0;
// assign o_board[35][27]=8'd0;

endmodule