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
wire [9:0] w_blinky_x;
wire [9:0] w_blinky_y;
wire [9:0] w_pinky_x;
wire [9:0] w_pinky_y;
wire [9:0] w_inky_x;
wire [9:0] w_inky_y;
wire [9:0] w_clyde_x;
wire [9:0] w_clyde_y;
wire [5:0] w_pacman_x_tile;
wire [5:0] w_pacman_y_tile;
wire [5:0] w_blinky_x_tile;
wire [5:0] w_blinky_y_tile;
wire [5:0] w_pinky_x_tile;
wire [5:0] w_pinky_y_tile;
wire [5:0] w_inky_x_tile;
wire [5:0] w_inky_y_tile;
wire [5:0] w_clyde_x_tile;
wire [5:0] w_clyde_y_tile;
wire [1:0] w_mem_select;
wire [7:0] w_address_map;
wire [3:0] w_which_char;
wire [7:0] w_address_item; // tbc
wire [5:0] w_tile_offset;
wire [7:0] w_char_offset;

assign w_pacman_x_tile = (w_pacman_x + 4) >> 3;
assign w_pacman_y_tile = (w_pacman_y + 4) >> 3;
assign w_blinky_x_tile = (w_blinky_x + 4) >> 3;
assign w_blinky_y_tile = (w_blinky_y + 4) >> 3;
assign w_pinky_x_tile = (w_pinky_x + 4) >> 3;
assign w_pinky_y_tile = (w_pinky_y + 4) >> 3;
assign w_inky_x_tile = (w_inky_x + 4) >> 3;
assign w_inky_y_tile = (w_inky_y + 4) >> 3;
assign w_clyde_x_tile = (w_clyde_x + 4) >> 3;
assign w_clyde_y_tile = (w_clyde_y + 4) >> 3;

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
	.o_which_char(w_which_char),
	.o_address_item(w_address_item),
	.o_tile_offset(w_tile_offset),
	.o_char_offset(w_char_offset)
);

wire [1:0] w_pacman_direction;
wire [1:0] w_blinky_direction, w_pinky_direction, w_inky_direction, w_clyde_direction;

