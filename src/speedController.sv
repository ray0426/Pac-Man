module speedController(
    input [2:0] test_bean,
    input [3:0] i_mode,
	input [7:0] i_dots_eaten_counter,
    input [7:0] i_level,
    output [27:0] o_speed
);


// game mode.
parameter MODE_IDLE = 4'd0;
parameter MODE_CHASE = 4'd1;
parameter MODE_SCATTER = 4'd2;
parameter MODE_FRIGHTENED = 4'd3;
parameter MODE_DIED = 4'd4;
parameter MODE_PAUSE = 4'd5;

always_comb begin
    case(i_mode) 
	    MODE_IDLE: begin
		      o_speed = 28'd3125000;
		  end
		  
        MODE_CHASE: begin
            if (i_level == 1) begin
                if (i_dots_eaten_counter <= 7'd15) begin
                    o_speed = 28'd3125000;
                end
                else if (i_dots_eaten_counter <= 7'd30) begin
                    o_speed = 28'd3000000;
                end
                else if (i_dots_eaten_counter <= 7'd60) begin
                    o_speed = 28'd2800000;
                end
                else if (i_dots_eaten_counter <= 7'd200) begin
                    o_speed = 28'd2500000;
                end
                else if (i_dots_eaten_counter <= 7'd230) begin
                    o_speed = 28'd2200000;
                end
                else begin
                    o_speed = 28'd2000000;
                end
            end

            else if (i_level == 2) begin
                if (i_dots_eaten_counter <= 7'd15) begin
                    o_speed = 28'd3000000;
                end
                else if (i_dots_eaten_counter <= 7'd30) begin
                    o_speed = 28'd2800000;
                end
                else if (i_dots_eaten_counter <= 7'd60) begin
                    o_speed = 28'd2500000;
                end
                else if (i_dots_eaten_counter <= 7'd200) begin
                    o_speed = 28'd2300000;
                end
                else if (i_dots_eaten_counter <= 7'd230) begin
                    o_speed = 28'd2000000;
                end
                else begin
                    o_speed = 28'd2000000;
                end

            end

            else begin
                if (i_dots_eaten_counter <= 7'd15) begin
                    o_speed = 28'd2800000;
                end
                else if (i_dots_eaten_counter <= 7'd30) begin
                    o_speed = 28'd2500000;
                end
                else if (i_dots_eaten_counter <= 7'd60) begin
                    o_speed = 28'd2300000;
                end
                else if (i_dots_eaten_counter <= 7'd200) begin
                    o_speed = 28'd2000000;
                end
                else if (i_dots_eaten_counter <= 7'd230) begin
                    o_speed = 28'd1800000;
                end
                else begin
                    o_speed = 28'd1600000;
                end
                
            end

        end

        MODE_DIED: begin
            o_speed = 28'd780000;
        end
		  
		MODE_FRIGHTENED: begin
            if (i_level == 1) begin
			    o_speed = 28'd3125000;
            end
            else if (i_level == 2) begin
                o_speed = 28'd2850000;
            end
            else begin
                o_speed = 28'd2500000;
            end
		end
		  
		  MODE_SCATTER: begin
		    if (i_level == 1) begin
                if (i_dots_eaten_counter <= 7'd15) begin
                    o_speed = 28'd3125000;
                end
                else if (i_dots_eaten_counter <= 7'd30) begin
                    o_speed = 28'd3000000;
                end
                else if (i_dots_eaten_counter <= 7'd60) begin
                    o_speed = 28'd2800000;
                end
                else if (i_dots_eaten_counter <= 7'd200) begin
                    o_speed = 28'd2500000;
                end
                else if (i_dots_eaten_counter <= 7'd230) begin
                    o_speed = 28'd2200000;
                end
                else begin
                    o_speed = 28'd2000000;
                end
            end

            else if (i_level == 2) begin
                if (i_dots_eaten_counter <= 7'd15) begin
                    o_speed = 28'd3000000;
                end
                else if (i_dots_eaten_counter <= 7'd30) begin
                    o_speed = 28'd2800000;
                end
                else if (i_dots_eaten_counter <= 7'd60) begin
                    o_speed = 28'd2500000;
                end
                else if (i_dots_eaten_counter <= 7'd200) begin
                    o_speed = 28'd2300000;
                end
                else if (i_dots_eaten_counter <= 7'd230) begin
                    o_speed = 28'd2000000;
                end
                else begin
                    o_speed = 28'd2000000;
                end

            end

            else begin
                if (i_dots_eaten_counter <= 7'd15) begin
                    o_speed = 28'd2800000;
                end
                else if (i_dots_eaten_counter <= 7'd30) begin
                    o_speed = 28'd2500000;
                end
                else if (i_dots_eaten_counter <= 7'd60) begin
                    o_speed = 28'd2300000;
                end
                else if (i_dots_eaten_counter <= 7'd200) begin
                    o_speed = 28'd2000000;
                end
                else if (i_dots_eaten_counter <= 7'd230) begin
                    o_speed = 28'd1800000;
                end
                else begin
                    o_speed = 28'd1600000;
                end
                
            end
		  end

        default: begin
            o_speed = 28'd6250000;
        end
    endcase

end  
endmodule