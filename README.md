# FPGA UART Hardware Echo Test

A minimal, pure-FPGA UART loopback design written in Verilog. This project provides a plain echo test to isolate and verify basic serial link functionality (pins, baud rate, wiring, and driver) before trusting any result from a full design[cite: 5]. It instantly takes any byte received from a PC via a USB-to-TTL adapter and echoes it back.

## Features

* **High-Speed Serial Communication:** Configured for a baud rate of 921600[cite: 8].
* **Robust Reception:** The receiver module utilizes a 16x oversampling technique (14.745 MHz internal tick) to ensure accurate bit sampling and reduce noise susceptibility[cite: 6].
* **Data Loss Prevention:** The top-level module features a 1-byte pending buffer and edge-detection logic; if the transmitter is busy when a new byte arrives, it queues the byte instead of silently dropping it[cite: 7].
* **Standard Protocol:** Uses the standard 8-N-1 UART framing (1 start bit, 8 data bits, 1 stop bit)[cite: 8].

## Hardware Requirements

* **FPGA Board:** Sipeed Tang Primer 25K (Gowin GW5A) or similar FPGA with a 50MHz clock. 
* **Serial Adapter:** A 3.3V USB-to-TTL Serial Adapter. 
  * *Warning:* The FPGA IO ports are configured for LVCMOS33 (3.3V)[cite: 5]. Ensure your serial adapter is operating at 3.3V logic levels to avoid damaging the FPGA pins.
* **Development Environment:** Gowin EDA.

## Pinout & Constraints

The physical pin constraints are mapped in the `uart_loopback.cst` file[cite: 5]:

| Signal | FPGA Pin | IO Standard | Description |
| :--- | :--- | :--- | :--- |
| `clk` | **E2** | LVCMOS33 | 50MHz Board Clock[cite: 5] |
| `uart_rx`| **B3** | LVCMOS33 | Data coming in from the PC[cite: 5, 7] |
| `uart_tx`| **C3** | LVCMOS33 | Data going out to the PC[cite: 5, 7] |

*Note: Both `clk` and `uart_rx` are configured with `PULL_MODE=UP`[cite: 5].*

## File Structure

* `uart_top.v`: The top-level module that instantiates the RX and TX modules, handling the routing and buffering of the 8-bit data payload between them[cite: 7].
* `UART.v`: The UART receiver module containing the state machine for detecting start bits, shifting in the 8 data bits, and asserting the `data_valid` flag[cite: 6].
* `UART_tx.v`: The UART transmitter module that packages the 8-bit data into a 10-bit frame and shifts it out over the TX line[cite: 8].
* `P.cst`: The physical constraint file mapping the Verilog top module ports to the specific pins on the FPGA[cite: 5].

## Quick Start & Testing

1. **Synthesize & Flash:** Open the project in Gowin EDA, run the synthesis and place & route processes, and flash the resulting bitstream to your FPGA SRAM or Flash.
2. **Wire the Hardware:** 
   * Connect your USB-to-TTL adapter's **TX** pin to the FPGA's **RX** pin (B3).
   * Connect the adapter's **RX** pin to the FPGA's **TX** pin (C3).
   * Connect the adapter's **GND** to the FPGA's **GND**.
3. **Open a Serial Terminal:** Open PuTTY, TeraTerm, or your preferred serial monitor on your PC.
4. **Configure Port Settings:**
   * **Baud Rate:** 921600
   * **Data Bits:** 8
   * **Parity:** None
   * **Stop Bits:** 1
   * **Flow Control:** None
5. **Test the Echo:** Type any character on your keyboard. The terminal should immediately display the character you typed, confirming that the full RX/TX hardware loopback pipeline is functioning correctly.
