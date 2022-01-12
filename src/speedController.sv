module speedController(
    input [2:0] test_bean,
    input [3:0] i_mode,
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
            if (test_bean == 3'b001) begin
                o_speed = 28'd3125000;
            end
            else if (test_bean == 3'b011) begin
                o_speed = 28'd1562500;
            end
            else if (test_bean == 3'b111) begin
                o_speed = 28'd781250;
            end
            else begin
                o_speed = 28'd6250000;
            end

        end

        MODE_DIED: begin
            o_speed = 28'd781250;
        end
		  
		  MODE_FRIGHTENED: begin
				o_speed = 28'd3125000;
		  end
		  
		  MODE_SCATTER: begin
		      if (test_bean == 3'b001) begin
                o_speed = 28'd3125000;
            end
            else if (test_bean == 3'b011) begin
                o_speed = 28'd1562500;
            end
            else if (test_bean == 3'b111) begin
                o_speed = 28'd781250;
            end
            else begin
                o_speed = 28'd6250000;
            end
		  end

        default: begin
            o_speed = 28'd6250000;
        end
    endcase

end  
endmodule