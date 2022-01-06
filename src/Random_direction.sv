module Random_direction (
    input i_clk,
    input i_rst_n,
    output [3:0] random_move
);

logic [3:0] o_random_out;

Random random_generator (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .o_random_out(o_random_out)
);

always_comb begin
    case(o_random_out)
        4'd0: random_move = 4'd1;
        4'd1: random_move = 4'd2;
        4'd2: random_move = 4'd3;
        4'd3: random_move = 4'd1;
        4'd4: random_move = 4'd2;
        4'd5: random_move = 4'd3;
        4'd6: random_move = 4'd1;
        4'd7: random_move = 4'd2;
        4'd8: random_move = 4'd3;
        4'd9: random_move = 4'd1;
        4'd10: random_move = 4'd2;
        4'd11: random_move = 4'd3;
        4'd12: random_move = 4'd1;
        4'd13: random_move = 4'd2;
        4'd14: random_move = 4'd3;
        4'd15: random_move = 4'd1;
        default: random_move = 4'd2;
    endcase 
end

endmodule
