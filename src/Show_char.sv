module Show_char(
    input  [9:0]   i_x_cord,               // 0~287
	input  [9:0]   i_y_cord,               // 0~223
	input  [9:0]   i_char_x,               // 0~479
	input  [9:0]   i_char_y,     

    output         o_overlap,
    output [1:0]   o_part_offset,          // which part 0, 1, 2, 3
    output [5:0]   o_char_offset           // pixel in this part
);

wire [2:0] x_offset, y_offset;
assign o_char_offset = x_offset * 8 + y_offset;

// 0, 1
// 2, 3

always_comb begin
    if      (i_x_cord >= i_char_x   & i_x_cord < i_char_x+8  & i_y_cord >= i_char_y   & i_y_cord < i_char_y+8)  begin
        o_overlap = 1;
        o_part_offset = 0;
        x_offset = i_x_cord - i_char_x;
        y_offset = i_y_cord - i_char_y;
    end
    else if (i_x_cord >= i_char_x+8 & i_x_cord < i_char_x+16 & i_y_cord >= i_char_y   & i_y_cord < i_char_y+8)  begin
        o_overlap = 1;
        o_part_offset = 1;
        x_offset = i_x_cord - i_char_x - 8;
        y_offset = i_y_cord - i_char_y;
    end
    else if (i_x_cord >= i_char_x   & i_x_cord < i_char_x+8  & i_y_cord >= i_char_y+8 & i_y_cord < i_char_y+16) begin
        o_overlap = 1;
        o_part_offset = 2;
        x_offset = i_x_cord - i_char_x;
        y_offset = i_y_cord - i_char_y - 8;
    end
    else if (i_x_cord >= i_char_x+8 & i_x_cord < i_char_x+16 & i_y_cord >= i_char_y+8 & i_y_cord < i_char_y+16) begin
        o_overlap = 1;
        o_part_offset = 3;
        x_offset = i_x_cord - i_char_x - 8;
        y_offset = i_y_cord - i_char_y - 8;
    end
    else begin
        o_overlap = 0;
        o_part_offset = 0;
        x_offset = 0;
        y_offset = 0;
        // cross over map to be done
        // if ((i_x_cord >= 272 & i_y_cord < 208) & (i_char_x < )) begin
            
        // end
        // else if (i_x_cord < 272 & i_y_cord >= 208) begin
            
        // end
        // else if (i_x_cord >= 272 & i_y_cord >= 208) begin
            
        // end
        // else begin
            
        // end
    end
end

endmodule