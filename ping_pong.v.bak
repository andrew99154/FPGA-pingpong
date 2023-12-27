`define TimeExpire 32'd416667


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
	output red,
	output green,
	output blue,
	output hsync,
	output vsync
);
	wire [1:0] game_state;
	wire div_clk;
	wire [9:0] p1_y;
	wire [9:0] p2_y;
	wire [9:0] ball_x;
	wire [9:0] ball_y;
	wire [9:0] speed_curr_x;
	wire [9:0] speed_curr_y;
	wire [9:0] speed_next_x;
	wire [9:0] speed_next_y;
	parameter p1_serve = 2'd0;
	parameter p2_serve = 2'd1;
	parameter playing = 2'd2;
	parameter done = 2'd3;
	
	divider fps60(clk, reset, div_clk);
	//process module first
	ball_next_state my_ball_next_state(reset, game_state, p1u, p1d, p2u, p2d, p1_y, p2_y, ball_x, ball_y,speed_curr_x,speed_curr_y,speed_next_x,speed_next_y);
	ball_move_moore my_ball_move_moore(div_clk, reset, speed_next_x,speed_next_y, game_state,p1_y, p2_y, ball_x, ball_y, speed_curr_x, speed_curr_y);
	board_controller my_controller(div_clk, reset, game_state, p1u, p1d, p2u, p2d, p1_y, p2_y);
	 
	

	//todo

endmodule

module divider(clk, reset, divided_clk);
input clk, reset;
output divided_clk;
reg divided_clk;
reg [31:0] cnt;

always@(posedge clk)
begin
	if(!reset)
	begin
		divided_clk <= 1'b0;
		cnt <= 32'd0;
	end
	else
	begin
		if(cnt == `TimeExpire)
		begin 
			cnt <= 32'd0;
			divided_clk <= ~divided_clk;
		end
		else
		begin
			cnt <= cnt+32'd1;
		end
	end
end

endmodule

module board_controller(
	input clk,
	input reset,
	input [1:0] game_state,
	input p1u,
	input p1d,
	input p2u,
	input p2d,
	output reg [9:0] p1_y,
	output reg [9:0] p2_y
);

	parameter center = 10'd220;
	parameter speed = 10'd10;
	parameter upper_limit = 10'd140;
	parameter lower_limit = 10'd330; //340-10 (board width)
	parameter p1_serve = 2'd0;
	parameter p2_serve = 2'd1;
	parameter playing = 2'd2;
	parameter done = 2'd3;

	always @(posedge clk or negedge reset) begin
		if (!reset) begin
			p1_y <= center;
			p2_y <= center;
		end else begin
			case(game_state)
				p1_serve: begin
					p1_y <= center; // p1 go back to center
					p2_y <= calculate_next_position(p2u, p2d, p2_y, speed, upper_limit, lower_limit);
				end
				p2_serve: begin
					p2_y <= center; // p2 go back to center
					p1_y <= calculate_next_position(p1u, p1d, p1_y, speed, upper_limit, lower_limit);
				end
				playing: begin
					// both of them can move
					p1_y <= calculate_next_position(p1u, p1d, p1_y, speed, upper_limit, lower_limit);
					p2_y <= calculate_next_position(p2u, p2d, p2_y, speed, upper_limit, lower_limit);
				end
				done: begin
					p1_y <= center;
					p2_y <= center;
				end
			endcase
		end
	end

	//function to calculate next board position
	function [9:0] calculate_next_position(
	  input up, 
	  input down, 
	  input [9:0] current_position, 
	  input [9:0] move_speed, 
	  input [9:0] up_limit, 
	  input [9:0] down_limit
	);
		begin
			if (up && !down && current_position > up_limit + move_speed)
				calculate_next_position = current_position - move_speed;
			else if (!up && down && current_position < down_limit - move_speed)
				calculate_next_position = current_position + move_speed;
			else
				calculate_next_position = current_position;
		end
	endfunction
endmodule

