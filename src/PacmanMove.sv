module PacmanMove (
    input        i_clk,
    input        i_rst_n,
    input        i_up,
    input        i_down,
    input        i_left,
    input        i_right,
    input  [7:0] i_map[0:35][0:27],
    input        i_pacman_reload,

    //output [3:0] debug_dir,

    output [9:0] w_pacman_x,
    output [9:0] w_pacman_y,
    output [1:0] cur_dir
);
    logic [31:0]counter_r;
    logic [31:0]counter_n;

    logic [9:0] px_r;
    logic [9:0] px_n;
    logic [9:0] py_r;
    logic [9:0] py_n;
    logic [3:0] cur_dir_n;
    logic [3:0] cur_dir_r;

    // ???
    logic [3:0] next_dir_n;

    // wire
    logic can_left;
    logic can_up;
    logic can_down;
    logic can_right;
    logic [7:0] cur_x;
    logic [7:0] cur_y;
    logic [7:0] left_x;
    logic [7:0] left_y;
    logic [7:0] up_x;
    logic [7:0] up_y;
    logic [7:0] down_x;
    logic [7:0] down_y;
    logic [7:0] right_x;
    logic [7:0] right_y;

    localparam LIMITMOVECOUNTER = 32'd2000000;
    localparam OFFSETX = 10'd4;
    localparam OFFSETY = 10'd4;
    localparam LEFT = 4'b1000;
    localparam UP   = 4'b0100;
    localparam DOWN = 4'b0010;
    localparam RIGHT= 4'b0001;

    assign w_pacman_x = px_n;
    assign w_pacman_y = py_n;
    assign cur_dir = cur_dir_n == UP? 0: cur_dir_n == DOWN ? 1 : cur_dir_n == LEFT? 2: cur_dir_n == RIGHT? 3 : 0;
    assign cur_x  = (px_n + OFFSETX)/8;
    assign cur_y  = (py_n + OFFSETY)/8;
    assign left_x  = (px_n + OFFSETX)/8;
    assign left_y  = (py_n + OFFSETY)/8 == 0? 27 :(py_n + OFFSETY)/8-1;
    assign up_x  = (px_n + OFFSETX)/8 - 1;
    assign up_y  = (py_n + OFFSETY)/8;
    assign down_x  = (px_n + OFFSETX)/8 + 1;
    assign down_y  = (py_n + OFFSETY)/8;
    assign right_x  = (px_n + OFFSETX)/8;
    assign right_y  = (py_n + OFFSETY)/8 == 27? 0 :(py_n + OFFSETY)/8+1;


    assign can_left = cur_dir_n == LEFT?( ( py_n[2:0] != OFFSETY ) ? 1 : (i_map[left_x][left_y] == 0 ? 1: 0 ) ):0; 
    assign can_up   = cur_dir_n == UP?( ( px_n[2:0] != OFFSETX ) ? 1 : (i_map[up_x][up_y] == 0 ? 1: 0 ) ):0; 
    assign can_down = cur_dir_n == DOWN?( ( px_n[2:0] != OFFSETX ) ? 1 : (i_map[down_x][down_y] == 0 ? 1: 0 ) ):0; 
    assign can_right= cur_dir_n == RIGHT?( ( py_n[2:0] != OFFSETY ) ? 1 : (i_map[right_x][right_y] == 0 ? 1: 0 ) ):0; 
    //assign debug_dir = {can_left, can_up, can_down, can_right};

    always_comb begin
        if(counter_n >= LIMITMOVECOUNTER)begin
            counter_r = 0;
            cur_dir_r = cur_dir_n;
            if(can_left)begin
                if(i_pacman_reload)begin
                    px_r = 20*8-4;
                    py_r = 13*8-4;
                end
                else begin
                    px_r = px_n;
                    py_r = py_n == 0? 227 : py_n - 1 ;
                end
            end
            else if(can_up)begin
                if(i_pacman_reload)begin
                    px_r = 20*8-4;
                    py_r = 13*8-4;
                end
                else begin
                    px_r = px_n - 1;
                    py_r = py_n;
                end
            end
            else if(can_down)begin
                if(i_pacman_reload)begin
                    px_r = 20*8-4;
                    py_r = 13*8-4;
                end
                else begin
                    px_r = px_n + 1;
                    py_r = py_n;   
                end
            end
            else if(can_right)begin
                if(i_pacman_reload)begin
                    px_r = 20*8-4;
                    py_r = 13*8-4;
                end
                else begin
                    px_r = px_n;
                    py_r = py_n == 223? 0 : py_n + 1 ;   
                end
            end
            else begin
                if(i_pacman_reload)begin
                    px_r = 20*8-4;
                    py_r = 13*8-4;
                end
                else begin
                    px_r = px_n;
                    py_r = py_n;   
                end
            end
        end
        else begin
            if(i_pacman_reload)begin
                px_r = 20*8-4;
                py_r = 13*8-4;
            end
            else begin
                px_r = px_n;
                py_r = py_n;   
            end
            counter_r = counter_n + 1;

            if(cur_dir_n == next_dir_n)begin
                cur_dir_r = cur_dir_n;
            end
            else if ( (cur_dir_n == LEFT) && (next_dir_n == RIGHT))begin
                if (!((cur_x == 17) && ((py_n <= 4) ||(py_n >= 223)) ))begin
                    cur_dir_r = next_dir_n;
                end
                else begin
                    cur_dir_r = cur_dir_n;
                end
            end
            else if ( (cur_dir_n == RIGHT) && (next_dir_n == LEFT) )begin
                cur_dir_r = next_dir_n;
            end
            else if ( (cur_dir_n == UP) && (next_dir_n == DOWN) )begin
                cur_dir_r = next_dir_n;
            end
            else if ( (cur_dir_n == DOWN) && (next_dir_n == UP) )begin
                cur_dir_r = next_dir_n;
            end
            else begin
                cur_dir_r = cur_dir_n;
                if( ((cur_dir_n == LEFT)||(cur_dir_n == RIGHT) )&& (next_dir_n == UP))begin
                    if( ( py_n[2:0] == OFFSETY ) && (i_map[up_x][up_y] == 0) )begin
                        if (!((cur_x == 17) && ((py_n <= 4) ||(py_n >= 220)) ))begin
                            cur_dir_r = next_dir_n;
                        end
                        else begin
                            cur_dir_r = cur_dir_n;
                        end
                    end
                end
                else if( ((cur_dir_n == LEFT)||(cur_dir_n == RIGHT) )&& (next_dir_n == DOWN))begin
                    if( ( py_n[2:0] == OFFSETY ) && (i_map[down_x][down_y] == 0) )begin
                        if (!((cur_x == 17) && ((py_n <= 4) ||(py_n >= 220)) ))begin
                            cur_dir_r = next_dir_n;
                        end
                        else begin
                            cur_dir_r = cur_dir_n;
                        end
                    end         
                end
                else if( ((cur_dir_n == UP)||(cur_dir_n == DOWN)) && (next_dir_n == LEFT))begin
                    if( ( px_n[2:0] == OFFSETX ) && (i_map[left_x][left_y] == 0) )begin
                        cur_dir_r = next_dir_n;
                    end                      
                end 
                else if( ((cur_dir_n == UP)||(cur_dir_n == DOWN)) && (next_dir_n == RIGHT))begin
                    if( ( px_n[2:0] == OFFSETX ) && (i_map[right_x][right_y] == 0) )begin
                        cur_dir_r = next_dir_n;
                    end                       
                end
                else begin
                    cur_dir_r = cur_dir_n;
                end
            end
        end
    end

    always_ff @(posedge i_clk or negedge i_rst_n ) begin 
        if (~i_rst_n) begin
            counter_n <= 0;
            px_n <= 20*8-4;
            py_n <= 13*8-4;
            
            cur_dir_n <= LEFT;
            next_dir_n <= LEFT;
        end
        else begin
            px_n <= px_r;
            py_n <= py_r;
            counter_n <= counter_r;
            cur_dir_n <= cur_dir_r;
            next_dir_n <= next_dir_n;
            if(i_left)begin
                next_dir_n <= LEFT;
            end
            else if(i_up)begin
                next_dir_n <= UP;
            end
            else if(i_down)begin
                next_dir_n <= DOWN;
            end
            else if(i_right)begin
                next_dir_n <= RIGHT;
            end
            else begin
                next_dir_n <= next_dir_n;
            end
        end
    end
endmodule