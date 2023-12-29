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
					green <= 4'hF; //ball is yellow 
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
