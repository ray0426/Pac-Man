module DE2_115 (
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,

	// VGA
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_R,
	output [7:0] VGA_G,
	output [7:0] VGA_B,
	output VGA_HS,
	output VGA_SYNC_N,
	output VGA_VS,

	// AUDIO
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	inout AUD_DACLRCK,
	output AUD_XCK,

	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	output I2C_SCLK,
	inout I2C_SDAT,
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,

	// SDRAM
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,

	// SRAM
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,

	// Flash
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,

	inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO
);

wire       w_show_en;     // 1 when in display time
wire [9:0] w_vga_x_cord;  // next pixel cordinate,  x
wire [9:0] w_vga_y_cord;  // next pixel cordinate,  y

wire CLOCK_25;     // 25MHz clock from pll
wire rst_main;     // main reset, high active

assign rst_main = SW[17];

CLK_25M clk_25m(
	.clk_clk(CLOCK_50),       //     clk.clk
	.clk_25m_clk(CLOCK_25),   // clk_25m.clk
	.reset_reset_n(~rst_main)  //   reset.reset_n
);

VGA vga(
	.i_rst_n(~rst_main),
	.i_clk_25M(CLOCK_25),
	// .VGA_R(VGA_R),
	// .VGA_G(VGA_G),
	// .VGA_B(VGA_B),
	.VGA_BLANK_N(VGA_BLANK_N),
	.VGA_CLK(VGA_CLK),
	.VGA_HS(VGA_HS),
	.VGA_SYNC_N(VGA_SYNC_N),
	.VGA_VS(VGA_VS),

	.o_show_en(w_show_en),     
	.o_x_cord(w_vga_x_cord),
	.o_y_cord(w_vga_y_cord)
	// .i_pixel_value(pixel_value),
	// .i_start_display(start),
	// .test(LEDG[2])
);

wire [7:0] w_map[0:35][0:27];
wire [9:0] w_pacman_x;
wire [9:0] w_pacman_y;
wire [9:0] w_ghost1_x;
wire [9:0] w_ghost1_y;
wire [1:0] w_mem_select;
wire [4:0] w_address_map;
wire [7:0] w_address_char;
wire [5:0] w_tile_offset;
wire [5:0] w_char_offset;

Vga_Mem_addr_generator vga_mem_addr_generator(
	.i_clk(CLOCK_50),
	.i_rst_n(~rst_main),

	.i_show_en(w_show_en),     
	.i_x_cord(w_vga_x_cord),
	.i_y_cord(w_vga_y_cord),

	.i_map(w_map),
	.i_pacman_x(w_pacman_x),
	.i_pacman_y(w_pacman_y),
	.i_ghost1_x(w_ghost1_x),
	.i_ghost1_y(w_ghost1_y),

	.o_mem_select(w_mem_select),
	.o_address_map(w_address_map),
	.o_address_char(w_address_char),
	.o_tile_offset(w_tile_offset),
	.o_char_offset(w_char_offset)
);

Mem_controller mam_controller(
    .i_clk(CLOCK_50),
    .i_rst_n(~rst_main),

    .i_mem_select(w_mem_select),
	.i_address_map(w_address_map),
	.i_address_char(w_address_char),
	.i_tile_offset(w_tile_offset),
	.i_char_offset(w_char_offset),

	.o_VGA_R(VGA_R),
	.o_VGA_G(VGA_G),
	.o_VGA_B(VGA_B)
);

Board_controller board_controller(
    .o_board(w_map)
);

wire w_left, w_right, w_up, w_down;

Test_show_pacman test_show_pacman(
    .i_clk(CLOCK_50),
    .i_rst_n(~rst_main),
    .i_up(w_up & SW[0]),
    .i_down(w_down & SW[0]),
    .i_left(w_left & SW[0]),
    .i_right(w_right & SW[0]),
    .w_pacman_x(w_pacman_x),
    .w_pacman_y(w_pacman_y)
);

Test_show_pacman test_show_ghost(
    .i_clk(CLOCK_50),
    .i_rst_n(~rst_main),
    .i_up(w_up & ~SW[0]),
    .i_down(w_down & ~SW[0]),
    .i_left(w_left & ~SW[0]),
    .i_right(w_right & ~SW[0]),
    .w_pacman_x(w_ghost1_x),
    .w_pacman_y(w_ghost1_y)
);

Debounce key_left(  .i_in(KEY[3]),	.i_clk(CLOCK_50), .o_pos(w_left));
Debounce key_up(    .i_in(KEY[2]),	.i_clk(CLOCK_50), .o_pos(w_up));
Debounce key_down(  .i_in(KEY[1]),	.i_clk(CLOCK_50), .o_pos(w_down));
Debounce key_right( .i_in(KEY[0]),	.i_clk(CLOCK_50), .o_pos(w_right));

// for future use or debug
assign HEX0 = 7'b1111001;
assign HEX1 = 7'b1111001;
assign HEX2 = 7'b1111001;
assign HEX3 = 7'b1111001;
assign HEX4 = 7'b1111001;
assign HEX5 = 7'b1111001;
assign HEX6 = 7'b1111001;
assign HEX7 = 7'b1111001;

endmodule