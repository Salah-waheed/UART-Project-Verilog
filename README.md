# UART Communication Module (Verilog HDL)

**Institution:** Cairo University, Faculty of Engineering  
**Developed by:** Salah Waheed

## Overview
This repository contains a modular implementation of a **UART (Universal Asynchronous Receiver-Transmitter)** protocol in Verilog. UART is a fundamental asynchronous serial communication protocol used extensively in digital systems for data exchange between FPGAs, microcontrollers, and PCs. 

## Technical Specifications
The module is designed with a standard **8N1** configuration to ensure compatibility with most serial terminals:
* **Data Bits:** 8 bits per frame.
* **Parity:** None.
* **Stop Bits:** 1.
* **Baud Rate:** Configurable via an internal clock divider.
* **Oversampling:** The receiver utilizes 16x oversampling to ensure accurate data capture and noise immunity.


## Hardware Architecture & Modules
The design is partitioned into three main functional blocks to ensure high modularity and ease of integration:

* **UART Top (`uart_top.v`):** The top-level entity that instantiates and interconnects the transmitter, receiver, and baud rate generator modules for full-duplex operation.
* **Baud Rate Generator (`baud_rate_gen.v`):** A programmable frequency divider that generates the 16x oversampling ticks required for precise synchronization between the transmitter and receiver.
* **UART Transmitter (`uart_tx.v`):** Implements a Finite State Machine (FSM) to convert parallel 8-bit data into a serial stream. It handles the generation of the mandatory **Start Bit** (low) and **Stop Bit** (high).
* **UART Receiver (`uart_rx.v`):** Features a robust FSM that detects the falling edge of the Start Bit and samples the incoming serial data at the center of each bit period to maximize the timing margin.


## FSM State Logic
Both the TX and RX units utilize a 4-state Finite State Machine:
1. **IDLE:** Line is held high; waiting for a trigger or start bit.
2. **START:** Synchronization period where the start bit is transmitted/detected.
3. **DATA:** Sequential processing of the 8-bit data payload.
4. **STOP:** Frame completion and verification of the stop bit.

## Simulation & Verification
* **Environment:** Developed and simulated using **Xilinx Vivado**.
* **Functional Validation:** A custom testbench was used to verify the baud rate accuracy and data integrity across various transmission sequences.
* **Waveform Evidence:** Simulation results demonstrate successful Start-bit synchronization and correct bit-shifting at the defined baud rate intervals.


## Repository Structure
* `/rtl`: Synthesizable Verilog source files for all modules.
* `/sim`: Testbench files and simulation configurations.
* `/docs`: Project report and detailed timing diagrams.# UART Communication Module (Verilog HDL)