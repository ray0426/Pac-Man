module Random (
	input        i_clk,
	input        i_rst_n,
	output [3:0] o_random_out
);

// ===== Output Buffers =====
// logic [3:0] o_random_out_r, o_random_out_w;

// ===== Registers & Wires =====
logic [15:0] counter_r;
logic counter_w;

// ===== Output Assignments =====
assign o_random_out = counter_r[3:0];


// ===== Combinational Circuits =====
always_comb begin
	counter_w = counter_r[10] ^ counter_r[12] ^ counter_r[13] ^ counter_r[15] ^ '1;
end



// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		counter_r <= 16'd0;
	end
	else begin
		counter_r <= {counter_r[14:0], counter_w};
	end
end

endmodule
