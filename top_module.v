

module top_module (
    input rst,clk,rx,btnu,swap,
    input [7:0] data_in,
    output tx,
    output [7:0] data_out,
    output [6:0] seg,
    output [3:0]an
);
    wire rx_clk_en; // collecting output of baud rate generator rx_enb signal
    wire rdy;
    wire [7:0] led;
    wire [15:0]bcd;
    wire [3:0]digit;
    baud_rate_gen brg(clk,rst,rx_clk_en);
    receiver rec(clk,rst,rx_clk_en,rx,rdy,led);
    led_ctrl uut0(led,swap,clk,rst,rdy,data_out);
    bcdconvertor uut1(data_out,bcd);
    display uut2(an,digit,bcd[3:0],bcd[7:4],bcd[11:8],bcd[15:12],clk);
    sevenseg uut3(digit,seg);

   wire tx_clk_en;
   wire tx_busy;
   wire [7:0] tx_data;
   wire tx_wr;
   reg btnu_d;
   
   tx_baud_gen txbg(
   .clk(clk),
   .rst(rst),
   .tx_en(tx_clk_en)
);

transmitter tx_inst(
   .clk(clk),
   .wr_enb(tx_wr),
   .enb(tx_clk_en),
   .rst(rst),
   .data_in(tx_data),
   .tx(tx),
   .busy(tx_busy)
);


always @(posedge clk)
begin
    btnu_d <= btnu;
end

assign tx_wr = btnu & ~btnu_d;
assign tx_data = data_in;

endmodule
