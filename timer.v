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