Mem_controller mam_controller(
	.i_clk(CLOCK_50),
	.i_rst_n(~rst_main),

	.i_mem_select(w_mem_select),
	.i_address_map(w_address_map),
	.i_which_char(w_which_char),
	.i_address_item(w_address_item),
	.i_tile_offset(w_tile_offset),
	.i_char_offset(w_char_offset),

	.i_blinky_state(w_blinky_state),
    .i_pinky_state(w_pinky_state),
    .i_inky_state(w_inky_state),
    .i_clyde_state(w_clyde_state),

	.i_pacman_direction(w_pacman_direction),
	.i_blinky_direction(w_blinky_direction),
	.i_pinky_direction(w_pinky_direction),
	.i_inky_direction(w_inky_direction),
	.i_clyde_direction(w_clyde_direction),

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
assign LEDR[3:0] = SW[2] ? 
	(SW[1] ? w_inky_state : w_clyde_state) :
	(SW[1] ? w_pinky_state : w_blinky_state);
assign LEDR[17:12] = SW[14] ? 
	(SW[15] ? w_blinky_y_tile : w_blinky_x_tile) : 
	(SW[15] ? w_pacman_y_tile : w_pacman_x_tile);

assign w_dot_clear = (w_dots_counter == 0);

Game_controller game_controller(
	.i_clk(CLOCK_50),
	.i_rst_n(~rst_main),
	.i_game_start(w_right),
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
	, .d_lives(LEDR[9:6])
	, .d_reloads(LEDR[5:4])
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

PacmanMove pacmanMove(
    .i_clk(CLOCK_50),
    .i_rst_n(~rst_main),
    .i_up((w_up & SW[0]) || (key_command == 2'b00)),
    .i_down((w_down & SW[0]) || (key_command == 2'b01)),
    .i_left((w_left & SW[0]) || (key_command == 2'b10)),
    .i_right((w_right & SW[0]) || (key_command == 2'b11)),
    .i_map(w_map),
    .i_pacman_reload(w_pacman_reload),

    //output [3:0] debug_dir,

    .w_pacman_x(w_pacman_x),
    .w_pacman_y(w_pacman_y)
	,    .cur_dir(w_pacman_direction)
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

GhostAlgo_Blinky Blinky_move (
	.test_bean({SW[10], SW[9], SW[8]}),
    .i_clk(CLOCK_50), // 請接CLOCK_50
    .i_rst(rst_main),   // 功能跟i_pacman_reload一樣，要接的話隨便找一個SW
    .i_pacman_reload(w_ghost_reload), // 之前說到的reload
    .pac_x(w_pacman_x),  // 小精靈的x座標
    .pac_y(w_pacman_y),  // 小精靈的y座標
    .i_board(w_map),     // 接遊戲地圖
    .i_mode(w_blinky_state),     // 接遊戲模式(Chase, Scatter, Frightened, IDLE, DIED)
    //.random_move_2(random_move_2),
    //.random_move_3(random_move_3),
    .o_x_location(w_blinky_x),  // 鬼魂的輸出位置(x座標)
    .o_y_location(w_blinky_y),  // 鬼魂的輸出位置(y座標)
    //.reach(reach_blinky),     // 在chase或frightened模式，小精靈的位置是否等於鬼魂
    .died_arrive_home(w_blinky_returned), // 在DIED模式中，鬼魂是否返回到重生點了，抵達時=1'b1
    .next_direction(w_blinky_direction), // 鬼魂目前行走的方向

    // debug用的
    .test_distance(test_distance1),
    .illegal(illegal1),
    .case_num(case_num_blinky),
    .mode_state(mode_state_1)
);

GhostAlgo_Pinky Pinky_move (
	 .test_bean({SW[10], SW[9], SW[8]}),
    .i_clk(CLOCK_50), // 請接CLOCK_50
    .i_rst(rst_main),   // 功能跟i_pacman_reload一樣，要接的話隨便找一個SW
    .i_pacman_reload(w_ghost_reload), // 之前說到的reload
    .pac_x(w_pacman_x),  // 小精靈的x座標
    .pac_y(w_pacman_y),  // 小精靈的y座標
    .i_board(w_map),     // 接遊戲地圖
    .i_mode(w_pinky_state),     // 接遊戲模式(Chase, Scatter, Frightened, IDLE, DIED)
	 .pac_direction(pac_direction),
    //.random_move_2(random_move_2),
    //.random_move_3(random_move_3),
    .o_x_location(w_pinky_x),  // 鬼魂的輸出位置(x座標)
    .o_y_location(w_pinky_y),  // 鬼魂的輸出位置(y座標)
    //.reach(reach_blinky),     // 在chase或frightened模式，小精靈的位置是否等於鬼魂
    .died_arrive_home(w_pinky_returned), // 在DIED模式中，鬼魂是否返回到重生點了，抵達時=1'b1
    .next_direction(w_pinky_direction), // 鬼魂目前行走的方向

    // debug用的
    .test_distance(test_distance2),
    .illegal(illegal2),
    .case_num(case_num_pinky),
    .mode_state(mode_state_2)
);


GhostAlgo_Inky inky_move (
    .test_bean({SW[10], SW[9], SW[8]}),
    .i_clk(CLOCK_50), // 請接CLOCK_50
    .i_rst(rst_main),   // 功能跟i_pacman_reload一樣，要接的話隨便找一個SW
    .i_pacman_reload(w_ghost_reload), // 之前說到的reload
    .pac_x(w_pacman_x),  // 小精靈的x座標
    .pac_y(w_pacman_y),  // 小精靈的y座標
    .i_board(w_map),     // 接遊戲地圖
    .i_mode(w_inky_state),     // 接遊戲模式(Chase, Scatter, Frightened, IDLE, DIED)
	 .pac_direction(pac_direction),
	 .blinky_x(w_blinky_x),
	 .blinky_y(w_blinky_y),
    //.random_move_2(random_move_2),
    //.random_move_3(random_move_3),
    .o_x_location(w_inky_x),  // 鬼魂的輸出位置(x座標)
    .o_y_location(w_inky_y),  // 鬼魂的輸出位置(y座標)
    //.reach(reach_blinky),     // 在chase或frightened模式，小精靈的位置是否等於鬼魂
    .died_arrive_home(w_inky_returned), // 在DIED模式中，鬼魂是否返回到重生點了，抵達時=1'b1
    .next_direction(w_inky_direction), // 鬼魂目前行走的方向

    // debug用的
    .test_distance(test_distance4),
    .illegal(illegal4),
    .case_num(case_num_inky),
    .mode_state(mode_state_4)
);

GhostAlgo_Clyde clyde_move (
    .test_bean({SW[10], SW[9], SW[8]}),
    .i_clk(CLOCK_50), // 請接CLOCK_50
    .i_rst(rst_main),   // 功能跟i_pacman_reload一樣，要接的話隨便找一個SW
    .i_pacman_reload(w_ghost_reload), // 之前說到的reload
    .pac_x(w_pacman_x),  // 小精靈的x座標
    .pac_y(w_pacman_y),  // 小精靈的y座標
    .i_board(w_map),     // 接遊戲地圖
    .i_mode(w_clyde_state),     // 接遊戲模式(Chase, Scatter, Frightened, IDLE, DIED)
    //.random_move_2(random_move_2),
    //.random_move_3(random_move_3),
    .o_x_location(w_clyde_x),  // 鬼魂的輸出位置(x座標)
    .o_y_location(w_clyde_y),  // 鬼魂的輸出位置(y座標)
    //.reach(reach_blinky),     // 在chase或frightened模式，小精靈的位置是否等於鬼魂
    .died_arrive_home(w_clyde_returned), // 在DIED模式中，鬼魂是否返回到重生點了，抵達時=1'b1
    .next_direction(w_clyde_direction), // 鬼魂目前行走的方向

    // debug用的
    .test_distance(test_distance3),
    .illegal(illegal3),
    .case_num(case_num_clyde),
    .mode_state(mode_state_3)
);
Collision_controller collision_controller(
    .i_clk(CLOCK_50),
    .i_rst_n(~rst_main),
    .i_game_state(w_game_state),
    .i_items(w_items),
    .i_pacman_x(w_pacman_x_tile),
	.i_pacman_y(w_pacman_y_tile),
	.i_blinky_x(w_blinky_x_tile),
	.i_blinky_y(w_blinky_y_tile),
	.i_pinky_x(w_pinky_x_tile),
	.i_pinky_y(w_pinky_y_tile),
	.i_inky_x(w_inky_x_tile),
	.i_inky_y(w_inky_y_tile),
	.i_clyde_x(w_clyde_x_tile),
	.i_clyde_y(w_clyde_y_tile),
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

// Board_controller board_controller(
// 	.i_clk(CLOCK_50),
// 	.i_rst_n(~rst_main),

// 	.i_reload(w_board_reload),
// 	.o_reload_done(w_board_reload_done),
// 	.o_board(w_map)
// );

Board_controller board_controller(
	.o_board(w_map)
);

wire w_left, w_right, w_up, w_down;

// Test_show_pacman test_show_pacman(
//     .i_clk(CLOCK_50),
//     .i_rst_n(~rst_main),
//     .i_up(w_up & SW[0]),
//     .i_down(w_down & SW[0]),
//     .i_left(w_left & SW[0]),
//     .i_right(w_right & SW[0]),
//     .w_pacman_x(w_pacman_x),
//     .w_pacman_y(w_pacman_y)
// );

// Test_show_pacman test_show_blinky(
//     .i_clk(CLOCK_50),
//     .i_rst_n(~rst_main),
//     .i_up(   w_up    & ~SW[0] & (~SW[2] & ~SW[1])),
//     .i_down( w_down  & ~SW[0] & (~SW[2] & ~SW[1])),
//     .i_left( w_left  & ~SW[0] & (~SW[2] & ~SW[1])),
//     .i_right(w_right & ~SW[0] & (~SW[2] & ~SW[1])),
//     .w_pacman_x(w_blinky_x),
//     .w_pacman_y(w_blinky_y)
// );

// Test_show_pacman test_show_pinky(
//     .i_clk(CLOCK_50),
//     .i_rst_n(~rst_main),
//     .i_up(   w_up    & ~SW[0] & (~SW[2] &  SW[1])),
//     .i_down( w_down  & ~SW[0] & (~SW[2] &  SW[1])),
//     .i_left( w_left  & ~SW[0] & (~SW[2] &  SW[1])),
//     .i_right(w_right & ~SW[0] & (~SW[2] &  SW[1])),
//     .w_pacman_x(w_pinky_x),
//     .w_pacman_y(w_pinky_y)
// );

// Test_show_pacman test_show_inky(
//     .i_clk(CLOCK_50),
//     .i_rst_n(~rst_main),
//     .i_up(   w_up    & ~SW[0] & ( SW[2] & ~SW[1])),
//     .i_down( w_down  & ~SW[0] & ( SW[2] & ~SW[1])),
//     .i_left( w_left  & ~SW[0] & ( SW[2] & ~SW[1])),
//     .i_right(w_right & ~SW[0] & ( SW[2] & ~SW[1])),
//     .w_pacman_x(w_inky_x),
//     .w_pacman_y(w_inky_y)
// );

// Test_show_pacman test_show_clyde(
//     .i_clk(CLOCK_50),
//     .i_rst_n(~rst_main),
//     .i_up(   w_up    & ~SW[0] & ( SW[2] &  SW[1])),
//     .i_down( w_down  & ~SW[0] & ( SW[2] &  SW[1])),
//     .i_left( w_left  & ~SW[0] & ( SW[2] &  SW[1])),
//     .i_right(w_right & ~SW[0] & ( SW[2] &  SW[1])),
//     .w_pacman_x(w_clyde_x),
//     .w_pacman_y(w_clyde_y)
// );

Debounce key_left(  .i_in(KEY[3]),	.i_clk(CLOCK_50), .o_pos(w_left));
Debounce key_up(    .i_in(KEY[2]),	.i_clk(CLOCK_50), .o_pos(w_up));
Debounce key_down(  .i_in(KEY[1]),	.i_clk(CLOCK_50), .o_pos(w_down));
Debounce key_right( .i_in(KEY[0]),	.i_clk(CLOCK_50), .o_pos(w_right));


// Part of keyboard.
// W: UP(0), S: DOWN(1), A: LEFT(2), D:RIGHT(3).
logic [3:0] keyboard_output;
logic [7:0] key_out;
logic [1:0] key_command;
keyboard_buffer keyboard_buffer0 (key_out, PS2_DAT, PS2_CLK, CLOCK_50, rst_main);

output_control output_controller (
	.clk(CLOCK_50),
	.rst(rst_main),
	.last_change(key_out),
	.key_command(key_command)
);

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