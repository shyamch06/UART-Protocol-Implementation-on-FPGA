# UART-Protocol-Implementation-on-FPGA
This project implements a Univeral asynchronous Receiver Transmitter(UART) communication system in Verilog HDL and deploys it on the Basys 3 FPGA using Xilinx Vivado. The objective is to establish reliable serial communication between a computer and the FPGA through  a UART interface operating at 115200 baud.

---

## Features

- UART Transmitter
- UART Receiver
- 115200 baud serial communication
- LED visualization of received data
- FPGA-to-PC and PC-to-FPGA communication
- Four-digit seven-segment display output

- --

## Hardware Used

- Basys3 FPGA Board
- USB-UART
- Seven Segment Display
- On board LEDs
- Push Buttons and Switches

   ---

  ## Software Used
  
- PC Terminal Software(PuTTY)
- Vivado
- Verilog HDL
- GTK Wave

- --

## UART Configuration

| Parameter | Value |
|---|---|
| Clock Frequency | 100MHz |
| Baud Rate | 115200|
| Data Bits | 8 |
| Parity | None |
| Stop Bits | 1 |

---

## System Architecture

```text
  PC Terminal
     ↓
    UART <-  UART TX FSM 
     ↓               
UART Receiver  
     ↓
LED Controller
     ↓
BCD Converter 
     ↓
7-Segment Disp
```
---

## Working Principle
PC -> FPGA Communication

1. A character is sent from the terminal.
2. The UART receiver captures the serial data.
3. The received byte is stored internally.
4. The binary value is displayed on LED.
5. The decimal equivalent is shown on the seven-segment display.

 FPGA -> PC Communication

 1. User selects an 8-bit value using FPGA inputs.
 2. A transmit request is generated.
 3. The UART transmitter serializes the data.
 4. The transmitted character appears on the PC terminal.

    ---

 ## File Structure

| File | Description |
|---|---|
| `top_module.v` | Top module |
| `transmittor.v` | UART transmitter |
| `receiver.v` | UART receiver |
| `baud_rate_gen.v` | Receiver Baud generator |
| `tx_baud_gen.v` | Transmitter Baud generator |
| `led_ctrl.v` | Stores and processes received data |
| `display_unit.v` | Display module |
| `seg7_display.v` | 7-segment display |
| `FPGA_UART_conversion.py` | Python UART monitor |

---
## Applications

- Serial Communication
- FPGA Communication Interfaces
- Embedded Systems

  ---
## Future Improvements

- Configurable Baaud rate
- UART echo functionality
- Parity error detection
- FIFO integration

- --
## Author

Cherukuri ShyamSundhar
Electronics and Communication Engineering
IIT Bhubaneswar
