# UART Controller with 16x Oversampling & CDC Synchronization

## 📌 Project Overview
This repository contains a robust, full-duplex **UART (Universal Asynchronous Receiver-Transmitter)** controller implemented in SystemVerilog. Unlike standard serial controllers, this design is built for real-world hardware reliability, addressing asynchronous signal integrity and clock recovery.

## 🛠 Technical Features
* **16x Oversampling Logic:** The receiver samples the incoming `rx_line` at 16 times the baud rate. It identifies the falling edge of the Start bit and counts 8 ticks to sample precisely at the **center of the bit**, maximizing setup/hold time margins.
* **Clock Domain Crossing (CDC) Mitigation:** Includes a **2-stage flip-flop synchronizer** on the asynchronous `rx_line` input to prevent metastability issues when interfacing with external clock domains.
* **Parameterizable Baud Rate:** Currently configured for **9600 Baud** using a 50MHz system clock (Divider: 5208). The baud rate is easily adjustable via the `CLK_PER_BIT` parameter.
* **FSM-Based Design:** Independent Finite State Machines (FSM) for both Transmitter (TX) and Receiver (RX) to ensure clean state transitions (IDLE, START, DATA, STOP).
* **Hardware-Ready RTL:** Fully synchronous reset logic ensures no `NaN` or unknown states ('x') exist upon initialization.

## 🏗 System Architecture
The system consists of two primary modules connected in a loopback configuration for verification:
1.  **Transmitter (TX):** Converts 8-bit parallel data into a serial stream.
2.  **Receiver (RX):** Reconstructs the 8-bit parallel data from the serial stream using oversampling clock recovery.



## 📊 Verification & Waveforms
The design was verified using a **Loopback Testbench** in EDA Playground.

### Key Observation Points:
* **Start Bit Detection:** The `rx_sync` signal correctly identifies the falling edge of the `tx_line`.
* **Center Sampling:** The `sample_count` signal shows the receiver sampling data bits at the 15th tick of the oversampling clock (the center of the bit period).
* **Data Integrity:** As shown in the waveform, `tx_data` (0x55) is successfully reconstructed as `rx_data` (0x55) with the `rx_done` flag pulsing high upon completion.



## 📂 File Structure
* `src/uart_tx.sv`: Transmitter RTL logic.
* `src/uart_rx.sv`: Receiver RTL logic with synchronizer and oversampling.
* `tb/tb_uart_top.sv`: Top-level loopback testbench for verification.

## 🚀 How to Use
1.  Clone the repository.
2.  Open the files in any SystemVerilog simulator (Vivado, Questa, or EDA Playground).
3.  Run the testbench `tb_uart_top.sv` to observe the loopback success.
