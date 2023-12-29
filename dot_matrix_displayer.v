`define MatrixExpire 32'd2500

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
