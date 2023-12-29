module process_next_state(clk,reset,p1u,p1d,p2u,p2d,ball_x,ball_y,time_cnt,game_state,p1_score,p2_score);
	input clk;
	input reset;
	input p1u;
	input p1d;
	input p2u;
	input p2d;
	input [9:0] ball_x,ball_y;
	input [5:0] time_cnt;
	
	output reg [1:0] game_state;
	output reg [3:0] p1_score;
	output reg [3:0] p2_score;
	
	
	parameter p1_serve = 2'd0;
	parameter p2_serve = 2'd1;
	parameter playing = 2'd2;
	parameter game_end = 2'd3;
	parameter goal_points = 4'd7;
	parameter game_times = 6'd60;
	parameter p1_board_x= 10'd110;
	parameter p2_board_x= 10'd530;
	
	always @(posedge clk or negedge reset)
	begin
		if(!reset)begin
			game_state <= p1_serve;//reset game to p1_serve
			p1_score= 4'd0;
			p2_score= 4'd0;
		end 
		else begin
			if(p1_score >= goal_points || p2_score >= goal_points)
				game_state <= game_end;
			else begin
				case(game_state)
					p1_serve: begin
						if(!p1u || !p1d) //p1 start the ball
							game_state <= playing;
						else //keep p1_sreve
							game_state <= p1_serve;
					end
					p2_serve: begin
						if(!p2u || !p2d) //p2 start the ball
							game_state <= playing;
						else //keep_p2_serve
							game_state <= p2_serve;
					end
					playing: begin
						if(ball_x>p2_board_x)//p1 goal ,from playing to p2_serve
						begin
							game_state <= p2_serve;
							p1_score <= p1_score+4'd1;
						end else if(ball_x<p1_board_x)//p2 goal ,from playing to p1_reserve
						begin
							game_state <= p1_serve;
							p2_score <= p2_score+4'd1;
						end else if(time_cnt<=0)//times out
							game_state <= game_end;
						else//keep playing
							game_state <= playing;
					end
					default: game_state <= game_end;
				endcase
			end
		end
	end
	
endmodule 