module Mem_controller(
    input        i_clk,
    input        i_rst_n,

    input [1:0]  i_mem_select,
	input [4:0]  i_address_map,
	input [7:0]  i_address_char,
	input [5:0]  i_tile_offset,
	input [5:0]  i_char_offset,

    output [7:0] o_VGA_R,
	output [7:0] o_VGA_G,
	output [7:0] o_VGA_B
);

always_comb begin
    if (i_mem_select == 2'b11) begin
        case (i_address_char)
            5'd0: begin
                o_VGA_R = 8'b11111111;
                o_VGA_G = 8'b11111111;
                o_VGA_B = 8'b00000000;
            end
            5'd1: begin
                o_VGA_R = 8'b11111111;
                o_VGA_G = 8'b11001100;
                o_VGA_B = 8'b00000000;
            end
            5'd2: begin
                o_VGA_R = 8'b11111111;
                o_VGA_G = 8'b10011001;
                o_VGA_B = 8'b00000000;
            end
            5'd3: begin
                o_VGA_R = 8'b11001100;
                o_VGA_G = 8'b10011001;
                o_VGA_B = 8'b00000000;
            end
            5'd4: begin
                o_VGA_R = 8'b11111111;
                o_VGA_G = 8'b00000000;
                o_VGA_B = 8'b00000000;
            end
            5'd5: begin
                o_VGA_R = 8'b11111111;
                o_VGA_G = 8'b01100110;
                o_VGA_B = 8'b00000000;
            end
            5'd6: begin
                o_VGA_R = 8'b11111111;
                o_VGA_G = 8'b01010000;
                o_VGA_B = 8'b01010000;
            end
            5'd7: begin
                o_VGA_R = 8'b11001100;
                o_VGA_G = 8'b00000000;
                o_VGA_B = 8'b00000000;
            end
            default: begin
                o_VGA_R = 8'b00000000;
                o_VGA_G = 8'b11111111;
                o_VGA_B = 8'b00000000;
            end
        endcase
    end
    else if (i_mem_select == 2'b01) begin
        case (i_address_map)
            5'd0: begin
                o_VGA_R = 8'b00000000;
                o_VGA_G = 8'b00000000;
                o_VGA_B = 8'b00000000;
            end
            5'd1: begin
                o_VGA_R = 8'b10100110;
                o_VGA_G = 8'b10100110;
                o_VGA_B = 8'b10100110;
            end
            default: begin
                o_VGA_R = 8'b00000000;
                o_VGA_G = 8'b00000000;
                o_VGA_B = 8'b11111111;
            end
        endcase
    end
    else begin
        o_VGA_R = 8'b00000000;
        o_VGA_G = 8'b00000000;
        o_VGA_B = 8'b00000000;
    end
end

endmodule