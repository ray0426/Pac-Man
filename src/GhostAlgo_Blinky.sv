// Ghost Algorithm for chase, scatter, frightened, idle, died mode.
// Tile version.
module GhostAlgo_Blinky ( 
    input i_clk, // global clock, (CLOCK_50).
    input i_rst, // reset, like i_pacman_reload.
	 input i_pacman_reload, // reload.
    input [9:0] pac_x, // 10 bits, x location of pac-man.
    input [9:0] pac_y, // 10 bits. y location of pac-man.
    input [7:0] i_board [0:35][0:27], // game map.
    input [3:0] i_mode, // chase, frightened, scatter, idle, died mode.
	 //input [3:0] random_move_2, // random 2 choice.
	 //input [3:0] random_move_3, // random 3 choice.
	 
    output [9:0] o_x_location, // 10 bits, the x location of blinky.
    output [9:0] o_y_location, // 10 bits. the y location of blinky.
    output reach, // in chase mode, ghost have catched pac-man.
	 output died_arrive_home, // in died mode, blinky had arrived at his birth place.
    output [1:0] next_direction, // ghost move's direction.
	 
	 // part of debug.
    output [9:0] test_distance, // debug for distance calculatuon.
    output illegal, // debug for visit on illegal tile.
    output [3:0] case_num, // debug for the categories of intersections.
    output [3:0] mode_state // debug for different mode state.
);


logic CLOCK_1hz;

