module ping_pong(
	input clk,
	input reset,
	input p1u, //control button
	input p1d,
	input p2u,
	input p2d, 
	output [6:0] time_ten, //tens digit
	output [6:0] time_one, //ones digit
	output [7:0] dot_matrix_row,
	output [7:0] dot_matrix_left_col,
	output [7:0] dot_matrix_right_col,
	output wire [3:0] red,
	output wire [3:0] green,
	output wire [3:0] blue,
	output hsync,
	output vsync
);
	wire [1:0] game_state;
	wire clk_60;
	wire clk_matrix;
	wire [9:0] p1_y;
	wire [9:0] p2_y;
	wire [9:0] ball_x;
	wire [9:0] ball_y;
	wire [9:0] speed_curr_x;
	wire [9:0] speed_curr_y;
	wire [9:0] speed_next_x;
	wire [9:0] speed_next_y;
	wire [5:0] time_cnt;
	wire [3:0] p1_score;
	wire [3:0] p2_score;
	parameter p1_serve = 2'd0;
	parameter p2_serve = 2'd1;
	parameter playing = 2'd2;
	parameter done = 2'd3;
	
	divider fps60(clk, reset, clk_60);
	process_next_state my_game_state(clk_60, reset, p1u, p1d, p2u, p2d, ball_x, ball_y, time_cnt, game_state, p1_score, p2_score);
	ball_next_state my_ball_next_state(reset, game_state, p1u, p1d, p2u, p2d, p1_y, p2_y, ball_x, ball_y,speed_curr_x,speed_curr_y,speed_next_x,speed_next_y);
	ball_move_moore my_ball_move_moore(clk_60, reset, speed_next_x,speed_next_y, game_state,p1_y, p2_y, ball_x, ball_y, speed_curr_x, speed_curr_y);
	board_controller my_controller(clk_60, reset, game_state, p1u, p1d, p2u, p2d, p1_y, p2_y);
	vga_displayer my_vga_displayer(clk, reset, p1_y, p2_y, ball_x, ball_y, hsync, vsync, red, blue, green);
	timer down_count_timer(clk, reset, game_state, time_cnt);
	time_displayer my_time_displayer(time_cnt, time_ten, time_one);
	matrix_clk_divider my_matrix_clk_divider(clk, reset, clk_matrix);
	matrix_displayer my_matrix_displayer(clk_matrix, reset, game_state, p1_score, p2_score, dot_matrix_row, dot_matrix_left_col, dot_matrix_right_col);

	
	
endmodule






