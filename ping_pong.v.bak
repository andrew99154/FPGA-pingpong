module ping_pong(
	input clk,
	input reset,
	input p1l, //control button
	input p1r,
	input p2l,
	input p2r, 
	output [6:0] time_ten, //tens digit
	output [6:0] time_one, //ones digit
	output [7:0] dot_matrix_row,
	output [7:0] dot_matrix_left_col,
	output [7:0] dot_matrix_right_col,
	output red,
	output green,
	output blue,
	output hsync,
	output vsync
);
	wire [1:0] game_state;
	parameter serve = 2'd0;
	parameter playing = 2'd1;
	parameter done = 2'd2;

	//todo

endmodule

module board_controller(
	input clk,
	input reset,
	input [1:0] game_state,
	input p1l,
	input p1r,
	input p2l,
	input p2r,
	output [9:0] p1_x, //position of the board
	output [9:0] p2_x //position of the board
);

	//todo
	//sequential

endmodule

module ball_next_state(
	input reset,
	input [1:0] game_state,
	input p1l,
	input p1r,
	input p2l,
	input p2r,
	input [9:0] p1_x,
	input [9:0] p2_x,
	input [9:0] ball_x,
	input [9:0] ball_y,
	input [9:0] acc_curr_x, //acceleration
	input [9:0] acc_curr_y,
	output [9:0] acc_next_x,
	output [9:0] acc_next_y
);
	//combinational
	//todo

endmodule

module ball_move_moore(
	input clk,
	input [9:0] acc_next_x,
	input [9:0] acc_next_y,
	output [9:0] acc_curr_x,
	output [9:0] acc_curr_y,
	output [9:0] ball_x,
	output [9:0] ball_y
);
	//sequential
	//update the acc into next state first
	//use acc to update ball's position

endmodule

module process_next_state(
	input reset,
	input p1l,
	input p1r,
	input p2l,
	input p2r,
	input ball_x,
	input ball_y,
	input [5:0] time_cnt,
	input [1:0] game_state,
	output [1:0] game_next_state,
	output [3:0] p1_score,
	output [3:0] p2_score
);
	//combinational
	//todo
	//serve -> playing: when serve (press the button)
	//playing->serve: when ball's position > or < specific value
	//playing->end: when one of player got 7 points or time's up
endmodule

module process_moore(
	input clk,
	input [1:0] game_state,
	output [1:0] game_next_state
);
	//sequential
	//todo
	//update game state to next state
endmodule
	

module vga_displayer(
	input clk, 
	input reset, 
	input btn_r, 
	output hsync,
	output vsync,
	output [3:0] red, 
	output [3:0] green, 
	output [3:0] blue
);
	//todo
endmodule

module timer(
	input clk,
	input game_state,
	output [5:0] time_cnt
);
	//count down timer
	//todo
endmodule

module time_displayer(
	input time_cnt,
	output [6:0] time_ten,
	output [6:0] time_one
);
	//todo
endmodule

module matrix_displayer(
	input clk,
	input [1:0] game_state,
	input [3:0] p1_score,
	input [3:0] p2_score,
	output [7:0] dot_matrix_row,
	output [7:0] dot_matrix_left_col,
	output [7:0] dot_matrix_right_col
);
	//todo

endmodule	


	



	
	




	
