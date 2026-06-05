# Context State & Anti-Hallucination Tracker

This file serves as my persistent memory bank across long conversations to ensure I do not lose context or hallucinate past decisions.

## Project Goal
We are rewriting the Microarchitecture Specification (MAS) for a 282-module, 90nm SoC. The original `project.md` was flawed (missing clocks, resets, explicit handshakes). We are correcting this block by block in `arch.md`.

## The 4 Master Execution Phases
To ensure bug-free, enterprise-grade Verilog, the entire project is strictly gated into 4 consecutive phases. **We are currently in PHASE 1.**

*   **PHASE 1: Microarchitecture Specification (MAS) Creation [CURRENT PHASE]**
    *   **Action:** Architect the `arch.md` file block by block.
    *   **Details required:** Define FSMs, Pipeline stages, Clock Domain Crossing (CDC), Stall/Hazard conditions, and build the pin-exact Signal Interface Matrix (injecting missing `clk`/`rst_n` and `valid`/`ready`).
    *   **Rule:** Absolutely ZERO Verilog coding is permitted in this phase.
*   **PHASE 2: User Review & Port Freezing**
    *   **Action:** The Lead Architect (User) reviews the `arch.md` for a block. If approved, the Signal Interface Matrix is permanently locked.
    *   **Action:** Generate the empty Verilog "Stub" files featuring ONLY the frozen ports.
*   **PHASE 3: Manual RTL Implementation**
    *   **Action:** Write the internal logic (`always_ff`, `always_comb`, State Machines) inside the frozen Verilog stubs.
    *   **Rule:** The logic must perfectly match the timing and FSMs defined in Phase 1.
*   **PHASE 4: Subsystem Integration & Validation**
    *   **Action:** Wire the completed modules together into their top-level wrappers (e.g., `rv64_core_top.sv`). Verify that the AXI streams and Valid/Ready handshakes align without deadlocking.

## Current Status
- **Section 1 (Global Arch & Inter-Core Comm):** COMPLETED. Defines 2D-Mesh NoC, 256-bit AXI4-Full for data plane, 32-bit AXI4-Lite for CSR, MESI Coherency, Credit-based flow control.
- **Section 2 (Foundational Primitives & RV64 Front-End, Modules 1-54):** COMPLETED. Defined 4-stage pipelines, Tournament predictor FSMs, and fully frozen port matrix with injected `clk` and `rst_n`.
- **Section 2.5 (RV64 Back-End, Modules 55-79):** COMPLETED. Defined ROB/ALU communication, Commit FSMs, memory disambiguation, and frozen port matrix.
- **Section 3 (RVV Vector Subsystem, Modules 80-99):** COMPLETED. Defined 512-bit width constraints, 128-bit lane slices, 3-cycle MAC latency, Gather/Scatter FSM, and frozen port matrix.
- **Section 4 (FPU Subsystem, Modules 100-116):** COMPLETED. Defined IEEE-754 multi-cycle SRT radix-4 dividers, exception flag routing, and frozen port matrix.
- **Section 5 (Advanced Memory Hierarchy, Modules 117-146):** COMPLETED. Defined 256-bit NoC backbone matching, 1-cycle L1 / 4-cycle L2 hit latency, MESI Coherency FSM for Snoop Invalidates, and frozen port matrix.
- **Section 6 (NPU Subsystem, Modules 147-186):** COMPLETED. Defined 128x128 Systolic Array datapath, strict PSUM backpressure stall mechanism, Sparsity Zero-skipping FSM, and exact AXI4-Full pins.
- **Section 7 (GPU Subsystem, Modules 187-228):** COMPLETED. Defined 32-wide SIMD execution, 4-pixel/cycle rasterization, TMU 2-cycle hit latency, Z-cull FSMs, and strict valid/ready handshakes.
- **Section 8 (Video Codec, Modules 229-245):** COMPLETED. Defined 4K@60fps pipeline, DMA streaming FSM, CABAC FSM, and standard AXI4-Full matrix.
- **Block 9 (NoC & Global Peripherals, Modules 246-270):** COMPLETED. Defined 2D-Mesh X-Y routing, 4-VC allocator FSMs, 3-cycle flit latency, and AXI-to-APB 32-bit bridges.
- **Block 10 (External Interfaces & SoC Top-Level, Modules 271-282):** COMPLETED. Defined DDR4 JEDEC FSMs, PCIe Gen4 TLPs, Iterative Conductor Reset/Power sequencing, and physical top-level PADs.

**STATUS: PHASE 1 (MAS Creation) IS 100% COMPLETE.**

## Global Rules Enforced
1. **NO PYTHON SCRIPTS** for document generation. All documentation must be written directly by me via standard file-write tools.
2. All sequential modules MUST have `clk` and `rst_n`.
3. All streaming modules MUST have strict `valid`/`ready` handshakes.
4. No Verilog coding begins until `arch.md` is 100% locked.
