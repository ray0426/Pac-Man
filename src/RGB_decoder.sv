module RGB_decoder(
    input [3:0]  i_data,
    output [7:0] o_VGA_R,
	output [7:0] o_VGA_G,
	output [7:0] o_VGA_B
);

always_comb begin
    case (i_data)
        4'd0 : begin
            o_VGA_R = 8'd0;
            o_VGA_G = 8'd0;
            o_VGA_B = 8'd0;
        end
        4'd1 : begin
            o_VGA_R = 8'd0;
            o_VGA_G = 8'd0;
            o_VGA_B = 8'd255;
        end
        4'd2 : begin
            o_VGA_R = 8'd255;
            o_VGA_G = 8'd255;
            o_VGA_B = 8'd255;
        end
        4'd3 : begin
            o_VGA_R = 8'd255;
            o_VGA_G = 8'd255;
            o_VGA_B = 8'd0;
        end
        4'd4 : begin
            o_VGA_R = 8'd255;
            o_VGA_G = 8'd0;
            o_VGA_B = 8'd0;
        end
        4'd5 : begin
            o_VGA_R = 8'd255;
            o_VGA_G = 8'd204;
            o_VGA_B = 8'd255;
        end
        4'd6 : begin
            o_VGA_R = 8'd79;
            o_VGA_G = 8'd255;
            o_VGA_B = 8'd255;
        end
        4'd7 : begin
            o_VGA_R = 8'd255;
            o_VGA_G = 8'd204;
            o_VGA_B = 8'd0;
        end
        default : begin
            o_VGA_R = 8'd255;
            o_VGA_G = 8'd255;
            o_VGA_B = 8'd255;
        end
    endcase
end

endmodule