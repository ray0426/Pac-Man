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
// wire [9:0] w_ghost1_x;
// wire [9:0] w_ghost1_y;
wire [9:0] w_blinky_x;
wire [9:0] w_blinky_y;
wire [9:0] w_pinky_x;
wire [9:0] w_pinky_y;
wire [9:0] w_inky_x;
wire [9:0] w_inky_y;
wire [9:0] w_clyde_x;
wire [9:0] w_clyde_y;
wire [1:0] w_mem_select;
wire [7:0] w_address_map;
wire [7:0] w_address_char;
wire [7:0] w_address_item; // tbc
wire [5:0] w_tile_offset;
wire [5:0] w_char_offset;

Vga_Mem_addr_generator vga_mem_addr_generator(
	.i_clk(CLOCK_50),
	.i_rst_n(~rst_main),

	.i_show_en(w_show_en),     
	.i_x_cord(w_vga_x_cord),
	.i_y_cord(w_vga_y_cord),

	.i_map(w_map),
	.i_items(w_items),
	.i_pacman_x(w_pacman_x),
	.i_pacman_y(w_pacman_y),
	.i_blinky_x(w_blinky_x),
	.i_blinky_y(w_blinky_y),
	.i_pinky_x(w_pinky_x),
	.i_pinky_y(w_pinky_y),
	.i_inky_x(w_inky_x),
	.i_inky_y(w_inky_y),
	.i_clyde_x(w_clyde_x),
	.i_clyde_y(w_clyde_y),

	.o_mem_select(w_mem_select),
	.o_address_map(w_address_map),
	.o_address_char(w_address_char),
	.o_address_item(w_address_item),
	.o_tile_offset(w_tile_offset),
	.o_char_offset(w_char_offset)
);

Mem_controller mam_controller(
	.i_clk(CLOCK_50),
	.i_rst_n(~rst_main),

	.i_mem_select(w_mem_select),
	.i_address_map(w_address_map),
	.i_address_char(w_address_char),
	.i_address_item(w_address_item),
	.i_tile_offset(w_tile_offset),
	.i_char_offset(w_char_offset),

	.o_VGA_R(VGA_R),
	.o_VGA_G(VGA_G),
	.o_VGA_B(VGA_B)
);

wire [3:0] w_game_state;
wire       w_board_reload;
wire       w_board_reload_done;
wire       w_pacman_eaten;
wire       w_dot_clear;
wire       w_ghost_reload;
wire       w_pacman_reload;       // to be connected
wire [7:0] w_level;               // to be connected

assign LEDG[3:0] = w_game_state;

assign w_dot_clear = (w_dots_counter == 0);

Game_controller game_controller(
	.i_clk(CLOCK_50),
	.i_rst_n(~rst_main),
	.i_game_start(KEY[0]),
	.i_game_pause(SW[16]),
	.i_board_reload_done(w_board_reload_done),
	.i_items_reload_done(w_items_reload_done),   // tbc
	.i_pacman_eaten(w_pacman_eaten),
	.i_dot_clear(w_dot_clear),

	.o_game_state(w_game_state),
	.o_board_reload(w_board_reload),
	.o_items_reload(w_items_reload),
	.o_ghost_reload(w_ghost_reload),
	.o_pacman_reload(w_pacman_reload),
	.o_level(w_level)
	//,	.d_lives()
);

wire       w_items_reload;          // to be connect, from game ctrl
wire       w_item_eaten;            
wire [1:0] w_item_eaten_type;       
wire [5:0] w_item_eaten_x;          
wire [5:0] w_item_eaten_y;          
wire [1:0] w_items[0:35][0:27];     // to be connect, for vga and collision ctrl
wire [7:0] w_dots_counter;          // for game ctrl
wire [7:0] w_dots_eaten_counter;    // to be connect, for ghost ctrl
wire [3:0] w_energizer_counter;     // to be connect
wire       w_items_reload_done;

Items_controller items_controller(
    .i_clk(CLOCK_50),
    .i_rst_n(~rst_main),
    .i_items_reload(w_items_reload),             // i_items_map must be ready when i_items_relaod
    .i_item_eaten(w_item_eaten),
    .i_item_eaten_type(w_item_eaten_type),
    .i_item_x(w_item_eaten_x),
    .i_item_y(w_item_eaten_y),

	.o_reload_done(w_items_reload_done),
    .o_items(w_items),   // 0: none, 1: dot, 2:energizer
    .o_dots_counter(w_dots_counter),
    .o_dots_eaten_counter(w_dots_eaten_counter),
    .o_energizer_counter(w_energizer_counter)
);

wire w_blinky_eaten;
wire w_pinky_eaten;
wire w_inky_eaten;
wire w_clyde_eaten;
wire w_blinky_returned;
wire w_pinky_returned;
wire w_inky_returned;
wire w_clyde_returned;
wire [3:0] w_blinky_state;
wire [3:0] w_pinky_state;
wire [3:0] w_inky_state;
wire [3:0] w_clyde_state;

