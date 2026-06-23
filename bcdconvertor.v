module bcdconvertor(bin,bcd);
input [7:0] bin;
output reg [15:0]bcd;
integer i; // to use in for loop
always @(*) begin
    bcd = 16'd0; // initiate with 0

    for(i = 7; i >=0 ; i = i-1) //repeat for each binary bit (MSB → LSB)
    begin
        if (bcd[3:0] > 4) bcd[3:0] = bcd[3:0] + 3; //if ones digit > 4 → add 3
        if (bcd[7:4] > 4) bcd[7:4] = bcd[7:4] + 3; //if tens digit > 4 → add 3
        if (bcd[11:8] > 4) bcd[11:8] = bcd[11:8] + 3; //if hundreds digit > 4 → add 3
        if (bcd[15:12] > 4) bcd[15:12] = bcd[15:12] + 3; //if thousands digit > 4 → add 3

        bcd = bcd << 1; //shift left whole BCD
        bcd[0] = bin[i]; // insert current binary bit into LSB

    end
end
endmodule