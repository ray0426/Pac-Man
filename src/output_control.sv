// Hexadecimal numbers
`define HEX_0 4'h0
`define HEX_1 4'h1
`define HEX_2 4'h2
`define HEX_3 4'h3
`define HEX_4 4'h4
`define HEX_5 4'h5
`define HEX_6 4'h6
`define HEX_7 4'h7
`define HEX_8 4'h8
`define HEX_9 4'h9
`define HEX_A 4'hA
`define HEX_B 4'hB
`define HEX_C 4'hC
`define HEX_D 4'hD
`define HEX_E 4'hE
`define HEX_F 4'hF

// Extend keys
`define EX 1'b1
`define NOT_EX 1'b0

parameter DIRECTION_UP = 3'b000;
parameter DIRECTION_DOWN = 3'b001;
parameter DIRECTION_LEFT = 3'b010;
parameter DIRECTION_RIGHT = 3'b011;

module output_control (
clk,
rst,
last_change,  // last_change from KeyboardDecoder.v
key_command  // encoded keyboard number
    );

input clk;
input rst;
input [7:0] last_change;
output reg [2:0] key_command; // W: UP(1), S: DOWN(2), A: LEFT(3), D:RIGHT(4)

always_ff @(posedge clk) begin
	if (rst) begin
		key_command <= 3'd111; 
	end
	
	else begin
		case (last_change)
			 8'h1D : key_command <= DIRECTION_UP; // W: UP
			 8'h1B : key_command <= DIRECTION_DOWN; // S: DOWN
			 8'h1C : key_command <= DIRECTION_LEFT; // A: LEFT
			 8'h23 : key_command <= DIRECTION_RIGHT; // D: RIGHT
			 default: key_command <= key_command;
		endcase
	end
	
end   
endmodule
