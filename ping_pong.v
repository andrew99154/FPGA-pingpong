`define TimeExpire 32'd416667 //60fps
`define MatrixExpire 32'd2500


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
			if (up && !down && current_position >= up_limit + move_speed)
				calculate_next_position = current_position - move_speed;
			else if (!up && down && current_position <= down_limit - move_speed)
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

	parameter SPEED_X = 10'd2;
	parameter SPEED_Y = 10'd2;
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
					if ((ball_x >= LEFT_BOUND && ball_x + speed_curr_x < LEFT_BOUND && ball_y + speed_curr_y >= p1_y && ball_y + speed_curr_y + BALL_WIDTH <= p1_y + BOARD_HEIGHT)
						|| (ball_x + BALL_WIDTH <= RIGHT_BOUND && ball_x + speed_curr_x + BALL_WIDTH > RIGHT_BOUND && ball_y + speed_curr_y >= p2_y && ball_y + speed_curr_y + BALL_WIDTH <= p2_y + BOARD_HEIGHT)) 
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
	
	wire p1u_deb, p1d_deb, p2u_deb, p2d_deb;
	
	parameter p1_serve = 2'd0;
	parameter p2_serve = 2'd1;
	parameter playing = 2'd2;
	parameter game_end = 2'd3;
	parameter goal_points = 4'd7;
	parameter game_times = 6'd60;
	parameter p1_board_x= 10'd110;
	parameter p2_board_x= 10'd530;
	
	debouncer p1u_debouncer(clk, p1u, p1u_deb);
	debouncer p1d_debouncer(clk, p1d, p1d_deb);
	debouncer p2u_debouncer(clk, p2u, p2u_deb);
	debouncer p2d_debouncer(clk, p2d, p2d_deb);

	
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
						if(!p1u_deb && !p1d_deb) //p1 start the ball
							game_state <= p1_serve;
						else //keep p1_sreve
							game_state <= playing;
					end
					p2_serve: begin
						if(!p2u_deb && !p2d_deb) //p2 start the ball
							game_state <= p2_serve;
						else //keep_p2_serve
							game_state <= playing;
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

module debouncer(
    input clk,
    input btn_in,
    output reg btn_out
);
    reg [7:0] shift_reg;

    always @(posedge clk) begin
        shift_reg <= shift_reg << 1;
        shift_reg[0] <= btn_in;

        if(shift_reg == 8'hFF || shift_reg == 8'h00) begin
            btn_out <= shift_reg[0];
        end
    end
endmodule


