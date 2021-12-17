	component CLK_25M is
		port (
			clk_clk       : in  std_logic := 'X'; -- clk
			reset_reset_n : in  std_logic := 'X'; -- reset_n
			clk_25m_clk   : out std_logic         -- clk
		);
	end component CLK_25M;

	u0 : component CLK_25M
		port map (
			clk_clk       => CONNECTED_TO_clk_clk,       --     clk.clk
			reset_reset_n => CONNECTED_TO_reset_reset_n, --   reset.reset_n
			clk_25m_clk   => CONNECTED_TO_clk_25m_clk    -- clk_25m.clk
		);

