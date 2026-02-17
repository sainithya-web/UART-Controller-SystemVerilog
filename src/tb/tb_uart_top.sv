`timescale 1ns/1ps

module tb_uart_tx;

    // --- 1. Signals ---
    logic clk;
    logic rst_n;
    logic [7:0] tx_data;
    logic tx_start;
    logic tx_line;
    logic tx_busy;

    // --- 2. Instantiate UUT ---
    uart_tx uut (.*);

    // --- 3. 50MHz Clock Generation (20ns period) ---
    always #10 clk = (clk === 1'b0);

    // --- 4. Stimulus ---
    initial begin
        // Initialize
        clk = 0; rst_n = 0; tx_start = 0; tx_data = 8'h00;
        
        // Release Reset
        #100 rst_n = 1;
        #100;

        // Send Byte: 0xA5 (10100101 in binary)
        @(posedge clk);
        tx_data = 8'hA5; 
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;

        // Wait for transmission to complete
        wait(tx_busy == 1);
        wait(tx_busy == 0);
        
        $display("[INFO] Transmission of 0xA5 Complete at %0t", $time);

        #500000; // Wait some time to see the stop bit clearly
        $finish;
    end

    // --- 5. Waveform Dump ---
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_uart_tx);
    end

endmodule

`timescale 1ns/1ps

module tb_uart_top;
    logic clk, rst_n;
    logic [7:0] tx_data, rx_data;
    logic tx_start, tx_line, tx_busy, rx_done;

    // 1. Connect TX and RX (Loopback)
    uart_tx transmitter (
        .clk(clk), .rst_n(rst_n), .tx_data(tx_data), .tx_start(tx_start),
        .tx_line(tx_line), .tx_busy(tx_busy)
    );

    uart_rx receiver (
        .clk(clk), .rst_n(rst_n), .rx_line(tx_line), // tx_line feeds rx_line
        .rx_data(rx_data), .rx_done(rx_done)
    );

    // 2. Clock Gen (50MHz)
    always #10 clk = (clk === 1'b0);

    // 3. Stimulus
    initial begin
        clk = 0; rst_n = 0; tx_start = 0; tx_data = 8'h00;
        #100 rst_n = 1;

        // Send Byte 0x55 (Alternating 1s and 0s)
        @(posedge clk);
        tx_data = 8'h55; 
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;

        // Wait for the Receiver to finish
        wait(rx_done);
        if (rx_data == 8'h55) 
            $display("[SUCCESS] Loopback: Sent 0x55, Received 0x55 at %0t", $time);
        else 
            $display("[ERROR] Loopback: Sent 0x55, Received %h", rx_data);

        #500000;
        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_uart_top);
    end
endmodule
