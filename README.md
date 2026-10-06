# APB Peripheral RTL Design

A simple APB-based peripheral designed and verified using SystemVerilog.

## Overview

This project implements a basic memory-mapped APB peripheral with support for register-based read and write transactions.

The design includes an APB protocol FSM, memory-mapped registers, address decoding, read/write handling, and a SystemVerilog testbench for functional verification.

## Features

- APB transaction handling
- APB FSM with `IDLE`, `SETUP`, and `ACCESS` states
- Memory-mapped register interface
- Register address decoding
- Read and write transaction support
- `PREADY` response generation
- SystemVerilog testbench
- Simulation waveform analysis

## Register Map

| Address | Register | Access | Description |
|--------:|----------|:------:|-------------|
| `0x00` | CONTROL | R/W | Control register |
| `0x04` | DATA | R/W | Data register |
| `0x08` | STATUS | R | Status register |

## Write Transaction
PWRITE  = 1
PSEL    = 1
PENABLE = 1

The address and write data are decoded and stored in the corresponding register.

## Read Transaction
PWRITE  = 0
PSEL    = 1
PENABLE = 1

The peripheral returns the selected register value through PRDATA.

## Project Structure
APB-Peripheral/
│
├── rtl/
│   └── apb_peripheral.sv
│
├── tb/
│   └── tb_APB.sv
│
├── waveform/
│   └── apb_waveform.png
│
└── README.md
## Verification

The SystemVerilog testbench verifies:

Write to CONTROL register
Read from CONTROL register
Write to DATA register
Read from DATA register
Read from STATUS register
Invalid address access
APB PREADY response
APB FSM transaction flow

Simulation and waveform analysis were performed using EDA Playground.

## Waveform
## Tools
SystemVerilog
EDA Playground
Icarus Verilog
GTKWave
Visual Studio Code

## Skills Demonstrated
RTL Design
SystemVerilog
Finite State Machine (FSM)
APB Protocol
Memory-Mapped Registers
Address Decoding
Testbench Development
Functional Verification
Simulation and Waveform Analysis

## Future Improvements
More detailed STATUS register behavior
APB error response handling
Additional register functionality
SystemVerilog Assertions (SVA)
UVM-based verification

## APB Transaction Flow

```text
IDLE
  │
  │ PSEL = 1
  ▼
SETUP
  │
  │ PENABLE = 1
  ▼
ACCESS
  │
  │ PREADY = 1
  ▼
IDLE
