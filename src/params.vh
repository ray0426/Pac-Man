`ifndef _PARAMS_VH_
`define _PARAMS_VH_

// game state
parameter GS_INIT         = 4'd0;
parameter GS_IDLE         = 4'd1;
parameter GS_RELOAD       = 4'd2;
parameter GS_PLAY         = 4'd3;
parameter GS_PAUSE        = 4'd4;
parameter GS_CLEAR        = 4'd5;
parameter GS_GAMEOVER     = 4'd6;

// ghost state
parameter G_IDLE          = 4'd0;
parameter G_CHASE         = 4'd1;
parameter G_SCATTER       = 4'd2;
parameter G_FRIGHTENED    = 4'd3;
parameter G_DIE           = 4'd4;

// chase or scatter
parameter CHASE      = 4'd0;
parameter SCATTER    = 4'd1;
parameter FRIGHTENED = 4'd2;

// item type
parameter I_NONE       = 2'd0;
parameter I_DOT        = 2'd1;
parameter I_ENERGIZER  = 2'd2;

parameter TILE_BLANK      = 8'd0;
parameter TILE_WALL       = 8'd1;

`endif