`include "params.vh"

module Ghost_anime_select(
    input         i_clk,
    input         i_rst_n,
	 
	 input [9:0] i_pacman_x,
	 input [9:0] i_pacman_y,
	 input [9:0] i_blinky_x,
	 input [9:0] i_blinky_y,
	 input [9:0] i_pinky_x,
	 input [9:0] i_pinky_y,
	 input [9:0] i_clyde_x,
	 input [9:0] i_clyde_y,
	 input [9:0] i_inky_x,
	 input [9:0] i_inky_y,
	 input i_frightened_mode_come_to_end,
    input  [3:0]  i_which_char,
    input  [3:0]  i_blinky_state,
    input  [3:0]  i_pinky_state,
    input  [3:0]  i_inky_state,
    input  [3:0]  i_clyde_state,
    input  [1:0]  i_pacman_direction,
	input  [1:0]  i_blinky_direction,
	input  [1:0]  i_pinky_direction,
	input  [1:0]  i_inky_direction,
	input  [1:0]  i_clyde_direction,

    output [3:0] o_pacman_pose,
    output [3:0] o_ghost_pose
);

// assign o_pacman_pose = i_pacman_direction;


always_comb begin
	case(i_pacman_direction)
		2'd0: begin // UP
			if (i_pacman_x % 8 == 0 || i_pacman_x % 8 == 1 || i_pacman_x % 8 == 6) begin
				o_pacman_pose = 2'd0;
			end
			else if (i_pacman_x % 8 == 2 || i_pacman_x % 8 == 3 || i_pacman_x % 8 == 7) begin
				o_pacman_pose = 2'd0 + 3'd4;
			end
			else begin // 4, 5
				o_pacman_pose = 4'd8;
			end
		end
		
		2'd1: begin // DOWN
			if (i_pacman_x % 8 == 0 || i_pacman_x % 8 == 1 || i_pacman_x % 8 == 6) begin
				o_pacman_pose = 2'd1;
			end
			else if (i_pacman_x % 8 == 2 || i_pacman_x % 8 == 3 || i_pacman_x % 8 == 7) begin
				o_pacman_pose = 2'd1 + 3'd4;
			end
			else begin // 4, 5
				o_pacman_pose = 4'd8;
			end
		end
		
		2'd2: begin // LEFT
			if (i_pacman_y % 8 == 0 || i_pacman_y % 8 == 1 || i_pacman_y % 8 == 6) begin
				o_pacman_pose = 2'd2;
			end
			else if (i_pacman_y % 8 == 2 || i_pacman_y % 8 == 3 || i_pacman_y % 8 == 7) begin
				o_pacman_pose = 2'd2 + 3'd4;
			end
			else begin // 4, 5
				o_pacman_pose = 4'd8;
			end
		end
		
		2'd3: begin // RIGHT
			if (i_pacman_y % 8 == 0 || i_pacman_y % 8 == 1 || i_pacman_y % 8 == 6) begin
				o_pacman_pose = 2'd3;
			end
			else if (i_pacman_y % 8 == 2 || i_pacman_y % 8 == 3 || i_pacman_y % 8 == 7) begin
				o_pacman_pose = 2'd3 + 3'd4;
			end
			else begin // 4, 5
				o_pacman_pose = 4'd8;
			end
		end
	endcase
		
		
end

wire [3:0] ghost_state;
wire [1:0] ghost_direction;
wire [9:0] ghost_x, ghost_y;

always_comb begin
    case (i_which_char)
        4'd1   : begin  // blinky
            ghost_direction = i_blinky_direction;
            ghost_state = i_blinky_state;
				ghost_x = i_blinky_x;
				ghost_y = i_blinky_y;
        end
        4'd2   : begin  // pinky
            ghost_direction = i_pinky_direction;
            ghost_state = i_pinky_state;
				ghost_x = i_pinky_x;
				ghost_y = i_pinky_y;
        end
        4'd3   : begin  // inky
            ghost_direction = i_inky_direction;
            ghost_state = i_inky_state;
				ghost_x = i_inky_x;
				ghost_y = i_inky_y;
        end
        4'd4   : begin  // clyde
            ghost_direction = i_clyde_direction;
            ghost_state = i_clyde_state;
				ghost_x = i_clyde_x;
				ghost_y = i_clyde_y;
        end
        default: begin
            ghost_direction = 0;
            ghost_state = 0;
				ghost_x = i_clyde_x;
				ghost_y = i_clyde_y;
        end
    endcase
end


always_comb begin
    case (ghost_state)
        G_IDLE       : begin
		      if (ghost_direction == 2'd0) begin // UP
					if (ghost_x % 8 == 0 || ghost_x % 8 == 1 || ghost_x % 8 == 4 || ghost_x % 8 == 5) begin
					    o_ghost_pose = ghost_direction << 1;
					end
					else begin
					    o_ghost_pose = (ghost_direction << 1) + 1'd1;
					end
				end
				
				else if (ghost_direction == 2'd1) begin // DOWN
					if (ghost_x % 8 == 0 || ghost_x % 8 == 1 || ghost_x % 8 == 4 || ghost_x % 8 == 5) begin
					    o_ghost_pose = ghost_direction << 1;
					end
					else begin
					    o_ghost_pose = (ghost_direction << 1) + 1'd1;
					end
				end
				
				else if (ghost_direction == 2'd2) begin // LEFT
					if (ghost_y % 8 == 0 || ghost_y % 8 == 1 || ghost_y % 8 == 4 || ghost_y % 8 == 5) begin
					    o_ghost_pose = ghost_direction << 1;
					end
					else begin
					    o_ghost_pose = (ghost_direction << 1) + 1'd1;
					end
				end
				
				else begin // RIGHT
					if (ghost_y % 8 == 0 || ghost_y % 8 == 1 || ghost_y % 8 == 4 || ghost_y % 8 == 5) begin
					    o_ghost_pose = ghost_direction << 1;
					end
					else begin
					    o_ghost_pose = (ghost_direction << 1) + 1'd1;
					end
				end
            
            // o_ghost_pose = ghost_direction << 1;
        end
        G_CHASE      : begin
		      if (ghost_direction == 2'd0) begin // UP
					if (ghost_x % 8 == 0 || ghost_x % 8 == 1 || ghost_x % 8 == 4 || ghost_x % 8 == 5) begin
					    o_ghost_pose = ghost_direction << 1;
					end
					else begin
					    o_ghost_pose = (ghost_direction << 1) + 1'd1;
					end
				end
				
				else if (ghost_direction == 2'd1) begin // DOWN
					if (ghost_x % 8 == 0 || ghost_x % 8 == 1 || ghost_x % 8 == 4 || ghost_x % 8 == 5) begin
					    o_ghost_pose = ghost_direction << 1;
					end
					else begin
					    o_ghost_pose = (ghost_direction << 1) + 1'd1;
					end
				end
				
				else if (ghost_direction == 2'd2) begin // LEFT
					if (ghost_y % 8 == 0 || ghost_y % 8 == 1 || ghost_y % 8 == 4 || ghost_y % 8 == 5) begin
					    o_ghost_pose = ghost_direction << 1;
					end
					else begin
					    o_ghost_pose = (ghost_direction << 1) + 1'd1;
					end
				end
				
				else begin // RIGHT
					if (ghost_y % 8 == 0 || ghost_y % 8 == 1 || ghost_y % 8 == 4 || ghost_y % 8 == 5) begin
					    o_ghost_pose = ghost_direction << 1;
					end
					else begin
					    o_ghost_pose = (ghost_direction << 1) + 1'd1;
					end
				end
            
        end
        G_SCATTER    : begin
            if (ghost_direction == 2'd0) begin // UP
					if (ghost_x % 8 == 0 || ghost_x % 8 == 1 || ghost_x % 8 == 4 || ghost_x % 8 == 5) begin
					    o_ghost_pose = ghost_direction << 1;
					end
					else begin
					    o_ghost_pose = (ghost_direction << 1) + 1'd1;
					end
				end
				
				else if (ghost_direction == 2'd1) begin // DOWN
					if (ghost_x % 8 == 0 || ghost_x % 8 == 1 || ghost_x % 8 == 4 || ghost_x % 8 == 5) begin
					    o_ghost_pose = ghost_direction << 1;
					end
					else begin
					    o_ghost_pose = (ghost_direction << 1) + 1'd1;
					end
				end
				
				else if (ghost_direction == 2'd2) begin // LEFT
					if (ghost_y % 8 == 0 || ghost_y % 8 == 1 || ghost_y % 8 == 4 || ghost_y % 8 == 5) begin
					    o_ghost_pose = ghost_direction << 1;
					end
					else begin
					    o_ghost_pose = (ghost_direction << 1) + 1'd1;
					end
				end
				
				else begin // RIGHT
					if (ghost_y % 8 == 0 || ghost_y % 8 == 1 || ghost_y % 8 == 4 || ghost_y % 8 == 5) begin
					    o_ghost_pose = ghost_direction << 1;
					end
					else begin
					    o_ghost_pose = (ghost_direction << 1) + 1'd1;
					end
				end
        end
        G_FRIGHTENED : begin
		      if (ghost_direction == 2'd0) begin // UP
					if (i_frightened_mode_come_to_end == 1'b0) begin
						if (ghost_x % 8 == 0 || ghost_x % 8 == 1 || ghost_x % 8 == 4 || ghost_x % 8 == 5) begin
							 o_ghost_pose = 4'd8;
						end
						else begin
							 o_ghost_pose = 4'd8 + 1'd1;
						end
					end
					
					else begin // i_frightened_mode_come_to_end = 1'b1
					   if (ghost_x % 8 == 0 || ghost_x % 8 == 1) begin
							 o_ghost_pose = 4'd8;
						end
						else if (ghost_x % 8 == 2 || ghost_x % 8 == 3) begin
							 o_ghost_pose = 4'd8 + 2'd3;
						end
						else if (ghost_x % 8 == 4 || ghost_x % 8 == 5) begin
							 o_ghost_pose = 4'd8 + 1'd1;
						end
						else begin
						    o_ghost_pose = 4'd8 + 2'd2;
						end
					end
				
				end
				
				else if (ghost_direction == 2'd1) begin // DOWN
					if (i_frightened_mode_come_to_end == 1'b0) begin
						if (ghost_x % 8 == 0 || ghost_x % 8 == 1 || ghost_x % 8 == 4 || ghost_x % 8 == 5) begin
							 o_ghost_pose = 4'd8;
						end
						else begin
							 o_ghost_pose = 4'd8 + 1'd1;
						end
					end
					
					else begin // i_frightened_mode_come_to_end = 1'b1
					   if (ghost_x % 8 == 0 || ghost_x % 8 == 1) begin
							 o_ghost_pose = 4'd8;
						end
						else if (ghost_x % 8 == 2 || ghost_x % 8 == 3) begin
							 o_ghost_pose = 4'd8 + 2'd3;
						end
						else if (ghost_x % 8 == 4 || ghost_x % 8 == 5) begin
							 o_ghost_pose = 4'd8 + 1'd1;
						end
						else begin
						    o_ghost_pose = 4'd8 + 2'd2;
						end
					end
				end
				
				else if (ghost_direction == 2'd2) begin // LEFT
					if (i_frightened_mode_come_to_end == 1'b0) begin
						if (ghost_y % 8 == 0 || ghost_y % 8 == 1 || ghost_y % 8 == 4 || ghost_y % 8 == 5) begin
							 o_ghost_pose = 4'd8;
						end
						else begin
							 o_ghost_pose = 4'd8 + 1'd1;
						end
					end
					
					else begin // i_frightened_mode_come_to_end = 1'b1
					   if (ghost_y % 8 == 0 || ghost_y % 8 == 1) begin
							 o_ghost_pose = 4'd8;
						end
						else if (ghost_y % 8 == 2 || ghost_y % 8 == 3) begin
							 o_ghost_pose = 4'd8 + 2'd3;
						end
						else if (ghost_y % 8 == 4 || ghost_y % 8 == 5) begin
							 o_ghost_pose = 4'd8 + 1'd1;
						end
						else begin
						    o_ghost_pose = 4'd8 + 2'd2;
						end
					end
				end
				
				else begin // RIGHT
					if (i_frightened_mode_come_to_end == 1'b0) begin
						if (ghost_y % 8 == 0 || ghost_y % 8 == 1 || ghost_y % 8 == 4 || ghost_y % 8 == 5) begin
							 o_ghost_pose = 4'd8;
						end
						else begin
							 o_ghost_pose = 4'd8 + 1'd1;
						end
					end
					
					else begin // i_frightened_mode_come_to_end = 1'b1
					   if (ghost_y % 8 == 0 || ghost_y % 8 == 1) begin
							 o_ghost_pose = 4'd8;
						end
						else if (ghost_y % 8 == 2 || ghost_y % 8 == 3) begin
							 o_ghost_pose = 4'd8 + 2'd3;
						end
						else if (ghost_y % 8 == 4 || ghost_y % 8 == 5) begin
							 o_ghost_pose = 4'd8 + 1'd1;
						end
						else begin
						    o_ghost_pose = 4'd8 + 2'd2;
						end
					end
				end
            
        end
        G_DIE        : begin
            o_ghost_pose = 4'd12 + ghost_direction;
        end
        default      : begin
            o_ghost_pose = 4'd0;
        end
    endcase
end

endmodule