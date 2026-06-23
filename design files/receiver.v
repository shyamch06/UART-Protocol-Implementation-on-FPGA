module receiver (
    input clk,rst,clk_en,rx,
    output reg rdy,
    output reg [7:0] data_out
);
    
    parameter START = 2'b00;
    parameter DATAOUT = 2'b01;
    parameter STOP = 2'b10;

    reg [1:0] state;
    reg [3:0] sample;
    reg [2:0] count;
    reg [7:0] temp_reg;

    always@(posedge clk) begin
        rdy <= 1'b0;
        if(rst) begin
            rdy <= 0;
            data_out <= 0;
            state <= START;
            sample <= 0;
            count <= 0;
            temp_reg <= 0;
        end

        else begin
             rdy <= 0;

            if(clk_en)
            case(state) 
                START : begin
                    if(rx == 0) begin
                        sample <= 0;
                        count <= 0;
                        temp_reg <= 0;
                        state <= DATAOUT;
                    end
                end

                DATAOUT: begin
                    if(sample==15) begin
                        sample<=0;
                        temp_reg[count]<=rx;

                        if(count==7)
                            state<=STOP;
                        else
                            count<=count+1;
                    end
                    else
                        sample<=sample+1;
                end

                STOP: begin
                    if(sample == 15) begin
                        sample <= 0;
                        if(rx == 1) begin
                        data_out <= temp_reg;
                        rdy <= 1'b1;
                        end
                        state <= START;
                    end
                    else begin
                        sample <= sample + 1;
                    end
                end

                default : state <= START;
            endcase
        end
    end
endmodule