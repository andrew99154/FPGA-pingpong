//File Name:process_next_state.v
module process_next_state(reset,p1l,p1r,p2l,p2r,ball_x,ball_y,time_cnt,game_state,game_next_state,p1_score,p2_score,clk);
	input reset;
	input p1l,p1r;
	input p2l,p2r;
	input [9:0]ball_x,ball_y;
	input [5:0] time_cnt;
	input [1:0] game_state;
	input clk;
	
	output reg [1:0] game_next_state;
	output reg [3:0] p1_score;
	output reg [3:0] p2_score;
	
	parameter p1_serve =2'd0;
	parameter p2_serve =2'd1;
	parameter playing =2'd2;
	parameter game_end =2'd3;
	parameter goal_points =3'd7;
	parameter game_times = 6'd60;
	parameter p1_board_x= 10'd150;
	parameter p2_board_x= 10'd490;
	
always @(posedge clk or negedge reset)
begin
	if(!reset)
	begin
		game_next_state=p1_serve;//reset game to p1_serve
		p1_score=3'd0;
		p2_score=3'd0;
	end
	else
	begin
		if(game_state == p1_serve) //p1_serve
		begin
			if(p2_score>=goal_points)
			begin
				game_next_state=game_end;
			end
			else if(p1l== 1'd1 || p1r == 1'd1) //p1 start the ball
				game_next_state=playing;
			else //keep p1_sreve
				game_next_state=p1_serve;
		end
		else if(game_state == p2_serve)//p2_serve
		begin
			if(p1_score>=goal_points)
			begin
				game_next_state=game_end;
			end
			if(p2l == 1'd1 || p2r == 1'd1) //p2 start the ball
				game_next_state=playing;
			else //keep_p2_serve
				game_next_state=p2_serve;
		end
		else if(game_state == playing)//playing
			begin
			if(ball_x>p2_board_x)//p1 goal ,from playing to p2_serve
			begin
				game_next_state = p2_serve;
				p1_score=p1_score+1'd1;
			end 
			else if(ball_x<p1_board_x)//p2 goal ,from playing to p1_reserve
			begin
				game_next_state=p1_serve;
				p2_score=p2_score+1'd1;
			end
			else if(time_cnt>=game_times)//times out
				game_next_state=game_end;
			else//keep playing
				game_next_state=playing;
			end
		else//end 2'd3 keep end
			game_next_state=game_end;
	end
end
	
endmodule 
