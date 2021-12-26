module Mem_controller(
    input        i_clk,
    input        i_rst_n,

    input [1:0]  i_mem_select,
	input [7:0]  i_address_map,
	input [7:0]  i_address_char,
	input [5:0]  i_tile_offset,
	input [5:0]  i_char_offset,

    output [7:0] o_VGA_R,
	output [7:0] o_VGA_G,
	output [7:0] o_VGA_B
);

wire [11:0] w_address_tile;
wire [3:0]  empty_data;
wire        never_write;
wire [3:0]  w_data, w_data_tile, w_data_char;
assign empty_data = 8'b0000;
assign never_write = 1'b0;
assign w_data = (i_mem_select[1] == 0) ? w_data_tile : w_data_char;

// input	[11:0]  address;
// input	  clock;
// input	[3:0]  data;
// input	  wren;
// output	[3:0]  q;

Tileset_Ram tileset_ram(
	.address(w_address_tile),
	.clock(i_clk),
	.data(empty_data),
	.wren(never_write),
	.q(w_data_tile)
);

// Char_Ram

wire [7:0] w_VGA_R;
wire [7:0] w_VGA_G;
wire [7:0] w_VGA_B;

RGB_decoder rgb_decoder(
    .i_data(w_data),
    .o_VGA_R(w_VGA_R),
	.o_VGA_G(w_VGA_G),
	.o_VGA_B(w_VGA_B)
);

always_comb begin
    if (i_mem_select == 2'b11) begin
        w_address_tile = 0;
        case (i_address_char >> 2)
            5'd0: begin
                w_data_char = 4'd3;
            end
            5'd1: begin
                w_data_char = 4'd4;
            end
            5'd2: begin
                w_data_char = 4'd4;
            end
            5'd3: begin
                w_data_char = 4'd4;
            end
            5'd4: begin
                w_data_char = 4'd4;
            end
            default: begin
                w_data_char = 4'd2;
            end
        endcase
        o_VGA_R = w_VGA_R;
        o_VGA_G = w_VGA_G;
        o_VGA_B = w_VGA_B;
        // case (i_address_char)
        //     5'd0: begin
        //         o_VGA_R = 8'b11111111;
        //         o_VGA_G = 8'b11111111;
        //         o_VGA_B = 8'b00000000;
        //     end
        //     5'd1: begin
        //         o_VGA_R = 8'b11111111;
        //         o_VGA_G = 8'b11001100;
        //         o_VGA_B = 8'b00000000;
        //     end
        //     5'd2: begin
        //         o_VGA_R = 8'b11111111;
        //         o_VGA_G = 8'b10011001;
        //         o_VGA_B = 8'b00000000;
        //     end
        //     5'd3: begin
        //         o_VGA_R = 8'b11001100;
        //         o_VGA_G = 8'b10011001;
        //         o_VGA_B = 8'b00000000;
        //     end
        //     5'd4: begin
        //         o_VGA_R = 8'b11111111;
        //         o_VGA_G = 8'b00000000;
        //         o_VGA_B = 8'b00000000;
        //     end
        //     5'd5: begin
        //         o_VGA_R = 8'b11111111;
        //         o_VGA_G = 8'b01100110;
        //         o_VGA_B = 8'b00000000;
        //     end
        //     5'd6: begin
        //         o_VGA_R = 8'b11111111;
        //         o_VGA_G = 8'b01010000;
        //         o_VGA_B = 8'b01010000;
        //     end
        //     5'd7: begin
        //         o_VGA_R = 8'b11001100;
        //         o_VGA_G = 8'b00000000;
        //         o_VGA_B = 8'b00000000;
        //     end
        //     default: begin
        //         o_VGA_R = 8'b00000000;
        //         o_VGA_G = 8'b11111111;
        //         o_VGA_B = 8'b00000000;
        //     end
        // endcase
    end
    else if (i_mem_select == 2'b01) begin
        w_address_tile = i_address_map[5:0] * 64 + i_tile_offset;
        w_data_char = 4'd2;
        o_VGA_R = w_VGA_R;
        o_VGA_G = w_VGA_G;
        o_VGA_B = w_VGA_B;
        // case (i_address_map)
        //     5'd0: begin
        //         o_VGA_R = 8'b00000000;
        //         o_VGA_G = 8'b00000000;
        //         o_VGA_B = 8'b00000000;
        //     end
        //     5'd1: begin
        //         o_VGA_R = 8'b10100110;
        //         o_VGA_G = 8'b10100110;
        //         o_VGA_B = 8'b10100110;
        //     end
        //     default: begin
        //         o_VGA_R = 8'b00000000;
        //         o_VGA_G = 8'b00000000;
        //         o_VGA_B = 8'b11111111;
        //     end
        // endcase
    end
    else begin
        w_address_tile = 0;
        w_data_char = 4'd2;
        o_VGA_R = 8'b11111111;  // for debug, may be 00000000
        o_VGA_G = 8'b11111111;
        o_VGA_B = 8'b11111111;
    end
end

endmodule