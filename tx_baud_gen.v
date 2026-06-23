module tx_baud_gen(
    input clk,
    input rst,
    output tx_en
);

reg [9:0] counter;

always @(posedge clk)
begin
    if(rst)
        counter <= 0;
    else if(counter == 867)
        counter <= 0;
    else
        counter <= counter + 1;
end

assign tx_en = (counter == 0);

endmodule