module vga_displayer(clk, reset, p1_y, p2_y, ball_x, ball_y, hsync, vsync, red, blue, green);
	input clk, reset;
	input [9:0] p1_y;
	input [9:0] p2_y;
	input [9:0] ball_x;
	input [9:0] ball_y;
	output hsync, vsync;
	output [3:0] red, blue, green;
	reg [3:0] red;
	reg [3:0] green;
	reg [3:0] blue;
	wire div_clk_color, div_clk;
	wire display_active;
	wire [9:0] pixel_x, pixel_y;
	parameter p1_x = 10'd140;
	parameter p2_x = 10'd490;
	parameter BOARD_WIDTH = 10'd10;
	parameter BOARD_HEIGHT = 10'd40;
	parameter BALL_WIDTH = 10'd5;
	
	parameter BORDER_TOP_X = 10'd65;
	parameter BORDER_TOP_Y = 10'd135;
	parameter BORDER_LEFT_X = 10'd65;
	parameter BORDER_LEFT_Y = 10'd135;
	parameter BORDER_BOTTOM_X = 10'd65;
	parameter BORDER_BOTTOM_Y = 10'd340;
	parameter BORDER_RIGHT_X = 10'd570;
	parameter BORDER_RIGHT_Y = 10'd135;
	parameter BORDER_WEIGHT = 10'd5;
	parameter BORDER_LONG = 10'd510;
	parameter BORDER_SHORT = 10'd210;


	vga_divider my_divider(clk, reset, div_clk);
	vga_sync my_vga_sync(div_clk, reset, hsync, vsync, display_active, pixel_x, pixel_y);
	
	always@(posedge div_clk) begin
		 if(!reset) begin
			  red <= 0;
			  green <= 0;
			  blue <= 0;
		 end
		 else if(display_active) begin
			  if(pixel_x >= p1_x && pixel_x < p1_x + BOARD_WIDTH && pixel_y >= p1_y && pixel_y < p1_y + BOARD_HEIGHT) begin
					red <= 4'h0; 
					green <= 4'h0; 
					blue <= 4'hF; //p1 is blue
			  end
			  else if(pixel_x >= p2_x && pixel_x < p2_x + BOARD_WIDTH && pixel_y >= p2_y && pixel_y < p2_y + BOARD_HEIGHT) begin
					red <= 4'hF; //p2 is red
					green <= 4'h0; 
					blue <= 4'h0;
			  end
			  else if(pixel_x >= ball_x && pixel_x < ball_x + BALL_WIDTH && pixel_y >= ball_y && pixel_y < ball_y + BALL_WIDTH) begin
					red <= 4'hF; 
					green <= 4'hF; //ball is green 
					blue <= 4'h0; 
			  end
			  else if(pixel_x >= BORDER_TOP_X && pixel_x < BORDER_TOP_X+BORDER_LONG && pixel_y >= BORDER_TOP_Y && pixel_y < BORDER_TOP_Y+BORDER_WEIGHT)begin
					red <= 4'hF; 
					green <= 4'hF; 
					blue <= 4'hF; // top border			
			  end
			  else if(pixel_x >= BORDER_BOTTOM_X && pixel_x < BORDER_BOTTOM_X+BORDER_LONG && pixel_y >= BORDER_BOTTOM_Y && pixel_y < BORDER_BOTTOM_Y+BORDER_WEIGHT)begin
					red <= 4'hF; 
					green <= 4'hF; 
					blue <= 4'hF; // bottom border			
			  end
			  else if(pixel_x >= BORDER_LEFT_X && pixel_x < BORDER_LEFT_X+BORDER_WEIGHT && pixel_y >= BORDER_LEFT_Y && pixel_y < BORDER_LEFT_Y+BORDER_SHORT)begin
					red <= 4'hF; 
					green <= 4'hF; 
					blue <= 4'hF; // left border			
			  end
			  else if(pixel_x >= BORDER_RIGHT_X && pixel_x < BORDER_RIGHT_X+BORDER_WEIGHT && pixel_y >= BORDER_RIGHT_Y && pixel_y < BORDER_RIGHT_Y+BORDER_SHORT)begin
					red <= 4'hF; 
					green <= 4'hF; 
					blue <= 4'hF; // right border			
			  end
			  else begin
					red <= 4'h0; 
					green <= 4'h0; 
					blue <= 4'h0;
			  end
		 end
		 else begin
			  red <= 4'h0; 
			  green <= 4'h0; 
			  blue <= 4'h0;
		 end
	end
	
endmodule

module vga_divider(clk, reset, divided_clk);
input clk, reset;
output divided_clk;
reg divided_clk;

always@(posedge clk)
begin
	if(!reset)
	begin
		divided_clk <= 1'b0;
	end
	else
	begin
		divided_clk <= ~divided_clk;
	end
end

endmodule


module vga_sync(
	input wire clk,
   input wire reset,
   output reg hsync,
   output reg vsync,
   output wire display_active,
   output wire [9:0] pixel_x,
   output wire [9:0] pixel_y
);


parameter h_front_porch = 16;
parameter h_sync_pulse = 96;
parameter h_back_porch = 48;
parameter h_max = 800;
parameter v_front_porch = 10;
parameter v_sync_pulse = 2;
parameter v_back_porch = 33;
parameter v_max = 525;

reg [9:0] h_count = 0;
reg [9:0] v_count = 0;

always @(posedge clk) begin
	if (!reset) begin
		h_count <= 10'd0;
		v_count <= 10'd0;
	end else begin
		if (h_count < h_max - 1) begin
			h_count <= h_count + 10'd1;
		end else begin
			h_count <= 10'd0;
			if (v_count < v_max - 1) begin
				v_count <= v_count + 10'd1;
			end else begin
				v_count <= 10'd0;
			end
		end
	end
	
	if(h_count >= h_sync_pulse)hsync <= 1'd1;
	else hsync <= 1'd0;
	if(v_count >= v_sync_pulse)vsync <= 1'd1;
	else vsync <= 1'd0;
end



assign display_active = (h_count >= (h_sync_pulse + h_back_porch)) &&
                        (h_count < (h_max - h_front_porch)) &&
                        (v_count >= (v_sync_pulse + v_back_porch)) &&
                        (v_count < (v_max - v_front_porch));

assign pixel_x = h_count - (h_sync_pulse + h_back_porch);
assign pixel_y = v_count - (v_sync_pulse + v_back_porch);

