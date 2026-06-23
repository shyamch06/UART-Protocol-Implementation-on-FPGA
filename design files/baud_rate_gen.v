module baud_rate_gen (
    input clk,
    input rst,
    output rx_enb
);
    reg [5:0] rx_counter;
    // clk = 100MHz and baud rate = 115200;
    always @(posedge clk) begin
        if(rst) begin
            rx_counter <= 0;
        end
        else begin

            if(rx_counter == 53) rx_counter <= 0;
            else rx_counter <= rx_counter + 1;
        end
    end
    assign rx_enb = (rx_counter ==  0);
endmodule
