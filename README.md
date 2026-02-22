# UART Design in Verilog HDL

**Author:** Salah Waheed

---

##  Project Overview

This project presents the design and implementation of a **Universal Asynchronous Receiver/Transmitter (UART)** using **Verilog HDL**.

The design is fully modular and consists of:

* **Transmitter (TX)** – parallel-to-serial conversion
* **Receiver (RX)** – serial-to-parallel conversion using **16× oversampling**
* **Baud Rate Generator** – produces both 1× and 16× timing clocks

The system was designed with synthesizable RTL practices and verified through simulation using a loopback testbench.

---

##  Abstract

This UART implementation includes three modular components:

* A transmitter that serializes 8-bit parallel data
* A receiver that uses **16× oversampling** for robust data recovery
* A configurable baud-rate generator providing both 1× and 16× clocks

The oversampling technique improves tolerance to:

* Clock mismatch
* Jitter
* Bit-edge uncertainty
* Line noise

Functional verification was performed using loopback simulation where TX output is connected to RX input. Results confirmed correct end-to-end transmission across multiple baud rates.

---

##  Introduction

UART is a widely used asynchronous serial communication protocol used for communication between:

* Microcontrollers
* Sensors
* Peripherals
* Host PCs

A UART frame typically contains:

* Start bit
* 8 data bits (LSB first)
* Optional parity
* Stop bit(s)

Because UART communication is asynchronous, both devices must agree on baud rate. To improve reliability, this design uses **16× oversampling** in the receiver, allowing sampling at the center of each bit period for improved robustness.

### Key Features

* **TX Module**

  * Serializes 8-bit data
  * Start + stop bit generation
  * Driven by 1× baud clock

* **RX Module**

  * 16× oversampling receiver
  * Mid-bit sampling
  * Reliable start detection

* **Baud Generator**

  * Selectable baud rates:

    * 9600
    * 19200
    * 38400
    * 57600
    * 115200
  * Generates both TX and RX clocks

---

##  UART Block Diagram

![alt text](<Screenshot (206).png>)

Main modules:

* Baud Generator
* RX Module
* TX Module

The baud generator provides:

* `baud_clk` (1× clock for TX)
* `baud_x16_clk` (16× clock for RX)

---

##  Module Description

### 1️⃣ TX Module

The transmitter converts parallel data into a UART frame.

**Responsibilities:**

* Sends start bit (logic 0)
* Transmits 8-bit data (LSB first)
* Sends stop bit (logic 1)
* Operates on 1× baud clock
* Provides `busy` status signal

A simple FSM controls the transmission process.

---

### 2️⃣ RX Module (16× Oversampling)

The receiver reconstructs data using oversampling.

**Functionality:**

* Detects falling edge (start bit)
* Waits half-bit time to reach center
* Samples at the 8th tick out of 16
* Validates stop bit
* Outputs:

  * `rx_data[7:0]`
  * `rx_done`
  * `busy`

**Why 16× oversampling?**

* Better tolerance to baud mismatch
* Improved noise immunity
* Accurate mid-bit sampling

---

### 3️⃣ Baud Rate Generator

Generates timing signals for TX and RX.

**Features:**

* Dual clocks:

  * TX baud clock (1×)
  * RX oversampling clock (16×)
* 3-bit baud selector (`baud_sel`)
* Parameterizable system clock
* Counter/divider-based implementation

This makes the UART reusable across FPGA platforms.

---

##  Simulation & Verification

Simulation was performed using **Vivado**.

### Loopback Test

* TX output connected directly to RX input.
* Verified correct reconstruction of transmitted data.

### Tested Cases

* TX transmitting **0xA5 @ 115200 baud**
* TX transmitting **0x3A @ 9600 baud**
* TX transmitting **0x3A @ 19200 baud**

Waveforms confirmed:

* Correct start/stop detection
* Mid-bit sampling accuracy
* Proper `rx_done` behavior
* Matching TX and RX data

---

##  Project Structure

```
rtl/
   uart_top.v
   tx.v
   rx.v
   baud_gen.v

tb/
   uart_loopback_tb.v

docs/
   block diagrams
   simulation waveforms
```

---
