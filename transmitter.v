module transmitter (
    input clk,
    input wr_enb,
    input enb,
    input rst,
    input [7:0] data_in,
    output reg tx,
    output reg busy
);
    parameter IDLE  = 2'b00;
    parameter START = 2'b01;
    parameter DATA  = 2'b10;
    parameter STOP  = 2'b11;

    reg [2:0] index;
    reg [7:0] data_reg;
    reg [1:0] state;

    always@(posedge clk) begin
        if(rst) begin
            state <= IDLE;
            data_reg <= 0;
            index <= 0;

            busy <= 0;
            tx <= 1'b1;
            
        end
        else begin
            case(state)

            IDLE: begin
                tx <= 1'b1;
                busy <= 1'b0;
                if(wr_enb) begin
                    busy <= 1'b1;
                    state <= START;
                    data_reg <= data_in;
                    index <= 3'b000;
                end
                else state <= IDLE;
            end

            START : begin
                if(enb == 1) begin
                    tx <= 1'b0;
                    state <= DATA;
                end
                else state <= START;
            end

            DATA : begin
                if (enb == 1) begin
                    tx <= data_reg[index];
                    if (index == 3'b111) begin
                        state <= STOP;
                    end
                    else begin
                         index <= index + 1;
                         
                    end
                end
            end

            STOP: begin
                if(enb) begin
                    tx <= 1'b1;
                    state <= IDLE;
                    busy <= 0;
                end
            end

            default : begin
                tx <= 1'b1;
                state <= IDLE;
            end

            endcase
        end
    end

endmodule
