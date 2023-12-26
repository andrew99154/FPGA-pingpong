//File Name:process_next_state.v
module process_next_state(reset,p1l,p1r,p2l,p2r,ball_x,ball_y,time_cnt,game_state,game_next_state,p1_score,p2_score);
	input reset;
	input p1l,p1r;
	input p2l,p2r;
	input ball_x,ball_y;
	input [5:0] time_cnt;
	input [1:0] game_state;
	
	output [1:0] game_next_state;
	output [3:0] p1_score;
	output [3:0] p2_score;
	
	if(game_state == 2'd0) //p1_serve
	begin
	end
	else if(game_state == 2'd1)//p2_serve
	begin
	end
	else if(game_state == 2'd2)//playing
		begin
		if(ball_x>490)//from playing to p2_serve
			game_next_state = 2'd1;  
		else if(ball_x<150) //from playing to p1_reserve
			game_next_state=2'd0;
		else if()
		else //keep playing
			game_next_state=2'd2;
		end
	else//end
	begin
	end
	
endmodule 