endmodule


module timer(
	input clk,
	input reset,
	input [1:0] game_state,
	output reg [5:0] time_cnt
);
	//count down timer
	//todo
	
	reg [32:0] count;	//counter, every 250000000 count => plus 1 second

	always@(posedge clk or negedge reset) begin
		if(!reset) begin
			time_cnt <= 6'd60;
			count <= 33'd0;
		end else begin
			case(game_state)
				2'd0: begin
						//player 1 serve	
					end
				2'd1: begin
						//player 2 serve
					end
				2'd2: begin
						//playing
						count <= count + 1;
					end
				2'd3: begin
						//done
						count <= 0;
						time_cnt <= 6'd60;
					end
			endcase
			
			if(count >= 50000000) begin
				count <= 0;
				time_cnt <= time_cnt - 6'd1;		
			end
		end
	end

endmodule

module time_displayer(
	input [5:0] time_cnt,
	output reg [6:0] time_ten,
	output reg [6:0] time_one
);
	reg [5:0] ten, one;
	always@(time_cnt) begin
		//count now digit at ten and one
		one <= time_cnt % 6'd10;
		ten <= (time_cnt / 6'd10) % 6'd10;

		case(one)
			4'd0: time_one <= 7'b1000000;
			4'd1: time_one <= 7'b1111001;
			4'd2: time_one <= 7'b0100100;
			4'd3: time_one <= 7'b0110000;
			4'd4: time_one <= 7'b0011001;
			4'd5: time_one <= 7'b0010010;		
			4'd6: time_one <= 7'b0000010;
			4'd7: time_one <= 7'b1111000;
			4'd8: time_one <= 7'b0000000;
			4'd9: time_one <= 7'b0010000;
			default: time_one <= 7'b0000000;
		endcase
	
		case(ten)
			4'd0: time_ten <= 7'b1000000;
			4'd1: time_ten <= 7'b1111001;
			4'd2: time_ten <= 7'b0100100;
			4'd3: time_ten <= 7'b0110000;
			4'd4: time_ten <= 7'b0011001;
			4'd5: time_ten <= 7'b0010010;		
			4'd6: time_ten <= 7'b0000010;
			4'd7: time_ten <= 7'b1111000;
			4'd8: time_ten <= 7'b0000000;
			4'd9: time_ten <= 7'b0010000;
			default: time_ten <= 7'b0000000;
		endcase
	end

endmodule

module matrix_clk_divider(clk, reset, divided_clk);
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
		if(cnt == `MatrixExpire)
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

module matrix_displayer(
	input clk,
	input reset,
	input [1:0] game_state,
	input [3:0] p1_score,
	input [3:0] p2_score,
	output reg [7:0] dot_matrix_row,
	output reg [7:0] dot_matrix_left_col,
	output reg [7:0] dot_matrix_right_col
);
	//todo
	//letf represent player 1's score
	//right represent player 2's score
	parameter done = 2'd3;
	
	reg [2:0] row_count;
	
	always@(posedge clk) begin
		if(!reset) begin
			row_count <= 0;	//init
			dot_matrix_row <= 8'b11111111;
			dot_matrix_left_col <= 8'b00000000;
			dot_matrix_right_col <= 8'b00000000;
		end else begin
			if(game_state == done) begin
				//show who's the winner
				if(p1_score > p2_score) begin
					//P1
					//left matrix
					case(row_count)
						3'd0: dot_matrix_left_col <= 8'b00000000;
						3'd1: dot_matrix_left_col <= 8'b01111100;
						3'd2: dot_matrix_left_col <= 8'b01100100;
						3'd3: dot_matrix_left_col <= 8'b01100100;
						3'd4: dot_matrix_left_col <= 8'b01111100;
						3'd5: dot_matrix_left_col <= 8'b01100000;
						3'd6: dot_matrix_left_col <= 8'b01100000;
						3'd7: dot_matrix_left_col <= 8'b01100000;
					endcase
					
					//right matrix
					case(row_count)
						3'd0: dot_matrix_right_col <= 8'b00000000;
						3'd1: dot_matrix_right_col <= 8'b00011000;
						3'd2: dot_matrix_right_col <= 8'b00111000;
						3'd3: dot_matrix_right_col <= 8'b00011000;
						3'd4: dot_matrix_right_col <= 8'b00011000;
						3'd5: dot_matrix_right_col <= 8'b00011000;
						3'd6: dot_matrix_right_col <= 8'b01111100;
						3'd7: dot_matrix_right_col <= 8'b00000000;
					endcase
				end else if(p2_score > p1_score) begin
					//P2
					//left matrix
					case(row_count)
						3'd0: dot_matrix_left_col <= 8'b00000000;
						3'd1: dot_matrix_left_col <= 8'b01111100;
						3'd2: dot_matrix_left_col <= 8'b01100100;
						3'd3: dot_matrix_left_col <= 8'b01100100;
						3'd4: dot_matrix_left_col <= 8'b01111100;
						3'd5: dot_matrix_left_col <= 8'b01100000;
						3'd6: dot_matrix_left_col <= 8'b01100000;
						3'd7: dot_matrix_left_col <= 8'b01100000;
					endcase
					
					//right matrix
					case(row_count)
						3'd0: dot_matrix_right_col <= 8'b00000000;
						3'd1: dot_matrix_right_col <= 8'b00111000;
						3'd2: dot_matrix_right_col <= 8'b01101100;
						3'd3: dot_matrix_right_col <= 8'b00001100;
						3'd4: dot_matrix_right_col <= 8'b00011000;
						3'd5: dot_matrix_right_col <= 8'b00110000;
						3'd6: dot_matrix_right_col <= 8'b01111110;
						3'd7: dot_matrix_right_col <= 8'b00000000;
					endcase
				end else begin
					//same score
					//left matrix
					case(row_count)
						3'd0: dot_matrix_left_col <= 8'b00000000;
						3'd1: dot_matrix_left_col <= 8'b01111100;
						3'd2: dot_matrix_left_col <= 8'b01100100;
						3'd3: dot_matrix_left_col <= 8'b01100100;
						3'd4: dot_matrix_left_col <= 8'b01111100;
						3'd5: dot_matrix_left_col <= 8'b01100000;
						3'd6: dot_matrix_left_col <= 8'b01100000;
						3'd7: dot_matrix_left_col <= 8'b01100000;
					endcase
					
					//right matrix
					case(row_count)
						3'd0: dot_matrix_right_col <= 8'b00000000;
						3'd1: dot_matrix_right_col <= 8'b01111100;
						3'd2: dot_matrix_right_col <= 8'b01100100;
						3'd3: dot_matrix_right_col <= 8'b01100100;
						3'd4: dot_matrix_right_col <= 8'b01111100;
						3'd5: dot_matrix_right_col <= 8'b01100000;
						3'd6: dot_matrix_right_col <= 8'b01100000;
						3'd7: dot_matrix_right_col <= 8'b01100000;
					endcase
				
				end
			end else begin
				//show both player's score
				case(p1_score)
					3'd0: begin
						//left matrix
						case(row_count)
							3'd0: dot_matrix_left_col <= 8'b00000000;
							3'd1: dot_matrix_left_col <= 8'b00111100;
							3'd2: dot_matrix_left_col <= 8'b01100110;
							3'd3: dot_matrix_left_col <= 8'b11000011;
							3'd4: dot_matrix_left_col <= 8'b11000011;
							3'd5: dot_matrix_left_col <= 8'b01100110;
							3'd6: dot_matrix_left_col <= 8'b00111100;
							3'd7: dot_matrix_left_col <= 8'b00000000;
						endcase
					end
					3'd1: begin
						//left matrix
						case(row_count)
							3'd0: dot_matrix_left_col <= 8'b00000000;
							3'd1: dot_matrix_left_col <= 8'b00011000;
							3'd2: dot_matrix_left_col <= 8'b00111000;
							3'd3: dot_matrix_left_col <= 8'b00011000;
							3'd4: dot_matrix_left_col <= 8'b00011000;
							3'd5: dot_matrix_left_col <= 8'b00011000;
							3'd6: dot_matrix_left_col <= 8'b01111100;
							3'd7: dot_matrix_left_col <= 8'b00000000;
						endcase
					end
					3'd2: begin
						//left matrix
						case(row_count)
							3'd0: dot_matrix_left_col <= 8'b00000000;
							3'd1: dot_matrix_left_col <= 8'b00111100;
							3'd2: dot_matrix_left_col <= 8'b01100110;
							3'd3: dot_matrix_left_col <= 8'b00001100;
							3'd4: dot_matrix_left_col <= 8'b00011000;
							3'd5: dot_matrix_left_col <= 8'b00110000;
							3'd6: dot_matrix_left_col <= 8'b01111110;
							3'd7: dot_matrix_left_col <= 8'b00000000;
						endcase
					end
					3'd3: begin
						//left matrix
						case(row_count)
							3'd0: dot_matrix_left_col <= 8'b00000000;
							3'd1: dot_matrix_left_col <= 8'b00111100;
							3'd2: dot_matrix_left_col <= 8'b00000110;
							3'd3: dot_matrix_left_col <= 8'b00000110;
							3'd4: dot_matrix_left_col <= 8'b00111100;
							3'd5: dot_matrix_left_col <= 8'b00000110;
							3'd6: dot_matrix_left_col <= 8'b00000110;
							3'd7: dot_matrix_left_col <= 8'b00111100;
						endcase
					end
					3'd4: begin
							//left matrix
						case(row_count)
							3'd0: dot_matrix_left_col <= 8'b00000000;
							3'd1: dot_matrix_left_col <= 8'b00001110;
							3'd2: dot_matrix_left_col <= 8'b00010110;
							3'd3: dot_matrix_left_col <= 8'b00100110;
							3'd4: dot_matrix_left_col <= 8'b01000110;
							3'd5: dot_matrix_left_col <= 8'b11111110;
							3'd6: dot_matrix_left_col <= 8'b00000110;
							3'd7: dot_matrix_left_col <= 8'b00000110;
						endcase
					end
					3'd5: begin
						//left matrix
						case(row_count)
							3'd0: dot_matrix_left_col <= 8'b00000000;
							3'd1: dot_matrix_left_col <= 8'b00111110;
							3'd2: dot_matrix_left_col <= 8'b00100000;
							3'd3: dot_matrix_left_col <= 8'b00100000;
							3'd4: dot_matrix_left_col <= 8'b00111110;
							3'd5: dot_matrix_left_col <= 8'b00000010;
							3'd6: dot_matrix_left_col <= 8'b00000010;
							3'd7: dot_matrix_left_col <= 8'b00111110;
						endcase
					end
					3'd6: begin
						//left matrix
						case(row_count)
							3'd0: dot_matrix_left_col <= 8'b00000000;
							3'd1: dot_matrix_left_col <= 8'b01111100;
							3'd2: dot_matrix_left_col <= 8'b01100000;
							3'd3: dot_matrix_left_col <= 8'b01100000;
							3'd4: dot_matrix_left_col <= 8'b01111110;
							3'd5: dot_matrix_left_col <= 8'b01100010;
							3'd6: dot_matrix_left_col <= 8'b01100010;
							3'd7: dot_matrix_left_col <= 8'b01111110;
						endcase
					end
					3'd7: begin
						//left matrix
						case(row_count)
							3'd0: dot_matrix_left_col <= 8'b00000000;
							3'd1: dot_matrix_left_col <= 8'b01111110;
							3'd2: dot_matrix_left_col <= 8'b00000110;
							3'd3: dot_matrix_left_col <= 8'b00001100;
							3'd4: dot_matrix_left_col <= 8'b00011000;
							3'd5: dot_matrix_left_col <= 8'b00110000;
							3'd6: dot_matrix_left_col <= 8'b01100000;
							3'd7: dot_matrix_left_col <= 8'b01100000;
						endcase
					end
				endcase
				
				case(p2_score)
					3'd0: begin
						//left matrix
						case(row_count)
							3'd0: dot_matrix_right_col <= 8'b00000000;
							3'd1: dot_matrix_right_col <= 8'b00111100;
							3'd2: dot_matrix_right_col <= 8'b01100110;
							3'd3: dot_matrix_right_col <= 8'b11000011;
							3'd4: dot_matrix_right_col <= 8'b11000011;
							3'd5: dot_matrix_right_col <= 8'b01100110;
							3'd6: dot_matrix_right_col <= 8'b00111100;
							3'd7: dot_matrix_right_col <= 8'b00000000;
						endcase
					end
					3'd1: begin
						//left matrix
						case(row_count)
							3'd0: dot_matrix_right_col <= 8'b00000000;
							3'd1: dot_matrix_right_col <= 8'b00011000;
							3'd2: dot_matrix_right_col <= 8'b00111000;
							3'd3: dot_matrix_right_col <= 8'b00011000;
							3'd4: dot_matrix_right_col <= 8'b00011000;
							3'd5: dot_matrix_right_col <= 8'b00011000;
							3'd6: dot_matrix_right_col <= 8'b01111100;
							3'd7: dot_matrix_right_col <= 8'b00000000;
						endcase
					end
					3'd2: begin
						//left matrix
						case(row_count)
							3'd0: dot_matrix_right_col <= 8'b00000000;
							3'd1: dot_matrix_right_col <= 8'b00111100;
							3'd2: dot_matrix_right_col <= 8'b01100110;
							3'd3: dot_matrix_right_col <= 8'b00001100;
							3'd4: dot_matrix_right_col <= 8'b00011000;
							3'd5: dot_matrix_right_col <= 8'b00110000;
							3'd6: dot_matrix_right_col <= 8'b01111110;
							3'd7: dot_matrix_right_col <= 8'b00000000;
						endcase
					end
					3'd3: begin
						//left matrix
						case(row_count)
							3'd0: dot_matrix_right_col <= 8'b00000000;
							3'd1: dot_matrix_right_col <= 8'b00111100;
							3'd2: dot_matrix_right_col <= 8'b00000110;
							3'd3: dot_matrix_right_col <= 8'b00000110;
							3'd4: dot_matrix_right_col <= 8'b00111100;
							3'd5: dot_matrix_right_col <= 8'b00000110;
							3'd6: dot_matrix_right_col <= 8'b00000110;
							3'd7: dot_matrix_right_col <= 8'b00111100;
						endcase
					end
					3'd4: begin
							//left matrix
						case(row_count)
							3'd0: dot_matrix_right_col <= 8'b00000000;
							3'd1: dot_matrix_right_col <= 8'b00001110;
							3'd2: dot_matrix_right_col <= 8'b00010110;
							3'd3: dot_matrix_right_col <= 8'b00100110;
							3'd4: dot_matrix_right_col <= 8'b01000110;
							3'd5: dot_matrix_right_col <= 8'b11111110;
							3'd6: dot_matrix_right_col <= 8'b00000110;
							3'd7: dot_matrix_right_col <= 8'b00000110;
						endcase
					end
					3'd5: begin
						//left matrix
						case(row_count)
							3'd0: dot_matrix_right_col <= 8'b00000000;
							3'd1: dot_matrix_right_col <= 8'b00111110;
							3'd2: dot_matrix_right_col <= 8'b00100000;
							3'd3: dot_matrix_right_col <= 8'b00100000;
							3'd4: dot_matrix_right_col <= 8'b00111110;
							3'd5: dot_matrix_right_col <= 8'b00000010;
							3'd6: dot_matrix_right_col <= 8'b00000010;
							3'd7: dot_matrix_right_col <= 8'b00111110;
						endcase
					end
					3'd6: begin
						//left matrix
						case(row_count)
							3'd0: dot_matrix_right_col <= 8'b00000000;
							3'd1: dot_matrix_right_col <= 8'b01111100;
							3'd2: dot_matrix_right_col <= 8'b01100000;
							3'd3: dot_matrix_right_col <= 8'b01100000;
							3'd4: dot_matrix_right_col <= 8'b01111110;
							3'd5: dot_matrix_right_col <= 8'b01100010;
							3'd6: dot_matrix_right_col <= 8'b01100010;
							3'd7: dot_matrix_right_col <= 8'b01111110;
						endcase
					end
					3'd7: begin
						//left matrix
						case(row_count)
							3'd0: dot_matrix_right_col <= 8'b00000000;
							3'd1: dot_matrix_right_col <= 8'b01111110;
							3'd2: dot_matrix_right_col <= 8'b00000110;
							3'd3: dot_matrix_right_col <= 8'b00001100;
							3'd4: dot_matrix_right_col <= 8'b00011000;
							3'd5: dot_matrix_right_col <= 8'b00110000;
							3'd6: dot_matrix_right_col <= 8'b01100000;
							3'd7: dot_matrix_right_col <= 8'b01100000;
						endcase
					end
				endcase
			end
			
			//row matrix
			case(row_count)
				3'd0: dot_matrix_row <= 8'b01111111;
				3'd1: dot_matrix_row <= 8'b10111111;
				3'd2: dot_matrix_row <= 8'b11011111;
				3'd3: dot_matrix_row <= 8'b11101111;
				3'd4: dot_matrix_row <= 8'b11110111;
				3'd5: dot_matrix_row <= 8'b11111011;
				3'd6: dot_matrix_row <= 8'b11111101;
				3'd7: dot_matrix_row <= 8'b11111110;
			endcase
				
			row_count <= row_count + 3'd1;
		end
	end
endmodule 


