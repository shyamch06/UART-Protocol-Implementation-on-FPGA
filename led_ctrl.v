module led_ctrl(
    input [7:0] led, 
    input swap,clk,rst,rdy,
    output [7:0] data_out
);
reg[7:0] led_reg;
    always@(posedge clk) begin
        if(rst)
            led_reg <= 8'b0;
        else if(rdy)
            led_reg <= led;
    end
    assign data_out =  swap ? {led_reg[3:0],led_reg[7:4]}: led_reg;
endmodule