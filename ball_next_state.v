module ball_next_state(
	input reset,
	input [1:0] game_state,
	input p1_up,
	input p1_down,
	input p2_up,
	input p2_down,
	input [9:0] p1_y,
	input [9:0] p2_y,
	output [9:0] ball_x,
	output [9:0] ball_y,
	input [9:0] now_speed_x,
	input [9:0] now_speed_y,
	output [9:0] next_speed_x,
	output [9:0] next_speed_y
);
	
	parameter up_y = 140;
	parameter down_y = 340;
	parameter p1_x = 150;
	parameter p2_x = 490;

	if(!reset || game_state == 3) begin
		assign next_speed_x = 0;
		assign next_speed_y = 0;
	end	else if(gmae_state == 3 && (p1_up | p1_down | p2_up | p2_down)) begin
		// no collison
		if(ball_x < right_x && ball_x > left_x && ball_y < down_y && ball_y > up_y) begin
			assign next_speed_x = now_speed_x;
			assign next_speed_y = now_speed_y;
		end else if(ball_x == p1_x && ball_y <= p1_y + 40 && ball_y >= p1_y) begin // collison with p1 board
			assign next_speed_x = ~now_speed_x;
			assign next_speed_y = ~now_speed_y;
		end else if(ball_x == p2_x && ball_y <= p2_y + 40 && ball_y >= p2_y) begin // collision with p2 board
			assign next_speed_x = ~now_speed_x;
			assign next_speed_y = ~now_speed_y;
		end else if(ball_y == up_y) begin // collision with up boundary
			assign next_speed_x = now_speed_x;
			assign next_speed_y = ~now_speed_y;
		end else begin // collision with down boundary
			assign next_speed_x = now_speed_x;
			assign next_speed_y = ~now_speed_y;
		end
	end
		
endmodule