Ghost_controller ghost_controller(
    .i_clk(CLOCK_50),
    .i_rst_n(~rst_main),
    .i_game_state(w_game_state),
    .i_ghost_reload(w_ghost_reload),
    .i_energizers_eaten(w_item_eaten && (w_item_eaten_type == I_ENERGIZER)),
    .i_blinky_eaten(w_blinky_eaten),
    .i_pinky_eaten(w_pinky_eaten),
    .i_inky_eaten(w_inky_eaten),
    .i_clyde_eaten(w_clyde_eaten),
    .i_blinky_returned(w_blinky_returned),
    .i_pinky_returned(w_pinky_returned),
    .i_inky_returned(w_inky_returned),
    .i_clyde_returned(w_clyde_returned),

    .o_blinky_state(w_blinky_state),
    .o_pinky_state(w_pinky_state),
    .o_inky_state(w_inky_state),
    .o_clyde_state(w_clyde_state),
);

Collision_controller collision_controller(
    .i_clk(CLOCK_50),
    .i_rst_n(~rst_main),
    .i_game_state(w_game_state),
    .i_items(w_items),
    .i_pacman_x(w_pacman_x >> 3),
	.i_pacman_y(w_pacman_y >> 3),
	.i_blinky_x(w_blinky_x >> 3),
	.i_blinky_y(w_blinky_y >> 3),
	.i_pinky_x(w_pinky_x >> 3),
	.i_pinky_y(w_pinky_y >> 3),
	.i_inky_x(w_inky_x >> 3),
	.i_inky_y(w_inky_y >> 3),
	.i_clyde_x(w_clyde_x >> 3),
	.i_clyde_y(w_clyde_y >> 3),
    .i_blinky_state(w_blinky_state),
    .i_pinky_state(w_pinky_state),
    .i_inky_state(w_inky_state),
    .i_clyde_state(w_clyde_state),

    .o_item_eaten(w_item_eaten),
    .o_item_eaten_type(w_item_eaten_type),
    .o_item_eaten_x(w_item_eaten_x),
    .o_item_eaten_y(w_item_eaten_y),
    .o_pacman_eaten(w_pacman_eaten),
    .o_blinky_eaten(w_blinky_eaten),
    .o_pinky_eaten(w_pinky_eaten),
    .o_inky_eaten(w_inky_eaten),
    .o_clyde_eaten(w_clyde_eaten)
);

Board_controller board_controller(
	.i_clk(CLOCK_50),
	.i_rst_n(~rst_main),

	.i_reload(w_board_reload),
	.o_reload_done(w_board_reload_done),
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

Test_show_pacman test_show_blinky(
    .i_clk(CLOCK_50),
    .i_rst_n(~rst_main),
    .i_up(   w_up    & ~SW[0] & (~SW[2] & ~SW[1])),
    .i_down( w_down  & ~SW[0] & (~SW[2] & ~SW[1])),
    .i_left( w_left  & ~SW[0] & (~SW[2] & ~SW[1])),
    .i_right(w_right & ~SW[0] & (~SW[2] & ~SW[1])),
    .w_pacman_x(w_blinky_x),
    .w_pacman_y(w_blinky_y)
);

Test_show_pacman test_show_pinky(
    .i_clk(CLOCK_50),
    .i_rst_n(~rst_main),
    .i_up(   w_up    & ~SW[0] & (~SW[2] &  SW[1])),
    .i_down( w_down  & ~SW[0] & (~SW[2] &  SW[1])),
    .i_left( w_left  & ~SW[0] & (~SW[2] &  SW[1])),
    .i_right(w_right & ~SW[0] & (~SW[2] &  SW[1])),
    .w_pacman_x(w_pinky_x),
    .w_pacman_y(w_pinky_y)
);

Test_show_pacman test_show_inky(
    .i_clk(CLOCK_50),
    .i_rst_n(~rst_main),
    .i_up(   w_up    & ~SW[0] & ( SW[2] & ~SW[1])),
    .i_down( w_down  & ~SW[0] & ( SW[2] & ~SW[1])),
    .i_left( w_left  & ~SW[0] & ( SW[2] & ~SW[1])),
    .i_right(w_right & ~SW[0] & ( SW[2] & ~SW[1])),
    .w_pacman_x(w_inky_x),
    .w_pacman_y(w_inky_y)
);

Test_show_pacman test_show_clyde(
    .i_clk(CLOCK_50),
    .i_rst_n(~rst_main),
    .i_up(   w_up    & ~SW[0] & ( SW[2] &  SW[1])),
    .i_down( w_down  & ~SW[0] & ( SW[2] &  SW[1])),
    .i_left( w_left  & ~SW[0] & ( SW[2] &  SW[1])),
    .i_right(w_right & ~SW[0] & ( SW[2] &  SW[1])),
    .w_pacman_x(w_clyde_x),
    .w_pacman_y(w_clyde_y)
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