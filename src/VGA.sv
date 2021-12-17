// *** In this file, x is horizontal, y is vertical
// However, output x_cord is vertical, y is horizontal (to match usage in other language)

module VGA(
    // DE2_115
    input  i_rst_n,
    input  i_clk_25M,
    output VGA_BLANK_N,
    output VGA_CLK,
    output VGA_HS,
    output VGA_SYNC_N,
    output VGA_VS,

    // for Mem_addr_generator
    output o_show_en,      // 1 when in display time, otherwise 0
    output [9:0] o_x_cord, // from 0 to 479
    output [9:0] o_y_cord  // from 0 to 639
);


    // Variable definition
    logic [9:0] x_cnt_r, x_cnt_w;
    logic [9:0] y_cnt_r, y_cnt_w;
    logic hsync_r, hsync_w, vsync_r, vsync_w;
    reg show_en_r, show_en_w;
    
    // 640*480, refresh rate 60Hz
    // VGA clock rate 25.175MHz
    // display as H_BLANK <= x_cnt_r <= H_TOTAL
    //            y_cnt_r
    localparam H_FRONT  =   16;
    localparam H_SYNC   =   96;
    localparam H_BACK   =   48;
    localparam H_ACT    =   640;
    localparam H_BLANK  =   H_FRONT + H_SYNC + H_BACK;         // = 160
    localparam H_TOTAL  =   H_FRONT + H_SYNC + H_BACK + H_ACT; // = 800
    localparam V_FRONT  =   10;
    localparam V_SYNC   =   2;
    localparam V_BACK   =   33;
    localparam V_ACT    =   480;
    localparam V_BLANK  =   V_FRONT + V_SYNC + V_BACK;         // = 45
    localparam V_TOTAL  =   V_FRONT + V_SYNC + V_BACK + V_ACT; // = 525

    // Output assignment
    assign VGA_CLK      =   i_clk_25M;
    assign VGA_HS       =   hsync_r;
    assign VGA_VS       =   vsync_r;
    assign VGA_SYNC_N   =   1'b0;
    assign VGA_BLANK_N  =   ~((x_cnt_r < H_BLANK) || (y_cnt_r < V_BLANK));
    
    // Coordinates
    always_comb begin
        if (x_cnt_r == H_TOTAL) begin
            x_cnt_w = 1;
        end
        else begin
            x_cnt_w = x_cnt_r + 1;
        end
    end

    always_comb begin
        if (y_cnt_r == V_TOTAL) begin
            y_cnt_w = 1;
        end
        else if (x_cnt_r == H_TOTAL) begin
            y_cnt_w = y_cnt_r + 1;
        end
        else begin
            y_cnt_w = y_cnt_r;
        end
    end

    // Sync signals
    always_comb begin
        if (x_cnt_r == H_FRONT) begin
            hsync_w = 1'b0;
        end
        else if (x_cnt_r == H_FRONT + H_SYNC) begin
            hsync_w = 1'b1;
        end
        else begin
            hsync_w = hsync_r;
        end
    end
    
    always_comb begin
        if (y_cnt_r == V_FRONT) begin
            vsync_w = 1'b0;
        end
        else if (y_cnt_r == V_FRONT + V_SYNC) begin
            vsync_w = 1'b1;                 
        end
        else begin
            vsync_w = vsync_r;
        end
    end
    
    // RGB data
    always_comb begin
        if (x_cnt_r < H_BLANK-1 || x_cnt_r > H_TOTAL-1 || y_cnt_r < V_BLANK-1 || y_cnt_r > V_TOTAL-1) begin
            show_en_w = 0;
            o_x_cord = 0;
            o_y_cord = 0;
        end
        else begin
            show_en_w = 1;
            o_x_cord = y_cnt_r - V_BLANK;
            o_y_cord = x_cnt_r - H_BLANK;
        end
    end

    // Flip-flop
    always_ff @(posedge i_clk_25M or negedge i_rst_n) begin
        if (~i_rst_n) begin
            x_cnt_r <= 1;   
            y_cnt_r <= 1;
            hsync_r <= 1'b1;
            vsync_r <= 1'b1;
            show_en_r <= 0;
        end
        else begin
            x_cnt_r <= x_cnt_w;
            y_cnt_r <= y_cnt_w;
            hsync_r <= hsync_w;
            vsync_r <= vsync_w;
            show_en_r <= show_en_w;
        end
    end
endmodule