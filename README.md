# Synchronous FIFO Design & Verification

## Overview
This repository contains a fully synthesizable, parameterized **Synchronous FIFO (First-In-First-Out)** memory buffer designed in **SystemVerilog**. The project includes a robust, self-checking testbench that verifies the design against a dynamic queue-based reference model (Golden Model).


## Key Features
* **Synthesizable Hardware:** Designed using standard digital logic practices (D-Flip-Flops, inference-compatible memory arrays).
* **Parameterized:** Configurable `WIDTH` (Data Bus) and `DEPTH` (Buffer Size).
* **Efficient Pointer Logic:** Implements **(N+1)-bit pointers** to handle full/empty conditions and wrap-around logic without extra flag registers.
* **Conflict-Free Access:** Supports simultaneous Read and Write operations without data corruption.

## Verification Strategy
The testbench (`tb_sync_fifo.sv`) uses a **SystemVerilog Queue (`[$]`)** as a golden reference model, which Compares the DUT (Device Under Test) output against the queue's expected data.

### Test Coverage
The verification suite covers the following scenarios:
* **Basic Functionality:** Simple data pipe behavior.
* **Overflow/Underflow:** Verifies `full` and `empty` flag protection logic.
* **Pointer Wrap-Around:** Ensures memory addressing correctly rolls over from address `DEPTH-1` to `0`.
* **Simultaneous R/W:** Stress-tests the dual-port behavior of the memory array.
* **Reset Recovery:** Validates asynchronous reset behavior and pointer initialization.

## Run this Project
You can simulate this design immediately in your browser (no installation required) using EDA Playground:
**Click Here to Run Simulation Live: https://www.edaplayground.com/x/WRyr**

## Author
Shai Brener - 2025
