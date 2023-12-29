`define TimeExpire 32'd416667 //60fps

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