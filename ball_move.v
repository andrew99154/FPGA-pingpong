module ball_move(
	input clk,
	input  [9:0] now_speed_x,
	input  [9:0] now_speed_y,
	output reg [9:0] ball_x,
	output reg [9:0] ball_y
);

	always @ (posedge clk) begin
		ball_x <= ball_x + now_speed_x;
		ball_y <= ball_y + now_speed_y;
	end

endmodule

