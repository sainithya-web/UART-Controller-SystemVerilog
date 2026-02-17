UART Controller with 16x Oversampling & CDC Synchronization
Overview
This project implements a full-duplex UART (Universal Asynchronous Receiver-Transmitter) controller in SystemVerilog. It is designed to handle asynchronous serial communication between two independent clock domains.

Key Technical Features
16x Oversampling: The receiver samples the incoming rx_line 16 times per bit period to identify the ideal "center-sampling" point, ensuring robust data recovery even with slight clock drift.

Clock Domain Crossing (CDC) Mitigation: Implemented a 2-stage flip-flop synchronizer on the asynchronous rx_line to eliminate metastability issues.

Configurable Baud Rate: Uses a high-speed clock divider (e.g., 50MHz to 9600 baud) controlled via local parameters.

Clean Reset Logic: Fully synchronous initialization to prevent NaN or unknown states in hardware.

Verification
The design was verified using a Loopback Testbench where the Transmitter output was fed directly into the Receiver.

Result: tx_data (0x55) successfully matched rx_data (0x55) with the rx_done flag pulsing correctly at the end of transmission.