module ball_next_state(
	input reset,
	input [1:0] game_state,
	input p1u,
	input p1d,
	input p2u,
	input p2d,
	input [9:0] p1_y,
	input [9:0] p2_y,
	input [9:0] ball_x,
	input [9:0] ball_y,
	input [9:0] speed_curr_x,
	input [9:0] speed_curr_y,
	output reg [9:0] speed_next_x,
	output reg [9:0] speed_next_y
);

	parameter SPEED_X = 10'd10;
	parameter SPEED_Y = 10'd10;
	parameter TOP_BOUND = 10'd140; //y
	parameter BOTTOM_BOUND = 10'd340; //y
	parameter LEFT_BOUND = 10'd150; //x
	parameter RIGHT_BOUND = 10'd490; //x
	parameter BALL_WIDTH = 10'd5;
	parameter BOARD_HEIGHT = 10'd40; //y
	parameter p1_serve = 2'd0;
	parameter p2_serve = 2'd1;
	parameter playing = 2'd2;
	parameter done = 2'd3;

	always @(*) begin
		if (reset) begin
			speed_next_x = 0;
			speed_next_y = 0;
		end else begin
			case(game_state)
				p1_serve: begin
					if (p1u) begin
						speed_next_x = SPEED_X;
						speed_next_y = -SPEED_Y;
					end else if (p1d) begin
						speed_next_x = SPEED_X;
						speed_next_y = SPEED_Y;
					end else begin
						speed_next_x = 0; // did not serve yet
						speed_next_y = 0;
					end
				end
				
				p2_serve: begin
					if (p2u) begin
						speed_next_x = -SPEED_X;
						speed_next_y = -SPEED_Y;
					end else if (p2d) begin
						speed_next_x = -SPEED_X;
						speed_next_y = SPEED_Y;
					end else begin
						speed_next_x = 0; // did not serve yet
						speed_next_y = 0;
					end
				end
				playing: begin
					//check whether the ball is hitting the board (horizontal)
					if ((ball_x + speed_curr_x < LEFT_BOUND && ball_y + speed_curr_y >= p1_y && ball_y + speed_curr_y + BOARD_HEIGHT <= p1_y + BOARD_HEIGHT)
						|| (ball_x + speed_curr_x > RIGHT_BOUND && ball_y + speed_curr_y >= p2_y && ball_y + speed_curr_y + BOARD_HEIGHT <= p2_y + BOARD_HEIGHT)) 
						speed_next_x = -speed_curr_x;
					else speed_next_x = speed_curr_x;

					if (ball_y + speed_curr_y < TOP_BOUND || ball_y + BOARD_HEIGHT + speed_curr_y > BOTTOM_BOUND) 
						speed_next_y = -speed_curr_y; // vertical
					else speed_next_y = speed_curr_y;
				end
				default: begin
					speed_next_x = speed_curr_x;
					speed_next_y = speed_curr_y;
				end
			endcase
		end
	end
endmodule


module ball_move_moore(
    input clk,
    input reset,
    input [9:0] speed_next_x,
    input [9:0] speed_next_y,
    input [1:0] game_state,
    input [9:0] p1_y,
    input [9:0] p2_y,
    output reg [9:0] ball_x,
    output reg [9:0] ball_y,
    output reg [9:0] speed_curr_x,
    output reg [9:0] speed_curr_y
);

	parameter BALL_START_OFFSET = 10'd18;
	parameter P1_START_X = 10'd150; // 140+10(board width)
	parameter P2_START_X = 10'd485; // 490-5(ball width)
	parameter p1_serve = 2'd0;
	parameter p2_serve = 2'd1;
	parameter playing = 2'd2;
	parameter done = 2'd3;

	always @(posedge clk or negedge reset) begin
		if (!reset) begin
			ball_x <= P1_START_X;
			ball_y <= p1_y + BALL_START_OFFSET;
			speed_curr_x <= 0;
			speed_curr_y <= 0;
		end else begin
			speed_curr_x <= speed_next_x;
			speed_curr_y <= speed_next_y;
			if (game_state == p1_serve) begin
				ball_x <= P1_START_X;
				ball_y <= p1_y + BALL_START_OFFSET;
			end else if (game_state == p2_serve) begin
				ball_x <= P2_START_X;
				ball_y <= p2_y + BALL_START_OFFSET;
			end else if (game_state == playing) begin
				ball_x <= ball_x + speed_curr_x;
				ball_y <= ball_y + speed_curr_y;
			end
		end
	end
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
