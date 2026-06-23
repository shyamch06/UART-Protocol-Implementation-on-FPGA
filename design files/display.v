module display(an,digit,ones,tens,hunds,thsnds,clk);
input clk;
input [3:0] ones,tens,hunds,thsnds;
output reg [3:0] an;
output reg [3:0] digit;

reg [19:0] refresh = 0;
reg [1:0]sel;

always @(posedge clk) begin
    refresh <= refresh + 1;
    sel <= refresh[19:18];
end

always @(*)
    case (sel) 
        2'b00: begin
            an = 4'b1110;  
            digit = ones;
        end
        2'b01: begin
            an = 4'b1101;  
            digit = tens;
        end
        2'b10: begin
            an = 4'b1011;  
            digit = hunds;
        end
        2'b11: begin
            an = 4'b0111;  
            digit = thsnds;
        end
        default: begin
            an = 4'b1111;
            digit = 4'b0000;
        end
    endcase
 

endmodule
