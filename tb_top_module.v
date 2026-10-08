`timescale 1ns / 1ps

module tb_top_module;

    // Inputs
    reg rst;
    reg clk;
    reg rx;
    reg btnu;
    reg swap;
    reg [7:0] data_in;

    // Outputs
    wire tx;
    wire [7:0] data_out;
    wire [6:0] seg;
    wire [3:0] an;

    // Instantiate the Unit Under Test (UUT)
    top_module uut (
        .rst(rst),
        .clk(clk),
        .rx(rx),
        .btnu(btnu),
        .swap(swap),
        .data_in(data_in),
        .tx(tx),
        .data_out(data_out),
        .seg(seg),
        .an(an)
    );

    // Clock generation: 100 MHz clock (10ns period)
    always #5 clk = ~clk;

    // ---- Self-checking result tracking ----
    integer pass_count;
    integer fail_count;
    integer total_checks;

    task check(input pass, input [8*40:1] label);
        begin
            total_checks = total_checks + 1;
            if (pass) begin
                $display("PASS: %0s", label);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s", label);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ---------------------------------------------------------------
    // RX path: emulate sending a complete UART byte into the RX pin.
    // Uses 16x oversampling tick timing based on the receiver's own
    // rx_clk_en (baud_rate_gen), so bit cells line up with what the
    // receiver actually samples.
    // ---------------------------------------------------------------
    task send_uart_byte(input [7:0] b);
        integer bit_idx;
        begin
            @(posedge uut.rx_clk_en);
            rx = 1'b0; // start bit

            for (bit_idx = 0; bit_idx < 8; bit_idx = bit_idx + 1) begin
                repeat(16) @(posedge uut.rx_clk_en);
                rx = b[bit_idx]; // LSB first
            end

            repeat(16) @(posedge uut.rx_clk_en);
            rx = 1'b1; // stop bit

            repeat(32) @(posedge uut.rx_clk_en); // idle gap between bytes
        end
    endtask

    // ---------------------------------------------------------------
    // TX path: decode a byte driven out on tx by sampling once per
    // tx_clk_en pulse (tx_baud_gen), matching the transmitter's own
    // one-bit-per-baud-tick shift timing.
    // ---------------------------------------------------------------
    task receive_uart_byte(output [7:0] b);
        integer k;
        localparam BIT_PERIOD = 8680; // ns: 868 cycles x 10ns, matches tx_baud_gen (115200 baud)
        begin
            @(negedge tx);                    // start bit begins
            $display("  [decode] start bit detected at time=%0t", $time);
            #(BIT_PERIOD + BIT_PERIOD/2);      // move to the center of bit 0 (1.5 bit periods in)
            for (k = 0; k < 8; k = k + 1) begin
                b[k] = tx;                     // LSB first, matches transmitter's index order
                $display("  [decode] bit %0d sampled = %b at time=%0t", k, tx, $time);
                #(BIT_PERIOD);                 // advance to the center of the next bit
            end
            $display("  [decode] stop bit sampled = %b at time=%0t", tx, $time);
        end
    endtask

    reg [7:0] tx_result;

    initial begin
        pass_count   = 0;
        fail_count   = 0;
        total_checks = 0;

        // Initialize Signals
        clk    = 0;
        rst    = 1;
        rx     = 1'b1; // UART idle line state is high
        btnu   = 0;
        swap   = 0;
        data_in = 8'h00;

        #100;
        rst = 0;
        #200;

        // --- TEST 1: RX path -- send 8'h35 into rx, check data_out ---
        $display("[%0t ns] TEST 1: RX receive path", $time);
        send_uart_byte(8'h35);
        #1000;
        check(data_out == 8'h35, "RX receiver correctly caught 0x35");

        // --- TEST 2: swap feature on LED controller ---
        $display("[%0t ns] TEST 2: nibble swap", $time);
        swap = 1'b1;
        #1000;
        check(data_out == 8'h53, "Swap correctly turned 0x35 into 0x53");
        swap = 1'b0;
        #1000;

        // --- TEST 3: TX path -- press btnu, decode tx, compare to data_in ---
        $display("[%0t ns] TEST 3: TX transmit path", $time);
        data_in = 8'hA5;
        @(posedge clk);
        btnu <= 1;
        @(posedge clk);
        btnu <= 0;

        fork : tx_wait
            begin
                receive_uart_byte(tx_result);
                disable tx_wait;
            end
            begin
                #120000000; // safety timeout -- comfortably covers 10 bit
                            // periods (~86,800,000) with margin, unlike the
                            // original #200000 which fired almost instantly
                disable tx_wait;
            end
        join

        check(tx_result == 8'hA5, "TX transmitter correctly sent 0xA5");
        $display("  (decoded tx_result = 0x%h, expected 0xA5)", tx_result);

        #10000;

        $display("---------------------------------------------");
        $display("Summary: %0d PASS, %0d FAIL out of %0d checks", pass_count, fail_count, total_checks);
        $display("---------------------------------------------");
        $finish;
    end

    // Terminal Monitor Log
    initial begin
        $monitor("Time=%0t | rst=%b | rx=%b | tx=%b | data_out=%h | an=%b | seg=%b",
                 $time, rst, rx, tx, data_out, an, seg);
    end

    // Dump Waves for GTKWave or Vivado
    initial begin
        $dumpfile("uart_system.vcd");
        $dumpvars(0, tb_top_module);
    end

endmodule