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

	parameter SPEED_X = 10'd3;
	parameter SPEED_Y = 10'd3;
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
		if (!reset) begin
			speed_next_x = 0;
			speed_next_y = 0;
		end else begin
			case(game_state)
				p1_serve: begin
					if (!p1u) begin
						speed_next_x = SPEED_X;
						speed_next_y = -SPEED_Y;
					end else if (!p1d) begin
						speed_next_x = SPEED_X;
						speed_next_y = SPEED_Y;
					end else begin
						speed_next_x = 0; // did not serve yet
						speed_next_y = 0;
					end
				end
				
				p2_serve: begin
					if (!p2u) begin
						speed_next_x = -SPEED_X;
						speed_next_y = -SPEED_Y;
					end else if (!p2d) begin
						speed_next_x = -SPEED_X;
						speed_next_y = SPEED_Y;
					end else begin
						speed_next_x = 0; // did not serve yet
						speed_next_y = 0;
					end
				end
				playing: begin
					//check whether the ball is hitting the board (horizontal)
					if ((ball_x >= LEFT_BOUND && ball_x + speed_curr_x < LEFT_BOUND && ball_y + speed_curr_y + BALL_WIDTH > p1_y && ball_y + speed_curr_y < p1_y + BOARD_HEIGHT)
						|| (ball_x + BALL_WIDTH <= RIGHT_BOUND && ball_x + speed_curr_x + BALL_WIDTH > RIGHT_BOUND && ball_y + speed_curr_y + BALL_WIDTH > p2_y && ball_y + speed_curr_y < p2_y + BOARD_HEIGHT)) 
						speed_next_x = -speed_curr_x;
					else speed_next_x = speed_curr_x;

					if (ball_y + speed_curr_y < TOP_BOUND || ball_y + BALL_WIDTH + speed_curr_y > BOTTOM_BOUND) 
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