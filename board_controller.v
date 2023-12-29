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
	parameter speed = 10'd5;
	parameter upper_limit = 10'd140;
	parameter lower_limit = 10'd300; //340-10 (board width)
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
			if (!up && down && current_position >= up_limit + move_speed)
				calculate_next_position = current_position - move_speed;
			else if (up && !down && current_position <= down_limit - move_speed)
				calculate_next_position = current_position + move_speed;
			else
				calculate_next_position = current_position;
		end
	endfunction
endmodule
