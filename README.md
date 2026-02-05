# Elastic Pipeline Register with Ready/Valid Handshake

This repository contains a synthesizable single-stage pipeline register implemented in SystemVerilog using a standard ready/valid handshake protocol. The design behaves as a one-entry elastic buffer that safely handles backpressure while maintaining correct data flow and maximum throughput.

---

## Overview

The pipeline register sits between an upstream producer and a downstream consumer. It accepts data only when `in_valid` and `in_ready` are asserted, stores data when the downstream is stalled, and forwards data when the downstream is ready. Simultaneous accept and forward in the same cycle is supported.

This block is a fundamental building unit for elastic pipelines used in CPUs, interconnects, and streaming interfaces such as AXI-Stream.

---

## Handshake Protocol

The design uses a **ready/valid handshake**:

- `valid` is driven by the sender  
- `ready` is driven by the receiver  
- A transfer occurs when `valid && ready` are high in the same cycle  
- `valid` remains asserted until data is accepted  
- `ready` may toggle freely  

This protocol guarantees no data loss, duplication, or corruption under backpressure.

---

## Repository Contents

- **pipeline_reg.sv**  
  RTL implementation of the single-stage elastic pipeline register.

- **tb_pipeline_reg.sv**  
  Self-checking testbench that verifies:
  - Reset behavior  
  - Pass-through operation  
  - Backpressure handling  
  - Simultaneous input/output transfers  

- **Simulation Waveforms**  
  Captured waveforms demonstrating correct handshake behavior, data stability during stalls, and bubble-free operation.

- **Synthesis Results**  
  Synthesis reports confirming the design is fully synthesizable and showing minimal resource usage.

---

## Key Features

- Single-entry pipeline register  
- Elastic (stall-tolerant) behavior  
- Supports simultaneous push and pop  
- No data loss or duplication  
- Clean reset to an empty state  
- Fully synthesizable, no latches or combinational loops  

---

## Typical Use Cases

- Pipeline stage registers (IF/ID, ID/EX, EX/MEM, etc.)
- AXI-Stream–style data paths
- Skid buffers and flow-controlled datapaths
- RISC-V and general CPU microarchitecture
- NoC and streaming accelerators

---

## Simulation

The testbench independently drives `valid` and `ready` to stress the design under realistic conditions. Included simulation waveforms show correct behavior across pass-through, stall, and replace scenarios.

---

## Synthesis

The design synthesizes to minimal hardware:
- One data register  
- One control bit  
- Simple combinational handshake logic  

No vendor-specific primitives are used.

---

## Notes

This module is intended as a reusable building block. It can be extended into multi-stage pipelines, FIFOs, or skid buffers while preserving the same ready/valid semantics.

---