// frequency divider.
Clock_divider freq_div1 (
    .clock_in(i_clk),
    .clock_out(CLOCK_1hz),
	 .DIVISOR(28'd781250)
);

logic [3:0] random_move2, random_move_3;

// random move using in frightened mode.
Random random_2_num (
	.i_clk(i_clk),
	.i_rst_n(i_rst),
	.o_random_out(random_move_2)
);

Random_direction random_3_num (
	.i_clk(i_clk),
	.i_rst_n(i_rst),
	.random_move(random_move_3)
);



// next move direction.
parameter UP = 2'b00;
parameter DOWN = 2'b01;
parameter LEFT = 2'b10;
parameter RIGHT = 2'b11;
 
// game mode.
parameter MODE_IDLE = 4'd0;
parameter MODE_CHASE = 4'd1;
parameter MODE_SCATTER = 4'd2;
parameter MODE_FRIGHTENED = 4'd3;
parameter MODE_DIED = 4'd4;


logic right_next, left_next, up_next, down_next;

logic target1; // scatter mode, reach ghost's home target.

// the distance between ghost and target.
logic [22:0] up_distance;  
logic [22:0] down_distance;
logic [22:0] left_distance;
logic [22:0] right_distance;

// can be simplified.
// the distance between ghost and home target.
logic [22:0] up_distance2;  
logic [22:0] down_distance2;
logic [22:0] left_distance2;
logic [22:0] right_distance2;

// the distance between ghost and birth place.
logic [22:0] up_distance3;  
logic [22:0] down_distance3;
logic [22:0] left_distance3;
logic [22:0] right_distance3;

// count = 8, then walk through a tile.
logic [3:0] count;

// mode state.
logic [3:0] state;
assign mode_state = state;

logic [3:0] tile;

// Tile: 36x28
// Pixel: 288x224

// * 0 1 0 1
// 1 0 0 1 0
// 1 1 0 1 0
// 1 0 0 0 0
// 1 0 0 1 X

//    0 1 2 3 4
// 0: G 0 0 0 0
// 1: 0 0 0 0 0
// 2: 0 0 0 0 0
// 3: 0 0 0 0 0
// 4: 0 0 0 0 P

// tile bound.
parameter ROW = 6'd36;
parameter COL = 6'd28;

// scatter mode.
//parameter BLINKY_TARGET_X = 9'd28;
//parameter BLINKY_TARGET_Y = 9'd204;

assign illegal = (i_board[(o_x_location + 4) >> 3][(o_y_location + 4) >> 3] == 1'b0)? 1'b0: 1'b1;

assign test_distance = distance(pac_x, pac_y, o_x_location, o_y_location);

// calculate Norm2 distance by tile.
function [11:0] distance;
	 input [9:0] pac_x;  // the x-coordination of pac-man.
    input [9:0] pac_y;  // the y-coordination of pac-man.
    input [9:0] o_x_location; // the x-coordination of ghost.
    input [9:0] o_y_location; // the y-coordination of ghost.
	 
	 logic [5:0] pac_tile_x;
	 logic [5:0] pac_tile_y;
	 
	 logic [5:0] ghost_tile_x;
	 logic [5:0] ghost_tile_y;
	 
	 logic [5:0] abs_x; // absolute value of distance in the x-coordination.
    logic [5:0] abs_y; // absolute value of distance in the y-coordination.
    
	 
	 pac_tile_x = (pac_x + 3'd4) >> 3;
	 pac_tile_y = (pac_y + 3'd4) >> 3;
	 
	 ghost_tile_x = (o_x_location + 3'd4) >> 3;
	 ghost_tile_y = (o_y_location + 3'd4) >> 3;
	 
	 if (pac_tile_x >= ghost_tile_x) begin
	     abs_x = pac_tile_x - ghost_tile_x;
	 end
	 
	 else begin
		  abs_x = ghost_tile_x - pac_tile_x; 
	 end
	 
	 if (pac_tile_y >= ghost_tile_y) begin
	     abs_y = pac_tile_y - ghost_tile_y;
	 end
	 
	 else begin
		  abs_y = ghost_tile_y - pac_tile_y; 
	 end
	 
	 distance = abs_x * abs_x + abs_y * abs_y;
	 
endfunction
	 
// calculate Norm2 distance by pixel
function [22:0] distance_pixel;
    input [9:0] pac_x;  // the x-coordination of pac-man.
    input [9:0] pac_y;  // the y-coordination of pac-man.
    input [9:0] o_x_location; // the x-coordination of ghost.
    input [9:0] o_y_location; // the y-coordination of ghost.
	 
    logic [9:0] abs_x; // absolute value of distance in the x-coordination.
    logic [9:0] abs_y; // absolute value of distance in the y-coordination.
    
    begin
        if (o_x_location >= pac_x) begin
            abs_x = o_x_location - pac_x;
        end
	else begin
            abs_x = pac_x - o_x_location;
        end
		  
        if (o_y_location >= pac_y) begin
            abs_y = o_y_location - pac_y;
        end
        else begin
            abs_y = pac_y - o_y_location;
        end
		  
        distance_pixel = abs_x * abs_x + abs_y * abs_y;
    end
    
endfunction

// determine the categories of intersection.
function [3:0] tile_situation;
    input [9:0] o_x_location; // the x-coordination of ghost.
    input [9:0] o_y_location; // the y-coordination of ghost.
    input [7:0] i_board [0:35][0:27]; // map.
    input [1:0] next_direction; // the direction of ghost.
	
    logic [5:0] tile_x; // the tile x-coordination of ghost.
    logic [5:0] tile_y; // the tile y-coordination of ghost.
    logic up, down, left, right; // up-tile, down-tile, left-tile, right-tile.
	
    tile_x = ((o_x_location + 3'd4) >> 3); // current tile.
    tile_y = ((o_y_location + 3'd4) >> 3);
		
    // 0 for road, 1 for non-road.
    if (tile_x - 1 >= 0) begin
        up = (i_board[tile_x - 1][tile_y] == 1'b0)? 1'b0: 1'b1;
    end
    else begin
        up = 1'b1; // boundary.
    end
    
    if (tile_x + 1 < ROW) begin
        down = (i_board[tile_x + 1][tile_y] == 1'b0)? 1'b0: 1'b1; // down tile.
    end
    else begin
        down = 1'b1; // boundary.
    end
    
    if (tile_y - 1 >= 0) begin
        left = (i_board[tile_x][tile_y - 1] == 1'b0)? 1'b0: 1'b1; // left tile.
    end
    else begin
        left = 1'b1; // boundary.
    end
    
    if (tile_y + 1 < COL) begin
        right = (i_board[tile_x][tile_y + 1] == 1'b0)? 1'b0: 1'b1; // right tile.
    end
    else begin
        right = 1'b1; // boundary.
    end
    
    tile_situation = {up, down, left, right};
	
endfunction

// the categories of current tile.
assign tile = tile_situation(o_x_location, o_y_location, i_board, next_direction); // cow bei

// the distance between next-predict location of ghost and current location of pac-man.
assign right_distance = distance(pac_x, pac_y, o_x_location, o_y_location + 4'd8);
assign left_distance = distance(pac_x, pac_y, o_x_location, o_y_location - 4'd8);
assign down_distance = distance(pac_x, pac_y, o_x_location + 4'd8, o_y_location);
assign up_distance = distance(pac_x, pac_y, o_x_location - 4'd8, o_y_location);

// the distance between next-predict location of ghost and its target location.
assign right_distance2 = distance(10'd28, 10'd204, o_x_location, o_y_location + 4'd8);
assign left_distance2 = distance(10'd28, 10'd204, o_x_location, o_y_location - 4'd8);
assign down_distance2 = distance(10'd28, 10'd204, o_x_location + 4'd8, o_y_location);
assign up_distance2 = distance(10'd28, 10'd204, o_x_location - 4'd8, o_y_location);

// the distance between next-predict location of ghost and its home location.
assign right_distance3 = distance(10'd108, 10'd100, o_x_location, o_y_location + 4'd8);
assign left_distance3 = distance(10'd108, 10'd100, o_x_location, o_y_location - 4'd8);
assign down_distance3 = distance(10'd108, 10'd100, o_x_location + 4'd8, o_y_location);
assign up_distance3 = distance(10'd108, 10'd100, o_x_location - 4'd8, o_y_location);


// go through the map, right to left, or, left to right.
logic right_to_left, left_to_right;
assign right_to_left = (((o_x_location + 3'd4) >> 3) == 17 && ((o_y_location + 3'd4) >> 3) == 26 && next_direction == RIGHT)? 1'b1: 1'b0;
assign left_to_right = (((o_x_location + 3'd4) >> 3) == 17 && ((o_y_location + 3'd4) >> 3) == 1 && next_direction == LEFT)? 1'b1: 1'b0;

logic [9:0] blinky_target_x;
logic [9:0] blinky_target_y;
logic legal_test, legal_test2;
logic walk_through_home;

always_ff @(posedge CLOCK_1hz) begin
    if (i_rst) begin
        o_x_location <= 9'd108; // ghost initial location.
        o_y_location <= 9'd100;
        
        state <= MODE_IDLE;
        
        left_next <= 1'b0;
        right_next <= 1'b1;
        up_next <= 1'b0;
        down_next <= 1'b0;
        
        next_direction <= RIGHT; // ghost initial move direction.
        
        reach <= 1'b0; // no reach.
        count <= 4'd0;
		  case_num <= 4'd0;
		  
		  target1 <= 1'b0;
		  
		  died_arrive_home <= 1'b0;
 
    end
	 
	 else if (i_pacman_reload == 1'b1) begin
	 
	     o_x_location <= 9'd108; // ghost initial location.
        o_y_location <= 9'd100;
        
        state <= MODE_IDLE;
        
        left_next <= 1'b0;
        right_next <= 1'b1;
        up_next <= 1'b0;
        down_next <= 1'b0;
        
        next_direction <= RIGHT; // ghost initial move direction.
        
        reach <= 1'b0; // no reach.
        count <= 4'd0;
		  case_num <= 4'd0;
		  
		  target1 <= 1'b0;
		  
		  died_arrive_home <= 1'b0;
	 
	 end
    
    else begin
        case(state)
				MODE_IDLE: begin
				    o_x_location <= 9'd108; // ghost initial location.
					 o_y_location <= 9'd100;
					  
					 state <= MODE_IDLE;
					  
					 left_next <= 1'b0;
					 right_next <= 1'b1;
					 up_next <= 1'b0;
					 down_next <= 1'b0;
					  
					 next_direction <= RIGHT; // ghost initial move direction.
					  
					 reach <= 1'b0; // no reach.
					 count <= 4'd0;
					 case_num <= 4'd0;
					  
					 target1 <= 1'b0;
					 
					 died_arrive_home <= 1'b0;
					 
					 if (i_mode == MODE_CHASE) begin
					     state <= MODE_CHASE;
						  left_next <= 1'b0;
						  right_next <= 1'b1;
						  up_next <= 1'b0;
						  down_next <= 1'b0;
						  count <= 4'd0;
						  next_direction <= RIGHT; // ghost initial move direction.
					 end
					 else if (i_mode == MODE_SCATTER) begin
						  state <= MODE_SCATTER;
					     count <= 4'd8;
						  blinky_target_x <= 9'd28;
						  blinky_target_y <= 9'd204;
					 end
					 else if (i_mode == MODE_FRIGHTENED) begin
						  state <= MODE_FRIGHTENED;
						 count <= 4'd0; // ?
						 if (next_direction == LEFT) begin
							  next_direction <= RIGHT;
							  up_next <= 1'b0;
							  down_next <= 1'b0;
							  right_next <= 1'b1;
							  left_next <= 1'b0;
						 end
						 else if (next_direction == RIGHT) begin
							  next_direction <= LEFT;
							  up_next <= 1'b0;
							  down_next <= 1'b0;
							  right_next <= 1'b0;
							  left_next <= 1'b1;
						 end
						 else if (next_direction == UP) begin
							  next_direction <= DOWN;
							  up_next <= 1'b0;
							  down_next <= 1'b1;
							  right_next <= 1'b0;
							  left_next <= 1'b0;
						 end
						 else begin // down.
							  next_direction <= UP;
							  up_next <= 1'b1;
							  down_next <= 1'b0;
							  right_next <= 1'b0;
							  left_next <= 1'b0;
						 end
					end
					
				end
				
				MODE_DIED: begin 
					 
						 if (count == 4'd8) begin // count = 8, predict next move's next direction.
							  state <= MODE_DIED;
							  if (i_mode == MODE_CHASE) begin
					            state <= MODE_CHASE;
									count <= 4'd8;
									
					        end
					 
							  else if (i_mode == MODE_SCATTER) begin
								   state <= MODE_SCATTER;
								   count <= 4'd8;
									
								   blinky_target_x <= 9'd28;
								   blinky_target_y <= 9'd204;
							  end
							  
							  else if (o_x_location == 9'd132 && o_y_location == 9'd100) begin // arrive at home.
								  died_arrive_home <= 1'b1;
								  o_x_location <= 9'd132;
								  o_y_location <= 9'd100;
								  count <= 4'd8;
							  end
							 
							  else if (o_x_location == 9'd108 && o_y_location == 9'd100) begin 
								  count <= 4'd0;
								  next_direction <= DOWN;
								  left_next <= 1'b0;
								  right_next <= 1'b0;
								  up_next <= 1'b0;
								  down_next <= 1'b1;
								 
							  end
							 
							  else if (o_x_location == 9'd116 && o_y_location == 9'd100) begin 
								  count <= 4'd0;
								  next_direction <= DOWN;
								  left_next <= 1'b0;
								  right_next <= 1'b0;
								  up_next <= 1'b0;
								  down_next <= 1'b1;
								 
							  end
							 
							  else if (o_x_location == 9'd124 && o_y_location == 9'd100) begin 
								  count <= 4'd0;
								  next_direction <= DOWN;
								  left_next <= 1'b0;
								  right_next <= 1'b0;
								  up_next <= 1'b0;
								  down_next <= 1'b1;
								 
							  end
							  
							  else begin
							     count <= 4'd0;
								  case(next_direction)
											  
									  UP: begin
											// case 1.
											if (tile == 4'b0011) begin
												 
												 next_direction <= UP;
												 down_next <= 1'b0;
												 up_next <= 1'b1;
												 right_next <= 1'b0;
												 left_next <= 1'b0;
															
												 case_num <= 4'd1;
												 
											end
												
											// case 2.
											else if (tile == 4'b1010) begin
													
												 next_direction <= RIGHT;
												 down_next <= 1'b0;
												 up_next <= 1'b0;
												 right_next <= 1'b1;
												 left_next <= 1'b0;
															
												 case_num <= 4'd2;
											
											end
												
												// case 3.
											else if (tile == 4'b1001) begin
												 
												 next_direction <= LEFT;
												 down_next <= 1'b0;
												 up_next <= 1'b0;
												 right_next <= 1'b0;
												 left_next <= 1'b1;
												 
												 case_num <= 4'd3;
											end
												
												// case 4.
											else if (tile == 4'b0010) begin
												 
												 
												 case_num <= 4'd4;
												 
												 if (up_distance3 <= right_distance3) begin
													  next_direction <= UP;
													  down_next <= 1'b0;
													  up_next <= 1'b1;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
												 
												 else begin
													  next_direction <= RIGHT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b1;
													  left_next <= 1'b0;
												 end
											end
												
												// case 5.
											else if (tile == 4'b1000) begin
												 
															
												 case_num <= 4'd5;
												 
												 if (left_distance3 <= right_distance3) begin
													  next_direction <= LEFT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b1;
												 end
												 else begin
													  next_direction <= RIGHT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b1;
													  left_next <= 1'b0;
												 end
												 
											end // end case 5.
												
												// case 6.
											else if (tile == 4'b0001) begin
												 
												 
												 case_num <= 4'd6;
												 
												 if (up_distance3 <= left_distance3) begin
													  next_direction <= UP;
													  down_next <= 1'b0;
													  up_next <= 1'b1;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
												 
												 else begin
													  next_direction <= LEFT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b1;
												 end
												 
											end
												
												// case 7.
											else if (tile == 4'b0000) begin
															
												 case_num <= 4'd7;
																			  
												 
												 if (up_distance3 <= left_distance3 && up_distance3 <= right_distance3) begin
													  next_direction <= UP;
													  down_next <= 1'b0;
													  up_next <= 1'b1;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
												 
												 else if (left_distance3 <= up_distance3 && left_distance3 <= right_distance3) begin
													  next_direction <= LEFT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b1;
												 end
												 
												 else begin
													  next_direction <= RIGHT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b1;
													  left_next <= 1'b0;
												 end
											end
												
												// case 8.
											else if (tile == 4'b1011) begin
												 case_num <= 4'd8;
												 next_direction <= DOWN;
												 down_next <= 1'b1;
												 up_next <= 1'b0;
												 right_next <= 1'b0;
												 left_next <= 1'b0;
											end
									 
										end // end UP case.
										  
									  LEFT: begin
											// case 1.
											if (tile == 4'b1100) begin
												  
												 next_direction <= LEFT;
												 down_next <= 1'b0;
												 up_next <= 1'b0;
												 right_next <= 1'b0;
												 left_next <= 1'b1;
															
												 case_num <= 4'd1;
											end
											
											// case 2.
											else if (tile == 4'b0000) begin
														 
												 
												 case_num <= 4'd2;
												 
												 if (up_distance3 <= down_distance3 && up_distance3 <= left_distance3) begin
													  next_direction <= UP;
													  down_next <= 1'b0;
													  up_next <= 1'b1;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
															
												 else if (left_distance3 <= up_distance3 && left_distance3 <= down_distance3) begin
													  next_direction <= LEFT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b1;
												 end
															
												 else begin
													  next_direction <= DOWN;
													  down_next <= 1'b1;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
												 
											end
											
											// case 3.
											else if (tile == 4'b0010) begin
															 
												 case_num <= 4'd3;
														 
											  
												 if (up_distance3 <= down_distance3) begin
													  next_direction <= UP;
													  down_next <= 1'b0;
													  up_next <= 1'b1;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
												 else begin
													  next_direction <= DOWN;
													  down_next <= 1'b1;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
											end
											
											
											// case 6.
											else if (tile == 4'b0100) begin
															 
												 case_num <= 4'd6;
														 
												 
												 if (up_distance3 <= left_distance3) begin
													  next_direction <= UP;
													  down_next <= 1'b0;
													  up_next <= 1'b1;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
												 
												 else begin
													  next_direction <= LEFT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b1;
												 end
											
											end
											
											// case 7.
											else if (tile == 4'b0000) begin
															
												 case_num <= 4'd7;
														 
												
												 if (left_distance3 <= down_distance3) begin
													  next_direction <= LEFT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b1;
												 end
												 
												 else begin
													  next_direction <= DOWN;
													  down_next <= 1'b1;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
											
											end
											
											// case 5.
											else if (tile == 4'b1010) begin
															 
												 case_num <= 4'd5;
														 
												 next_direction <= DOWN;
												 down_next <= 1'b1;
												 up_next <= 1'b0;
												 right_next <= 1'b0;
												 left_next <= 1'b0;
											end
											
											// case 4.
											else if (tile == 4'b0110) begin
													
												 case_num <= 4'd4;
												 next_direction <= UP;
												 down_next <= 1'b0;
												 up_next <= 1'b1;
												 right_next <= 1'b0;
												 left_next <= 1'b0;
	
											end
											
											// case 8.
											else if (tile == 4'b1110) begin
												 next_direction <= RIGHT;
												 down_next <= 1'b0;
												 up_next <= 1'b0;
												 right_next <= 1'b1;
												 left_next <= 1'b0;
												 case_num <= 4'd8;
											end
											
									  end // case LEFT end
										  
									  DOWN: begin
									  
											// case 1.
											if (tile == 4'b0011) begin
															 
															
												 case_num <= 4'd1;
												 next_direction <= DOWN;
												 down_next <= 1'b1;
												 up_next <= 1'b0;
												 right_next <= 1'b0;
												 left_next <= 1'b0;
												 
											end
											
											// case 2.
											else if (tile == 4'b0110) begin
												  
												 next_direction <= RIGHT;
												 down_next <= 1'b0;
												 up_next <= 1'b0;
												 right_next <= 1'b1;
												 left_next <= 1'b0;
															
												 case_num <= 4'd2;
												  
											end
											
											// case 3.
											else if (tile == 4'b0101) begin
												  
												 next_direction <= LEFT;
												 down_next <= 1'b0;
												 up_next <= 1'b0;
												 right_next <= 1'b0;
												 left_next <= 1'b1;
															
												 case_num <= 4'd3;
												 
											end
											
											// case 4.
											else if (tile == 4'b0010) begin
												 
												 case_num <= 4'd4;
												 if (down_distance3 <= right_distance3) begin
													  next_direction <= DOWN;
													  down_next <= 1'b1;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
												 
												 else begin
													  next_direction <= RIGHT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b1;
													  left_next <= 1'b0;
												 end
											
											end
											
											// case 5.
											else if (tile == 4'b0100) begin
												  
												 case_num <= 4'd5;
												 
												 if (left_distance3 <= right_distance3) begin
													  next_direction <= LEFT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b1;
												 end
												 else begin
													  next_direction <= RIGHT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b1;
													  left_next <= 1'b0;
												 end
												 
											end
											
											// case 6.
											else if (tile == 4'b0001) begin
															
												 case_num <= 4'd6;
												 
												 if (left_distance3 <= down_distance3) begin
													  next_direction <= LEFT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b1;
												 end
												 
												 else begin
													  next_direction <= DOWN;
													  down_next <= 1'b1;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
												 
											end
											
											// case 7.
											else if (tile == 4'b0000) begin
	
												 case_num <= 4'd7;
												 
												 if (left_distance3 <= right_distance3 && left_distance3 <= down_distance3) begin
													  next_direction <= LEFT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b1;
												 end
												 
												 else if (down_distance3 <= left_distance3 && down_distance3 <= right_distance3) begin
													  next_direction <= DOWN;
													  down_next <= 1'b1;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
												 
												 else begin
													  next_direction <= RIGHT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b1;
													  left_next <= 1'b0;
												 end
												 
											end
											
											// case 8.
											else if (tile == 4'b0111) begin
												 case_num <= 4'd8;
												 next_direction <= UP;
												 down_next <= 1'b0;
												 up_next <= 1'b1;
												 right_next <= 1'b0;
												 left_next <= 1'b0;
											end
											
									  end // case DOWN end
										  
									  RIGHT: begin
											// case 1.
											if (tile == 4'b1100) begin
												  
													  next_direction <= RIGHT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b1;
													  left_next <= 1'b0;
																  
													  case_num <= 4'd1;
											end
											
											// case 2.
											else if (tile == 4'b1001) begin
													  
													  next_direction <= DOWN;
													  down_next <= 1'b1;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
																  
													  case_num <= 4'd2;
												  
											end
											
											// case 3.
											else if (tile == 4'b0101) begin
												  
												 next_direction <= UP;
												 down_next <= 1'b0;
												 up_next <= 1'b1;
												 right_next <= 1'b0;
												 left_next <= 1'b0;
															
												 case_num <= 4'd3;
											end
											
											// case 4.
											else if (tile == 4'b1000) begin
												  
												 
															
												 case_num <= 4'd4;
												 
												 if (down_distance3 <= right_distance3) begin
													  next_direction <= DOWN;
													  down_next <= 1'b1;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
																  
												 end
												 
												 else begin
													  next_direction <= RIGHT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b1;
													  left_next <= 1'b0;
												 end
												  
											end
											
											// case 5.
											else if (tile == 4'b0001) begin
												
												 case_num <= 4'd5;
												 
												 if (up_distance3 <= down_distance3) begin
													  next_direction <= UP;
													  down_next <= 1'b0;
													  up_next <= 1'b1;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
												 
												 else begin
													  next_direction <= DOWN;
													  down_next <= 1'b1;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
											end
											
											// case 6.
											else if (tile == 4'b0100) begin
													
												 case_num <= 4'd6;
															
												 
												 if (up_distance3 <= right_distance3) begin
													  next_direction <= UP;
													  down_next <= 1'b0;
													  up_next <= 1'b1;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
												 
												 else begin
													  next_direction <= RIGHT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b1;
													  left_next <= 1'b0;
												 end
												  
											end
											
											// case 7.
											else if (tile == 4'b0000) begin
												  
												 case_num <= 4'd7;
															
												 
												 if (up_distance3 <= right_distance3 && up_distance3 <= down_distance3) begin
													  next_direction <= UP;
													  down_next <= 1'b0;
													  up_next <= 1'b1;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
												 
												 else if (down_distance3 <= up_distance3 && down_distance3 <= right_distance3) begin
													  next_direction <= DOWN;
													  down_next <= 1'b1;
													  up_next <= 1'b0;
													  right_next <= 1'b0;
													  left_next <= 1'b0;
												 end
												 
												 else begin
													  next_direction <= RIGHT;
													  down_next <= 1'b0;
													  up_next <= 1'b0;
													  right_next <= 1'b1;
													  left_next <= 1'b0;
												 end
												  
											end
											
											// case 8.
											else if (tile == 4'b1101) begin
												 case_num <= 4'd8;
												 next_direction <= LEFT;
												 down_next <= 1'b0;
												 up_next <= 1'b0;
												 right_next <= 1'b0;
												 left_next <= 1'b1;
											end
											
									  end // case RIGHT end
										
								  endcase
						     end
						 end 
					  
						 
						 
						  else begin
								  reach <= 1'b0;
								  o_x_location <= o_x_location + down_next - up_next;
								  o_y_location <= o_y_location + right_next - left_next;
								
								  count <= count + 1'b1;
								  
							end
					
					 		 
				end
            MODE_CHASE: begin
					 
                if (o_x_location == pac_x && o_y_location == pac_y) begin // catch the target.
                    reach <= 1'b1;
                    count <= 4'd0;
                    // todo
                    
                end
                
                else begin
                    if (count == 4'd8) begin // count = 8, predict next move's next direction.
                        
                        if (i_mode == MODE_SCATTER) begin
                            state <= MODE_SCATTER;
									 count <= 4'd8;
									 blinky_target_x <= 9'd28;
									 blinky_target_y <= 9'd204;
                        end
								
								else if (i_mode == MODE_IDLE) begin
									state <= MODE_IDLE;
								end
								
                        else if (i_mode == MODE_FRIGHTENED) begin
                            state <= MODE_FRIGHTENED;
									 count <= 4'd0; // ?
									 if (next_direction == LEFT) begin
									     next_direction <= RIGHT;
										  up_next <= 1'b0;
										  down_next <= 1'b0;
										  right_next <= 1'b1;
										  left_next <= 1'b0;
									 end
									 else if (next_direction == RIGHT) begin
									     next_direction <= LEFT;
										  up_next <= 1'b0;
										  down_next <= 1'b0;
										  right_next <= 1'b0;
										  left_next <= 1'b1;
									 end
									 else if (next_direction == UP) begin
									     next_direction <= DOWN;
										  up_next <= 1'b0;
										  down_next <= 1'b1;
										  right_next <= 1'b0;
										  left_next <= 1'b0;
									 end
									 else begin // down.
									     next_direction <= UP;
										  up_next <= 1'b1;
										  down_next <= 1'b0;
										  right_next <= 1'b0;
										  left_next <= 1'b0;
									 end
                        end
								
								else if (right_to_left == 1'b1) begin
								    o_x_location <= 10'd132; 
									 o_y_location <= 10'd4;
									 next_direction <= RIGHT;
									 up_next <= 1'b0;
									 down_next <= 1'b0;
									 right_next <= 1'b1;
									 left_next <= 1'b0;
								end
								
								else if (left_to_right == 1'b1) begin
									o_x_location <= 10'd132; 
									o_y_location <= 10'd212;
									next_direction <= LEFT;
									up_next <= 1'b0;
									down_next <= 1'b0;
									right_next <= 1'b0;
									left_next <= 1'b1;
								end
								
								else if (o_x_location == 9'd124 && o_y_location == 9'd100) begin
									  next_direction <= UP;
									  
									  left_next <= 1'b0;
									  right_next <= 1'b0;
									  up_next <= 1'b1;
									  down_next <= 1'b0;
									
									  count <= 4'd0;
									  
							   end
								 
								else if (o_x_location == 9'd116 && o_y_location == 9'd100) begin
									  next_direction <= UP;
									  
									  left_next <= 1'b0;
									  right_next <= 1'b0;
									  up_next <= 1'b1;
									  down_next <= 1'b0;
									
									  count <= 4'd0;
									  
								end 
								
								else if (o_x_location == 9'd132 && o_y_location == 9'd100) begin
									  legal_test <= 1'b1;
									  next_direction <= UP;
									  
									  left_next <= 1'b0;
									  right_next <= 1'b0;
									  up_next <= 1'b1;
									  down_next <= 1'b0;
									
									  count <= 4'd0;
									  
								end
								
								else if (o_x_location == 9'd108 && o_y_location == 9'd100 && legal_test == 1'b1) begin
									  legal_test <= 1'b0;
									  
									  if (left_distance <= right_distance) begin
										  next_direction <= LEFT;
										  
										  left_next <= 1'b1;
										  right_next <= 1'b0;
										  up_next <= 1'b0;
										  down_next <= 1'b0;
										
										  count <= 4'd0;
									  end
									  
									  else begin
									     next_direction <= RIGHT;
										  
										  left_next <= 1'b0;
										  right_next <= 1'b1;
										  up_next <= 1'b0;
										  down_next <= 1'b0;
										
										  count <= 4'd0;
									  end
									  
								end
							
								
											
                        else begin // chase mode.
								
                            state <= MODE_CHASE;
                            count <= 4'd0;
                            case(next_direction)
                                
                                UP: begin
                                    // case 1.
                                    if (tile == 4'b0011) begin
                                        
                                        next_direction <= UP;
                                        down_next <= 1'b0;
                                        up_next <= 1'b1;
                                        right_next <= 1'b0;
                                        left_next <= 1'b0;
                                                
                                        case_num <= 4'd1;
                                        
                                    end
                                    
                                    // case 2.
                                    else if (tile == 4'b1010) begin
                                          
                                        next_direction <= RIGHT;
                                        down_next <= 1'b0;
                                        up_next <= 1'b0;
                                        right_next <= 1'b1;
                                        left_next <= 1'b0;
                                                
                                        case_num <= 4'd2;
                                    
                                    end
                                    
                                    // case 3.
                                    else if (tile == 4'b1001) begin
                                        
                                        next_direction <= LEFT;
                                        down_next <= 1'b0;
                                        up_next <= 1'b0;
                                        right_next <= 1'b0;
                                        left_next <= 1'b1;
                                        
                                        case_num <= 4'd3;
                                    end
                                    
                                    // case 4.
                                    else if (tile == 4'b0010) begin
                                        
                                        
                                        case_num <= 4'd4;
                                        
                                        if (up_distance <= right_distance) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                    end
                                    
                                    // case 5.
                                    else if (tile == 4'b1000) begin
                                        
                                                
                                        case_num <= 4'd5;
                                        
                                        if (left_distance <= right_distance) begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                        
                                    end // end case 5.
                                    
                                    // case 6.
                                    else if (tile == 4'b0001) begin
                                        
                                        
                                        case_num <= 4'd6;
                                        
                                        if (up_distance <= left_distance) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                        
                                    end
                                    
                                    // case 7.
                                    else if (tile == 4'b0000) begin
                                                
                                        case_num <= 4'd7;
                                                              
                                        
                                        if (up_distance <= left_distance && up_distance <= right_distance) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else if (left_distance <= up_distance && left_distance <= right_distance) begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                        
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                    end
                                    
                                    // case 8.
                                    else if (tile == 4'b1011) begin
                                                case_num <= 4'd8;
                                        next_direction <= DOWN;
                                        down_next <= 1'b1;
                                        up_next <= 1'b0;
                                        right_next <= 1'b0;
                                        left_next <= 1'b0;
                                    end
                            
                                end // end UP case.
                                
                                LEFT: begin
                                    // case 1.
                                    if (tile == 4'b1100) begin
                                         
                                        next_direction <= LEFT;
                                        down_next <= 1'b0;
                                        up_next <= 1'b0;
                                        right_next <= 1'b0;
                                        left_next <= 1'b1;
                                                
                                        case_num <= 4'd1;
                                    end
                                    
                                    // case 2.
                                    else if (tile == 4'b0000) begin
                                              
                                        
                                        case_num <= 4'd2;
                                        
                                        if (up_distance <= down_distance && up_distance <= left_distance) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                                
                                        else if (left_distance <= up_distance && left_distance <= down_distance) begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                                
                                        else begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                    end
                                    
                                    // case 3.
                                    else if (tile == 4'b0010) begin
                                                 
                                        case_num <= 4'd3;
                                              
                                      
                                        if (up_distance <= down_distance) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        else begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                    end
                                    
                                    
                                    // case 6.
                                    else if (tile == 4'b0100) begin
                                                 
                                        case_num <= 4'd6;
                                              
                                        
                                        if (up_distance <= left_distance) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                    
                                    end
                                    
                                    // case 7.
                                    else if (tile == 4'b0000) begin
                                                
                                        case_num <= 4'd7;
                                              
                                       
                                        if (left_distance <= down_distance) begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                        
                                        else begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                    
                                    end
                                    
                                    // case 5.
                                    else if (tile == 4'b1010) begin
                                                 
                                        case_num <= 4'd5;
                                              
                                        next_direction <= DOWN;
                                        down_next <= 1'b1;
                                        up_next <= 1'b0;
                                        right_next <= 1'b0;
                                        left_next <= 1'b0;
                                    end
                                    
                                    // case 4.
                                    else if (tile == 4'b0110) begin
                                          
                                        case_num <= 4'd4;
                                        next_direction <= UP;
                                        down_next <= 1'b0;
                                        up_next <= 1'b1;
                                        right_next <= 1'b0;
                                        left_next <= 1'b0;

                                    end
                                    
                                    // case 8.
                                    else if (tile == 4'b1110) begin
                                        next_direction <= RIGHT;
                                        down_next <= 1'b0;
                                        up_next <= 1'b0;
                                        right_next <= 1'b1;
                                        left_next <= 1'b0;
                                        case_num <= 4'd8;
                                    end
                                    
                                end // case LEFT end
                                
                                DOWN: begin
                                
                                    // case 1.
                                    if (tile == 4'b0011) begin
                                                 
                                                
                                        case_num <= 4'd1;
                                        next_direction <= DOWN;
                                        down_next <= 1'b1;
                                        up_next <= 1'b0;
                                        right_next <= 1'b0;
                                        left_next <= 1'b0;
                                        
                                    end
                                    
                                    // case 2.
                                    else if (tile == 4'b0110) begin
                                         
                                        next_direction <= RIGHT;
                                        down_next <= 1'b0;
                                        up_next <= 1'b0;
                                        right_next <= 1'b1;
                                        left_next <= 1'b0;
                                                
                                        case_num <= 4'd2;
                                         
                                    end
                                    
                                    // case 3.
                                    else if (tile == 4'b0101) begin
                                         
                                        next_direction <= LEFT;
                                        down_next <= 1'b0;
                                        up_next <= 1'b0;
                                        right_next <= 1'b0;
                                        left_next <= 1'b1;
                                                
                                        case_num <= 4'd3;
                                        
                                    end
                                    
                                    // case 4.
                                    else if (tile == 4'b0010) begin
                                        
                                        case_num <= 4'd4;
                                        if (down_distance <= right_distance) begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                    
                                    end
                                    
                                    // case 5.
                                    else if (tile == 4'b0100) begin
                                         
                                        case_num <= 4'd5;
                                        
                                        if (left_distance <= right_distance) begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                        
                                    end
                                    
                                    // case 6.
                                    else if (tile == 4'b0001) begin
                                                
                                        case_num <= 4'd6;
                                        
                                        if (left_distance <= down_distance) begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                        
                                        else begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                    end
                                    
                                    // case 7.
                                    else if (tile == 4'b0000) begin

                                        case_num <= 4'd7;
                                        
                                        if (left_distance <= right_distance && left_distance <= down_distance) begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                        
                                        else if (down_distance <= left_distance && down_distance <= right_distance) begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                        
                                    end
                                    
                                    // case 8.
                                    else if (tile == 4'b0111) begin
                                        case_num <= 4'd8;
                                        next_direction <= UP;
                                        down_next <= 1'b0;
                                        up_next <= 1'b1;
                                        right_next <= 1'b0;
                                        left_next <= 1'b0;
                                    end
                                    
                                end // case DOWN end
                                
                                RIGHT: begin
                                    // case 1.
                                    if (tile == 4'b1100) begin
                                         
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                                     
                                            case_num <= 4'd1;
                                    end
                                    
                                    // case 2.
                                    else if (tile == 4'b1001) begin
                                            
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                                     
                                            case_num <= 4'd2;
                                         
                                    end
                                    
                                    // case 3.
                                    else if (tile == 4'b0101) begin
                                         
                                        next_direction <= UP;
                                        down_next <= 1'b0;
                                        up_next <= 1'b1;
                                        right_next <= 1'b0;
                                        left_next <= 1'b0;
                                                
                                        case_num <= 4'd3;
                                    end
                                    
                                    // case 4.
                                    else if (tile == 4'b1000) begin
                                         
                                        
                                                
                                        case_num <= 4'd4;
                                        
                                        if (down_distance <= right_distance) begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                                     
                                        end
                                        
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                         
                                    end
                                    
                                    // case 5.
                                    else if (tile == 4'b0001) begin
                                       
                                        case_num <= 4'd5;
                                        
                                        if (up_distance <= down_distance) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                    end
                                    
                                    // case 6.
                                    else if (tile == 4'b0100) begin
                                          
                                        case_num <= 4'd6;
                                                
                                        
                                        if (up_distance <= right_distance) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                         
                                    end
                                    
                                    // case 7.
                                    else if (tile == 4'b0000) begin
                                         
                                        case_num <= 4'd7;
                                                
                                        
                                        if (up_distance <= right_distance && up_distance <= down_distance) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else if (down_distance <= up_distance && down_distance <= right_distance) begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                         
                                    end
                                    
                                    // case 8.
                                    else if (tile == 4'b1101) begin
                                        case_num <= 4'd8;
                                        next_direction <= LEFT;
                                        down_next <= 1'b0;
                                        up_next <= 1'b0;
                                        right_next <= 1'b0;
                                        left_next <= 1'b1;
                                    end
                                    
                                end // case RIGHT end
                              
                            endcase
                        end 
                    end
                      
                      
                    else begin
                          reach <= 1'b0;
                          o_x_location <= o_x_location + down_next - up_next;
                          o_y_location <= o_y_location + right_next - left_next;
                        
                          count <= count + 1'b1;
                          
                     end
          

                end
            end // end mode chase.
            
            MODE_SCATTER: begin
					 
                if (o_x_location == pac_x && o_y_location == pac_y) begin // catch the target.
                    reach <= 1'b1;
                    count <= 4'd0;
                    // todo
                    
                end
					 
				    
                if (count == 4'd8) begin
							
							if (i_mode == MODE_CHASE) begin
								state <= MODE_CHASE;
								count <= 4'd8;
							end
							
							else if (i_mode == MODE_IDLE) begin
							    state <= MODE_IDLE;
							end
							
							else if (i_mode == MODE_FRIGHTENED) begin
								state <= MODE_FRIGHTENED;
								count <= 4'd0; //?
								
								if (next_direction == LEFT) begin
									 next_direction <= RIGHT;
									 up_next <= 1'b0;
									 down_next <= 1'b0;
									 right_next <= 1'b1;
									 left_next <= 1'b0;
								end
								else if (next_direction == RIGHT) begin
									 next_direction <= LEFT;
									 up_next <= 1'b0;
									 down_next <= 1'b0;
									 right_next <= 1'b0;
									 left_next <= 1'b1;
								end
								else if (next_direction == UP) begin
									 next_direction <= DOWN;
									 up_next <= 1'b0;
									 down_next <= 1'b1;
									 right_next <= 1'b0;
									 left_next <= 1'b0;
								end
								else begin // down.
									 next_direction <= UP;
									 up_next <= 1'b1;
									 down_next <= 1'b0;
									 right_next <= 1'b0;
									 left_next <= 1'b0;
								end
								
							end
							
							else if (o_x_location == 9'd28 && o_y_location == 9'd204) begin
								target1 <= 1'b1;
								count <= 4'd0;
								
								if (next_direction == RIGHT) begin
									next_direction <= DOWN;
									down_next <= 1'b1;
                           up_next <= 1'b0;
                           right_next <= 1'b0;
                           left_next <= 1'b0;
								end
								else begin // up.
									next_direction <= LEFT;
									down_next <= 1'b0;
                           up_next <= 1'b0;
                           right_next <= 1'b0;
                           left_next <= 1'b1;
								end
							end
							
							else if (o_x_location == 9'd28 && o_y_location == 9'd164 && target1 == 1'b1) begin
								count <= 4'd0;
								
								if (next_direction == LEFT) begin
									next_direction <= DOWN;
									down_next <= 1'b1;
                           up_next <= 1'b0;
                           right_next <= 1'b0;
                           left_next <= 1'b0;
								end
								else begin // up.
									next_direction <= RIGHT;
									down_next <= 1'b0;
                           up_next <= 1'b0;
                           right_next <= 1'b1;
                           left_next <= 1'b0;
								end
							end
							
							else if (o_x_location == 9'd60 && o_y_location == 9'd164 && target1 == 1'b1) begin
								count <= 4'd0;
							
								if (next_direction == RIGHT) begin
									next_direction <= UP;
									down_next <= 1'b0;
                           up_next <= 1'b1;
                           right_next <= 1'b0;
                           left_next <= 1'b0;
								end
								else begin // down.
									next_direction <= RIGHT;
									down_next <= 1'b0;
                           up_next <= 1'b0;
                           right_next <= 1'b1;
                           left_next <= 1'b0;
								end
							end
							
							else if (o_x_location == 9'd60 && o_y_location == 9'd204 && target1 == 1'b1) begin
								count <= 4'd0;
							
								if (next_direction == RIGHT) begin
									next_direction <= UP;
									down_next <= 1'b0;
                           up_next <= 1'b1;
                           right_next <= 1'b0;
                           left_next <= 1'b0;
								end
								else begin // down.
									next_direction <= LEFT;
									down_next <= 1'b0;
                           up_next <= 1'b0;
                           right_next <= 1'b0;
                           left_next <= 1'b1;
								end
							end
							
							else if (o_x_location == 9'd124 && o_y_location == 9'd100) begin
								  next_direction <= UP;
								  
								  left_next <= 1'b0;
								  right_next <= 1'b0;
								  up_next <= 1'b1;
								  down_next <= 1'b0;
								
								  count <= 4'd0;
								  
							end
							
							else if (o_x_location == 9'd132 && o_y_location == 9'd100) begin
									  legal_test2 <= 1'b1;
									  next_direction <= UP;
									  
									  left_next <= 1'b0;
									  right_next <= 1'b0;
									  up_next <= 1'b1;
									  down_next <= 1'b0;
									
									  count <= 4'd0;
									  
								end
							 
							else if (o_x_location == 9'd116 && o_y_location == 9'd100) begin
								  next_direction <= UP;
								  
								  left_next <= 1'b0;
								  right_next <= 1'b0;
								  up_next <= 1'b1;
								  down_next <= 1'b0;
								
								  count <= 4'd0;
								  
							end
							else if (o_x_location == 9'd108 && o_y_location == 9'd100 && legal_test2 == 1'b1) begin
									  legal_test2 <= 1'b0;
									  
									  if (left_distance <= right_distance) begin
										  next_direction <= LEFT;
										  
										  left_next <= 1'b1;
										  right_next <= 1'b0;
										  up_next <= 1'b0;
										  down_next <= 1'b0;
										
										  count <= 4'd0;
									  end
									  
									  else begin
									     next_direction <= RIGHT;
										  
										  left_next <= 1'b0;
										  right_next <= 1'b1;
										  up_next <= 1'b0;
										  down_next <= 1'b0;
										
										  count <= 4'd0;
									  end
									  
								end 
							
							else begin// scatter mode.
								state <= MODE_SCATTER;
								count <= 4'd0;
								
								case(next_direction)
                                
                                UP: begin
                                    // case 1.
                                    if (tile == 4'b0011) begin
                                        
                                        next_direction <= UP;
                                        down_next <= 1'b0;
                                        up_next <= 1'b1;
                                        right_next <= 1'b0;
                                        left_next <= 1'b0;
                                                
                                        case_num <= 4'd1;
                                        
                                    end
                                    
                                    // case 2.
                                    else if (tile == 4'b1010) begin
                                          
                                        next_direction <= RIGHT;
                                        down_next <= 1'b0;
                                        up_next <= 1'b0;
                                        right_next <= 1'b1;
                                        left_next <= 1'b0;
                                                
                                        case_num <= 4'd2;
                                    
                                    end
                                    
                                    // case 3.
                                    else if (tile == 4'b1001) begin
                                        
                                        next_direction <= LEFT;
                                        down_next <= 1'b0;
                                        up_next <= 1'b0;
                                        right_next <= 1'b0;
                                        left_next <= 1'b1;
                                        
                                        case_num <= 4'd3;
                                    end
                                    
                                    // case 4.
                                    else if (tile == 4'b0010) begin
                                        
                                        
                                        case_num <= 4'd4;
                                        
                                        if (up_distance2 <= right_distance2) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                    end
                                    
                                    // case 5.
                                    else if (tile == 4'b1000) begin
                                        
                                                
                                        case_num <= 4'd5;
                                        
                                        if (left_distance2 <= right_distance2) begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                        
                                    end // end case 5.
                                    
                                    // case 6.
                                    else if (tile == 4'b0001) begin
                                        
                                        
                                        case_num <= 4'd6;
                                        
                                        if (up_distance2 <= left_distance2) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                        
                                    end
                                    
                                    // case 7.
                                    else if (tile == 4'b0000) begin
                                                
                                        case_num <= 4'd7;
                                                              
                                        
                                        if (up_distance2 <= left_distance2 && up_distance2 <= right_distance2) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else if (left_distance2 <= up_distance2 && left_distance2 <= right_distance2) begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                        
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                    end
                                    
                                    // case 8.
                                    else if (tile == 4'b1011) begin
                                        case_num <= 4'd8;
                                        next_direction <= DOWN;
                                        down_next <= 1'b1;
                                        up_next <= 1'b0;
                                        right_next <= 1'b0;
                                        left_next <= 1'b0;
                                    end
                            
                                end // end UP case.
                                
                                LEFT: begin
                                    // case 1.
                                    if (tile == 4'b1100) begin
                                         
                                        next_direction <= LEFT;
                                        down_next <= 1'b0;
                                        up_next <= 1'b0;
                                        right_next <= 1'b0;
                                        left_next <= 1'b1;
                                                
                                        case_num <= 4'd1;
                                    end
                                    
                                    // case 2.
                                    else if (tile == 4'b0000) begin
                                              
                                        
                                        case_num <= 4'd2;
                                        
                                        if (up_distance2 <= down_distance2 && up_distance2 <= left_distance2) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                                
                                        else if (left_distance2 <= up_distance2 && left_distance2 <= down_distance2) begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                                
                                        else begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                    end
                                    
                                    // case 3.
                                    else if (tile == 4'b0010) begin
                                                 
                                        case_num <= 4'd3;
                                              
                                      
                                        if (up_distance2 <= down_distance2) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        else begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                    end
                                    
                                    
                                    // case 6.
                                    else if (tile == 4'b0100) begin
                                                 
                                        case_num <= 4'd6;
                                              
                                        
                                        if (up_distance2 <= left_distance2) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                    
                                    end
                                    
                                    // case 7.
                                    else if (tile == 4'b0000) begin
                                                
                                        case_num <= 4'd7;
                                              
                                       
                                        if (left_distance2 <= down_distance2) begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                        
                                        else begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                    
                                    end
                                    
                                    // case 5.
                                    else if (tile == 4'b1010) begin
                                                 
                                        case_num <= 4'd5;
                                              
                                        next_direction <= DOWN;
                                        down_next <= 1'b1;
                                        up_next <= 1'b0;
                                        right_next <= 1'b0;
                                        left_next <= 1'b0;
                                    end
                                    
                                    // case 4.
                                    else if (tile == 4'b0110) begin
                                          
                                        case_num <= 4'd4;
                                        next_direction <= UP;
                                        down_next <= 1'b0;
                                        up_next <= 1'b1;
                                        right_next <= 1'b0;
                                        left_next <= 1'b0;

                                    end
                                    
                                    // case 8.
                                    else if (tile == 4'b1110) begin
                                        next_direction <= RIGHT;
                                        down_next <= 1'b0;
                                        up_next <= 1'b0;
                                        right_next <= 1'b1;
                                        left_next <= 1'b0;
                                        case_num <= 4'd8;
                                    end
                                    
                                end // case LEFT end
                                
                                DOWN: begin
                                
                                    // case 1.
                                    if (tile == 4'b0011) begin
                                                 
                                                
                                        case_num <= 4'd1;
                                        next_direction <= DOWN;
                                        down_next <= 1'b1;
                                        up_next <= 1'b0;
                                        right_next <= 1'b0;
                                        left_next <= 1'b0;
                                        
                                    end
                                    
                                    // case 2.
                                    else if (tile == 4'b0110) begin
                                         
                                        next_direction <= RIGHT;
                                        down_next <= 1'b0;
                                        up_next <= 1'b0;
                                        right_next <= 1'b1;
                                        left_next <= 1'b0;
                                                
                                        case_num <= 4'd2;
                                         
                                    end
                                    
                                    // case 3.
                                    else if (tile == 4'b0101) begin
                                         
                                        next_direction <= LEFT;
                                        down_next <= 1'b0;
                                        up_next <= 1'b0;
                                        right_next <= 1'b0;
                                        left_next <= 1'b1;
                                                
                                        case_num <= 4'd3;
                                        
                                    end
                                    
                                    // case 4.
                                    else if (tile == 4'b0010) begin
                                        
                                        case_num <= 4'd4;
                                        if (down_distance2 <= right_distance2) begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                    
                                    end
                                    
                                    // case 5.
                                    else if (tile == 4'b0100) begin
                                         
                                        case_num <= 4'd5;
                                        
                                        if (left_distance2 <= right_distance2) begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                        
                                    end
                                    
                                    // case 6.
                                    else if (tile == 4'b0001) begin
                                                
                                        case_num <= 4'd6;
                                        
                                        if (left_distance2 <= down_distance2) begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                        
                                        else begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                    end
                                    
                                    // case 7.
                                    else if (tile == 4'b0000) begin

                                        case_num <= 4'd7;
                                        
                                        if (left_distance2 <= right_distance2 && left_distance2 <= down_distance2) begin
                                            next_direction <= LEFT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b1;
                                        end
                                        
                                        else if (down_distance2 <= left_distance2 && down_distance2 <= right_distance2) begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                        
                                    end
                                    
                                    // case 8.
                                    else if (tile == 4'b0111) begin
                                        case_num <= 4'd8;
                                        next_direction <= UP;
                                        down_next <= 1'b0;
                                        up_next <= 1'b1;
                                        right_next <= 1'b0;
                                        left_next <= 1'b0;
                                    end
                                    
                                end // case DOWN end
                                
                                RIGHT: begin
                                    // case 1.
                                    if (tile == 4'b1100) begin
                                         
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                                     
                                            case_num <= 4'd1;
                                    end
                                    
                                    // case 2.
                                    else if (tile == 4'b1001) begin
                                            
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                                     
                                            case_num <= 4'd2;
                                         
                                    end
                                    
                                    // case 3.
                                    else if (tile == 4'b0101) begin
                                         
                                        next_direction <= UP;
                                        down_next <= 1'b0;
                                        up_next <= 1'b1;
                                        right_next <= 1'b0;
                                        left_next <= 1'b0;
                                                
                                        case_num <= 4'd3;
                                    end
                                    
                                    // case 4.
                                    else if (tile == 4'b1000) begin
                                         
                                        
                                                
                                        case_num <= 4'd4;
                                        
                                        if (down_distance2 <= right_distance2) begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                                     
                                        end
                                        
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                         
                                    end
                                    
                                    // case 5.
                                    else if (tile == 4'b0001) begin
                                       
                                        case_num <= 4'd5;
                                        
                                        if (up_distance2 <= down_distance2) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                    end
                                    
                                    // case 6.
                                    else if (tile == 4'b0100) begin
                                          
                                        case_num <= 4'd6;
                                                
                                        
                                        if (up_distance2 <= right_distance2) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                         
                                    end
                                    
                                    // case 7.
                                    else if (tile == 4'b0000) begin
                                         
                                        case_num <= 4'd7;
                                                
                                        
                                        if (up_distance2 <= right_distance2 && up_distance2 <= down_distance2) begin
                                            next_direction <= UP;
                                            down_next <= 1'b0;
                                            up_next <= 1'b1;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else if (down_distance2 <= up_distance2 && down_distance2 <= right_distance2) begin
                                            next_direction <= DOWN;
                                            down_next <= 1'b1;
                                            up_next <= 1'b0;
                                            right_next <= 1'b0;
                                            left_next <= 1'b0;
                                        end
                                        
                                        else begin
                                            next_direction <= RIGHT;
                                            down_next <= 1'b0;
                                            up_next <= 1'b0;
                                            right_next <= 1'b1;
                                            left_next <= 1'b0;
                                        end
                                         
                                    end
                                    
                                    // case 8.
                                    else if (tile == 4'b1101) begin
                                        case_num <= 4'd8;
                                        next_direction <= LEFT;
                                        down_next <= 1'b0;
                                        up_next <= 1'b0;
                                        right_next <= 1'b0;
                                        left_next <= 1'b1;
                                    end
                                    
                                end // case RIGHT end
                              
                            endcase
							end
					 end
					 
					 else begin
							o_x_location <= o_x_location + down_next - up_next;
							o_y_location <= o_y_location + right_next - left_next;
							count <= count + 1'b1;
					 end
					 
					 
            end
            
            MODE_FRIGHTENED: begin
					if (count == 4'd8) begin
						if (i_mode == MODE_CHASE) begin
							state <= MODE_CHASE;
							count <= 4'd8;
						end
						else if (i_mode == MODE_IDLE) begin
							state <= MODE_IDLE;
						end
						else if (i_mode == MODE_DIED) begin
							state <= MODE_DIED;
							
							count <= 4'd8; // ?
							 if (next_direction == LEFT) begin
								  next_direction <= RIGHT;
								  up_next <= 1'b0;
								  down_next <= 1'b0;
								  right_next <= 1'b1;
								  left_next <= 1'b0;
							 end
							 else if (next_direction == RIGHT) begin
								  next_direction <= LEFT;
								  up_next <= 1'b0;
								  down_next <= 1'b0;
								  right_next <= 1'b0;
								  left_next <= 1'b1;
							 end
							 else if (next_direction == UP) begin
								  next_direction <= DOWN;
								  up_next <= 1'b0;
								  down_next <= 1'b1;
								  right_next <= 1'b0;
								  left_next <= 1'b0;
							 end
							 else begin // down.
								  next_direction <= UP;
								  up_next <= 1'b1;
								  down_next <= 1'b0;
								  right_next <= 1'b0;
								  left_next <= 1'b0;
							 end
						end
						
						else if (i_mode == MODE_SCATTER) begin
							state <= MODE_SCATTER;
							count <= 4'd8;
							blinky_target_x <= 9'd28;
							blinky_target_y <= 9'd204;
						end
						
						else if (right_to_left == 1'b1) begin
							o_x_location <= 10'd132; 
							o_y_location <= 10'd4;
							next_direction <= RIGHT;
							up_next <= 1'b0;
							down_next <= 1'b0;
							right_next <= 1'b1;
							left_next <= 1'b0;
						end
								
						else if (left_to_right == 1'b1) begin
							o_x_location <= 10'd132; 
							o_y_location <= 10'd212;
							next_direction <= LEFT;
							up_next <= 1'b0;
							down_next <= 1'b0;
							right_next <= 1'b0;
							left_next <= 1'b1;
						end
						
						else begin // frightened mode.
							count <= 4'd0;
							state <= MODE_FRIGHTENED;
							case(next_direction)
                                
								UP: begin
									// case 1.
									if (tile == 4'b0011) begin
										 
										 next_direction <= UP;
										 down_next <= 1'b0;
										 up_next <= 1'b1;
										 right_next <= 1'b0;
										 left_next <= 1'b0;
													
										 case_num <= 4'd1;
										 
									end
													
									// case 2.
									else if (tile == 4'b1010) begin
											
										 next_direction <= RIGHT;
										 down_next <= 1'b0;
										 up_next <= 1'b0;
										 right_next <= 1'b1;
										 left_next <= 1'b0;
													
										 case_num <= 4'd2;
									
									end
									
									// case 3.
									else if (tile == 4'b1001) begin
										 
										 next_direction <= LEFT;
										 down_next <= 1'b0;
										 up_next <= 1'b0;
										 right_next <= 1'b0;
										 left_next <= 1'b1;
										 
										 case_num <= 4'd3;
									end
									
									// case 4.
									else if (tile == 4'b0010) begin
										 
										 case_num <= 4'd4;
										 
										 if (random_move_2 % 2 == 0) begin
											  next_direction <= UP;
											  down_next <= 1'b0;
											  up_next <= 1'b1;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
										 
										 else begin
											  next_direction <= RIGHT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b1;
											  left_next <= 1'b0;
										 end
									end
													
									// case 5.
									else if (tile == 4'b1000) begin
										 
													
										 case_num <= 4'd5;
										 
										 if (random_move_2 % 2 == 0) begin
											  next_direction <= LEFT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b1;
										 end
										 else begin
											  next_direction <= RIGHT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b1;
											  left_next <= 1'b0;
										 end
										 
									end // end case 5.
									
									// case 6.
									else if (tile == 4'b0001) begin
										 
										 
										 case_num <= 4'd6;
										 
										 if (random_move_2 % 2 == 0) begin
											  next_direction <= UP;
											  down_next <= 1'b0;
											  up_next <= 1'b1;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
										 
										 else begin
											  next_direction <= LEFT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b1;
										 end
										 
									end
									
									// case 7.
									else if (tile == 4'b0000) begin
													
										 case_num <= 4'd7;
																	  
										 if (random_move_3 == 4'd1) begin
											  next_direction <= UP;
											  down_next <= 1'b0;
											  up_next <= 1'b1;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
										 
										 else if (random_move_3 == 4'd2) begin
											  next_direction <= LEFT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b1;
										 end
										 
										 else begin
											  next_direction <= RIGHT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b1;
											  left_next <= 1'b0;
										 end
									end
									
									// case 8.
									else if (tile == 4'b1011) begin
										 case_num <= 4'd8;
										 next_direction <= DOWN;
										 down_next <= 1'b1;
										 up_next <= 1'b0;
										 right_next <= 1'b0;
										 left_next <= 1'b0;
									end
						 
							  end // end UP case.
												  
								LEFT: begin
									// case 1.
									if (tile == 4'b1100) begin
										  
										 next_direction <= LEFT;
										 down_next <= 1'b0;
										 up_next <= 1'b0;
										 right_next <= 1'b0;
										 left_next <= 1'b1;
													
										 case_num <= 4'd1;
									end
									
									// case 2.
									else if (tile == 4'b0000) begin
												 
										 
										 case_num <= 4'd2;
										 
										 if (random_move_3 == 4'd1) begin
											  next_direction <= UP;
											  down_next <= 1'b0;
											  up_next <= 1'b1;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
													
										 else if (random_move_3 == 4'd2) begin
											  next_direction <= LEFT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b1;
										 end
													
										 else begin
											  next_direction <= DOWN;
											  down_next <= 1'b1;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
										 
									end
									
									// case 3.
									else if (tile == 4'b0010) begin
													 
										 case_num <= 4'd3;
												 
									  
										 if (random_move_2 % 2 == 0) begin
											  next_direction <= UP;
											  down_next <= 1'b0;
											  up_next <= 1'b1;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
										 else begin
											  next_direction <= DOWN;
											  down_next <= 1'b1;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
									end
									
									
									// case 6.
									else if (tile == 4'b0100) begin
													 
										 case_num <= 4'd6;
												 
										 
										 if (random_move_2 % 2 == 0) begin
											  next_direction <= UP;
											  down_next <= 1'b0;
											  up_next <= 1'b1;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
										 
										 else begin
											  next_direction <= LEFT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b1;
										 end
									
									end
									
									// case 7.
									else if (tile == 4'b0000) begin
													
										 case_num <= 4'd7;
												 
										
										 if (random_move_2 % 2 == 0) begin
											  next_direction <= LEFT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b1;
										 end
										 
										 else begin
											  next_direction <= DOWN;
											  down_next <= 1'b1;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
									
									end
									
									// case 5.
									else if (tile == 4'b1010) begin
													 
										 case_num <= 4'd5;
												 
										 next_direction <= DOWN;
										 down_next <= 1'b1;
										 up_next <= 1'b0;
										 right_next <= 1'b0;
										 left_next <= 1'b0;
									end
									
									// case 4.
									else if (tile == 4'b0110) begin
											
										 case_num <= 4'd4;
										 next_direction <= UP;
										 down_next <= 1'b0;
										 up_next <= 1'b1;
										 right_next <= 1'b0;
										 left_next <= 1'b0;

									end
									
									// case 8.
									else if (tile == 4'b1110) begin
										 next_direction <= RIGHT;
										 down_next <= 1'b0;
										 up_next <= 1'b0;
										 right_next <= 1'b1;
										 left_next <= 1'b0;
										 case_num <= 4'd8;
									end
									
							  end // case LEFT end
							  
							   DOWN: begin
							  
									// case 1.
									if (tile == 4'b0011) begin
													 
													
										 case_num <= 4'd1;
										 next_direction <= DOWN;
										 down_next <= 1'b1;
										 up_next <= 1'b0;
										 right_next <= 1'b0;
										 left_next <= 1'b0;
										 
									end
									
									// case 2.
									else if (tile == 4'b0110) begin
										  
										 next_direction <= RIGHT;
										 down_next <= 1'b0;
										 up_next <= 1'b0;
										 right_next <= 1'b1;
										 left_next <= 1'b0;
													
										 case_num <= 4'd2;
										  
									end
									
									// case 3.
									else if (tile == 4'b0101) begin
										  
										 next_direction <= LEFT;
										 down_next <= 1'b0;
										 up_next <= 1'b0;
										 right_next <= 1'b0;
										 left_next <= 1'b1;
													
										 case_num <= 4'd3;
										 
									end
									
									// case 4.
									else if (tile == 4'b0010) begin
										 
										 case_num <= 4'd4;
										 if (random_move_2 % 2 == 0) begin
											  next_direction <= DOWN;
											  down_next <= 1'b1;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
										 
										 else begin
											  next_direction <= RIGHT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b1;
											  left_next <= 1'b0;
										 end
									
									end
									
									// case 5.
									else if (tile == 4'b0100) begin
										  
										 case_num <= 4'd5;
										 
										 if (random_move_2 % 2 == 0) begin
											  next_direction <= LEFT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b1;
										 end
										 else begin
											  next_direction <= RIGHT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b1;
											  left_next <= 1'b0;
										 end
										 
									end
									
									// case 6.
									else if (tile == 4'b0001) begin
													
										 case_num <= 4'd6;
										 
										 if (random_move_2 % 2 == 0) begin
											  next_direction <= LEFT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b1;
										 end
										 
										 else begin
											  next_direction <= DOWN;
											  down_next <= 1'b1;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
										 
									end
									
									// case 7.
									else if (tile == 4'b0000) begin

										 case_num <= 4'd7;
										 
										 if (random_move_3 == 4'd1) begin
											  next_direction <= LEFT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b1;
										 end
										 
										 else if (random_move_3 == 4'd2) begin
											  next_direction <= DOWN;
											  down_next <= 1'b1;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
										 
										 else begin
											  next_direction <= RIGHT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b1;
											  left_next <= 1'b0;
										 end
										 
									end
									
									// case 8.
									else if (tile == 4'b0111) begin
										 case_num <= 4'd8;
										 next_direction <= UP;
										 down_next <= 1'b0;
										 up_next <= 1'b1;
										 right_next <= 1'b0;
										 left_next <= 1'b0;
									end
									
							  end // case DOWN end
												  
								RIGHT: begin
									// case 1.
									if (tile == 4'b1100) begin
										  
											  next_direction <= RIGHT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b1;
											  left_next <= 1'b0;
														  
											  case_num <= 4'd1;
									end
									
									// case 2.
									else if (tile == 4'b1001) begin
											  
											  next_direction <= DOWN;
											  down_next <= 1'b1;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
														  
											  case_num <= 4'd2;
										  
									end
									
									// case 3.
									else if (tile == 4'b0101) begin
										  
										 next_direction <= UP;
										 down_next <= 1'b0;
										 up_next <= 1'b1;
										 right_next <= 1'b0;
										 left_next <= 1'b0;
													
										 case_num <= 4'd3;
									end
									
									// case 4.
									else if (tile == 4'b1000) begin
										  
										 
													
										 case_num <= 4'd4;
										 
										 if (random_move_2 % 2 == 0) begin
											  next_direction <= DOWN;
											  down_next <= 1'b1;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
														  
										 end
										 
										 else begin
											  next_direction <= RIGHT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b1;
											  left_next <= 1'b0;
										 end
										  
									end
									
									// case 5.
									else if (tile == 4'b0001) begin
										
										 case_num <= 4'd5;
										 
										 if (random_move_2 % 2 == 0) begin
											  next_direction <= UP;
											  down_next <= 1'b0;
											  up_next <= 1'b1;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
										 
										 else begin
											  next_direction <= DOWN;
											  down_next <= 1'b1;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
									end
									
									// case 6.
									else if (tile == 4'b0100) begin
											
										 case_num <= 4'd6;
													
										 
										 if (random_move_2 % 2 == 0) begin
											  next_direction <= UP;
											  down_next <= 1'b0;
											  up_next <= 1'b1;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
										 
										 else begin
											  next_direction <= RIGHT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b1;
											  left_next <= 1'b0;
										 end
										  
									end
									
									// case 7.
									else if (tile == 4'b0000) begin
										  
										 case_num <= 4'd7;
													
										 
										 if (random_move_3 == 4'd1) begin
											  next_direction <= UP;
											  down_next <= 1'b0;
											  up_next <= 1'b1;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
										 
										 else if (random_move_3 == 4'd2) begin
											  next_direction <= DOWN;
											  down_next <= 1'b1;
											  up_next <= 1'b0;
											  right_next <= 1'b0;
											  left_next <= 1'b0;
										 end
										 
										 else begin
											  next_direction <= RIGHT;
											  down_next <= 1'b0;
											  up_next <= 1'b0;
											  right_next <= 1'b1;
											  left_next <= 1'b0;
										 end
										  
									end
									
									// case 8.
									else if (tile == 4'b1101) begin
										 case_num <= 4'd8;
										 next_direction <= LEFT;
										 down_next <= 1'b0;
										 up_next <= 1'b0;
										 right_next <= 1'b0;
										 left_next <= 1'b1;
									end
									
							  end // case RIGHT end
						
                     endcase
						end
					end
					
					else begin
						o_x_location <= o_x_location + down_next - up_next;
                  o_y_location <= o_y_location + right_next - left_next;
                        
                  count <= count + 1'b1;
					end
					
				end
				
        endcase                      
    end
end


    
   




endmodule
