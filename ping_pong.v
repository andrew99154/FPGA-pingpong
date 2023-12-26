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
	input p1u,
	input p1d,
	input p2u,
	input p2d,
	output reg [9:0] p1_y, //position of the board
	output reg [9:0] p2_y //position of the board
);

	//todo
	//sequential
	
	//const value
	parameter center = 10'd220; //board center

	//record next pos of player board
	reg [9:0]next_p1_y;
	reg [9:0]next_p2_y;
	
	//link move counter of board
	//counting next pos of board first
	//next, when clk is coming update pos
	
	//only will moving once a clk
	//since we the based value is from this module
	//then if clk do not change based value, the pos of both player will only change +-10
	player_moveBoard p1_move(
							.pu(p1u),
							.pd(p1d),
							.last(p1_y),	//lsat position of the board
							.py(next_p1_y), //position of the board
						);
	player_moveBoard p2_move(
		.pu(p2u),
		.pd(p2d),
		.last(p2_y),	//lsat position of the board
		.py(next_p2_y), //position of the board
	);
	always@(posedge clk or negedge reset) begin
	
		if(!reset) begin
			//reset position of two board back to init position
			p1_y <= center;
			p2_y <= center;
		end else begin
			
			//decide output based on game_state
			case(game_state)
				2'd0: begin
						//player 1 can move his board
						p1_y <= next_p1_y;
					end
				2'd1: begin
						//player 2 can move his board
						p2_y <= next_p2_y;
					end
				2'd2: begin
						//both them can move their board
						p1_y <= next_p1_y;
						p2_y <= next_p2_y;
					end
				2'd3: begin
						//both them can not move their board
						//game is done, everyone back center

						p1_y <= center;
						p2_y <= center;
					end
			endcase
			
		end
	
	end

endmodule

//moving of player
module player_moveBoard(
	input pu,
	input pd,
	input [9:0]last,	//lsat position of the board
	output reg [9:0] py, //position of the board
);

	parameter speed = 10'd10;
	py <= last;	//default setting now pos eauals previous pos

	always(posedge pu or posedge pd) begin
		if(!pu) begin
			py <= last - speed;
		
			if(py < 10'd140) py <= 10'd140;
		end else if(!pd) begin
			py <= last + speed;
		
			if(py > 10'd340) py <= 10'd340;
		end else begin
			//will not happen
		end
	end

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


	



	
	




	
