# Microarchitecture Specification (MAS)
## The Definitive Blueprint for the 90nm SoC

> **WARNING: STRICT ENFORCEMENT**
> This document is the Single Source of Truth. If it is not in this document, it does not get written into RTL. The RTL team (Antigravity) will follow this exact architecture down to the individual clock cycle.

---

## Section 1: Global System Architecture & Inter-Core Communication

This section defines the strict, binding global communication fabric of the 90nm SoC. Every sub-block must interface with this fabric exactly as specified below to prevent deadlocks and data corruption.

### 1.1 Global Interconnect Topology (NoC vs AXI)

The SoC employs a **heterogeneous 2D-Mesh Network-on-Chip (NoC)** for scalable, high-bandwidth communication between the major compute islands, complemented by dedicated **AXI4-Full** and **AXI4-Lite** hierarchies for localized traffic.

*   **Compute Islands:** The RV64 Quad-Core Cluster, NPU Subsystem, GPU Subsystem, and the Memory Controller (DDR4) act as independent nodes on the NoC.
*   **The NoC Backbone:** A 4x4 2D-Mesh routing topology. Each compute node connects to the mesh via a `noc_network_interface` which translates AXI4 burst transactions into NoC flits (Flow Control Units).
*   **Routing Algorithm:** Dimension-Order Routing (X-Y routing) to guarantee deadlock freedom. Packets travel along the X-axis first, then the Y-axis.

### 1.2 Data Plane: AXI4-Full Burst Traffic

All high-bandwidth memory traffic (e.g., NPU weight fetching, GPU texture loading, Vector Core 512-bit loads) must use the **AXI4-Full Protocol**.
*   **Data Width:** The AXI4-Full bus is uniformly **256-bit wide** at the NoC interfaces. For blocks like the Vector Core that require 512-bit, an internal 512-bit to 256-bit asymmetric gear-box handles the downsizing.
*   **Burst Support:** `INCR` bursts are heavily utilized. `AWLEN` and `ARLEN` support up to 256 beats per transaction.
*   **Out-of-Order Execution:** Modules must use `AWID`/`ARID` (4-bit to 8-bit depending on the master) to tag transactions. The NoC may return read data out of order; the initiator's AXI Burst Controller must contain a Reorder Buffer (ROB) to reconstruct the data.

### 1.3 Control Plane: AXI4-Lite CSR Hierarchy

For programming Configuration and Status Registers (CSRs), the SoC uses a totally separate, low-latency, non-blocking **AXI4-Lite Control Plane**.
*   **Data Width:** Strictly 32-bit Address, 32-bit Data.
*   **Topology:** A tree-structured `axi4_lite_interconnect` connects the RV64 Core (Master) to all peripheral slaves (UART, SPI, Timers, NPU Control Registers, GPU Command Registers).
*   **Rule:** AXI4-Lite slaves MUST NOT assert `awready` or `arready` LOW for more than 16 consecutive clock cycles to prevent the CPU from hanging.

### 1.4 Credit-Based Flow Control Mechanism

To prevent buffer overflows and completely eliminate the need for global combinatorial stall signals, the NoC and major AXI bridges use **Credit-Based Flow Control**.
*   **Initialization:** Upon `rst_n` deassertion, the Receiver broadcasts its total buffer depth as "Initial Credits" (e.g., 32 credits) to the Sender.
*   **Consumption:** Every time the Sender transmits a valid flit/beat, it decrements its local Credit Counter by 1. If Credits == 0, the Sender MUST NOT assert `valid`.
*   **Replenishment:** When the Receiver pops a flit from its internal FIFO (freeing up a slot), it asserts a `credit_return` pulse back to the Sender. The Sender increments its Credit Counter.
*   **Deadlock Prevention:** The `credit_return` signal must be registered and travel on a dedicated, non-blockable sideband channel.

### 1.5 Global Memory Map

The entire SoC shares a unified 64-bit physical address space, decoded statically by the NoC Routers and AXI interconnects.

| Address Range (Hex) | Size | Target Block / Region | Properties |
| :--- | :--- | :--- | :--- |
| `0x0000_0000 - 0x0000_FFFF` | 64 KB | Boot ROM | Read-Only, Cacheable |
| `0x0100_0000 - 0x01FF_FFFF` | 16 MB | APB Peripherals (UART, I2C, Timers) | Non-Cacheable, AXI4-Lite |
| `0x0200_0000 - 0x0200_FFFF` | 64 KB | PLIC (Interrupt Controller) | Non-Cacheable, AXI4-Lite |
| `0x1000_0000 - 0x10FF_FFFF` | 16 MB | NPU / GPU CSR & Command Queues | Non-Cacheable, AXI4-Lite |
| `0x4000_0000 - 0x4FFF_FFFF` | 256 MB | PCIe Gen4 Memory Mapped I/O | Non-Cacheable, AXI4-Full |
| `0x8000_0000 - 0xFFFF_FFFF` | 2 GB+ | Main DDR4 System Memory | Cacheable, AXI4-Full (Burst) |

*Transactions to unmapped regions instantly trigger a hardware `DECERR` (Decode Error) response on the AXI bus.*

### 1.6 Hardware Cache Coherency Protocol (MESI)

The SoC implements a directory-based **MESI (Modified, Exclusive, Shared, Invalid)** coherency protocol, governed by the `mesi_coherency_directory`.
*   **Snooping Mechanism:** The RV64 Quad-Core cluster has a unified L2 Cache. When the GPU or NPU writes to a memory address in the `0x8000_0000+` range, their NoC Network Interface sends a "Snoop Invalidate" request to the Coherency Directory.
*   **L2 Interrogation:** The Directory checks its Snoop Filter. If the address is present in the RV64 L2 Cache, the Directory asserts a snoop request to the L2 Cache Controller.
*   **Action:** If the L2 Cache holds the line in 'Modified' state, it flushes the dirty line back to DDR4 (or forwards it directly to the GPU) before allowing the GPU's write to complete. If 'Shared', the L2 line is simply marked 'Invalid'.
*   **Stall Constraint:** The GPU AXI Master will be held in `awvalid` HIGH, `awready` LOW wait-state until the Coherency Directory acknowledges the snoop resolution.

### 1.7 Global Interrupt Routing (PLIC)

The **Platform-Level Interrupt Controller (PLIC)** acts as the central nervous system for exceptions.
*   **Sources:** 128 hardwired interrupt lines connect to the PLIC.
    *   `irq[0:31]`: Standard APB Peripherals (UART, SPI, GPIO).
    *   `irq[32:47]`: PCIe MSI/MSI-X interrupts.
    *   `irq[48:63]`: GPU/NPU completion or error flags.
    *   `irq[64:127]`: Inter-Processor Interrupts (IPIs) and reserved.
*   **Routing:** The PLIC aggregates these, prioritizes them based on memory-mapped priority registers, and routes an `ext_interrupt` signal to one of the 4 RV64 Cores (Hart 0 to 3) in either Machine (M-Mode) or Supervisor (S-Mode) privilege levels.

---

## Part 2: Detailed Microarchitecture (Block by Block)

*(This section will be built out iteratively. We will start with Block 1, define it completely, freeze it, and then move to the next.)*


## Section 2: Foundational Primitives & RV64 Front-End (Block 1 & 2)

This section dictates the precise microarchitecture for the fundamental building blocks and the RV64 Quad-Core CPU Front-End (Modules 1 through 54).

### 2.1 Block 1: Foundational Primitives & CDC (Modules 1-32)

Block 1 contains the heavily optimized low-level structural components. These must be instantiated exactly as specified to ensure timing closure at 90nm.

*   **Synchronizer CDC Protocols:**
    *   `level_synchronizer`: Uses a standard 2-flop synchronizer. MTBF must be calculated assuming a 3GHz core clock crossing into a 400MHz bus clock.
    *   `pulse_synchronizer`: Implements a toggle-flop on the fast domain, synchronized via 2-flops on the slow domain, followed by an XOR edge detector.
    *   `async_fifo`: Uses dual-port SRAM with Gray-coded read/write pointers crossing domains via 2-flop synchronizers.
*   **FIFO Full/Empty Conditions:**
    *   `full` logic: `assign full = (wr_ptr_gray == {~rd_ptr_sync[N:N-1], rd_ptr_sync[N-2:0]});`
    *   `empty` logic: `assign empty = (rd_ptr_gray == wr_ptr_sync);`
*   **Math Primitives (Pipeline & Latency):**
    *   `fp64_fused_mac`: Deeply pipelined. Minimum 4-stage pipeline (Align -> Multiply -> Add -> Normalize). Data `valid` and `ready` handshakes must propagate through all 4 pipeline stages.

### 2.2 Block 2: RV64 Core Front-End Pipeline (Modules 33-54)

The RV64GC Core Front-End is responsible for fetching, predicting, decoding, and dispatching instructions to the Out-of-Order execution backend. 

#### Pipeline Stages & Latency
1.  **Stage 1: Fetch (`fetch_buffer`, `pc_gen_unit`)**
    *   Issues 256-bit wide instruction fetch requests to the L1 I-Cache.
    *   **Stall Condition:** If the L1 I-Cache misses, `fetch_valid` goes LOW. The `pc_gen_unit` must hold its current PC until `icache_ready` asserts.
2.  **Stage 2: Pre-Decode & Predict (`branch_target_buffer`, `tournament_predictor`)**
    *   **FSM Logic:** The Tournament Predictor uses a 2-bit saturating counter. States: `STRONGLY_NOT_TAKEN (00) -> WEAKLY_NOT_TAKEN (01) -> WEAKLY_TAKEN (10) -> STRONGLY_TAKEN (11)`.
    *   If a branch is predicted taken, a `flush_fetch` signal is immediately asserted upstream to wipe Stage 1.
3.  **Stage 3: Decode (`instr_decoder`, `compressed_decoder_rvc`)**
    *   Expands 16-bit RVC instructions into 32-bit.
    *   Translates RISC-V instructions into uniform 64-bit Micro-Ops (`uop_out`).
4.  **Stage 4: Rename (`register_rename_unit`, `freelist_manager`)**
    *   Maps the 32 Architectural Registers (ARF) to 128 Physical Registers (PRF).
    *   **Stall Condition:** If the `freelist_manager` asserts `empty` (no free physical registers), the Rename stage asserts `stall_decode` upstream.
5.  **Stage 5: Dispatch (`dispatch_unit_4way`, `issue_queue_manager`)**
    *   Allocates the Micro-Op into the Reorder Buffer (ROB) and the appropriate Reservation Station (ALU, MEM, BRANCH).
    *   **Hazard Handling:** If any Reservation Station is full, `dispatch_ready` goes LOW, halting the entire Front-End pipeline.

### 2.3 Clock Domain Crossing & Handshake Rules

All streaming interfaces between the Front-End modules strictly follow the valid/ready protocol:
*   **Rule 1:** `valid` MUST NOT depend on `ready` (to prevent combinatorial deadlock loops).
*   **Rule 2:** Once `valid` is asserted, the `data` bus MUST NOT change until `ready` is sampled HIGH on the rising edge of `clk`.


## 2.4 Frozen Signal Interface Matrix (Modules 1-54)

This matrix serves as the strictly frozen port definition for Block 1 and the RV64 Front-End. All sequential modules have been forcefully injected with `clk` and `rst_n`.

### sv_standard_cell_ram.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `clk` | input | 1 | Clock |
| `we` | input | 1 | Write Enable (Active High) |
| `addr` | input | `$clog2(DEPTH)` | Memory Address |
| `wdata` | input | `DATA_WIDTH` | Write Data |
| `rdata` | output | `DATA_WIDTH` | Read Data |

### sv_standard_cell_rom.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `clk` | input | 1 | Clock |
| `re` | input | 1 | Read Enable (Active High) |
| `addr` | input | `$clog2(DEPTH)` | ROM Address |
| `rdata` | output | `DATA_WIDTH` | Read Data |

### sync_fifo.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Synchronous reset (Active Low) |
| `push` | input | 1 | Push/Write Enable |
| `pop` | input | 1 | Pop/Read Enable |
| `data_in` | input | `DATA_WIDTH` | Data to be written |
| `data_out` | output | `DATA_WIDTH` | Data to be read |
| `full` | output | 1 | FIFO is full flag |
| `empty` | output | 1 | FIFO is empty flag |

### async_fifo.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `wclk` | input | 1 | Write Clock |
| `wrst_n` | input | 1 | Write Domain Reset (Active Low) |
| `wpush` | input | 1 | Write Enable |
| `wdata` | input | `DATA_WIDTH` | Write Data |
| `wfull` | output | 1 | Write Full Flag |
| `rclk` | input | 1 | Read Clock |
| `rrst_n` | input | 1 | Read Domain Reset (Active Low) |
| `rpop` | input | 1 | Read Enable |
| `rdata` | output | `DATA_WIDTH` | Read Data |
| `rempty` | output | 1 | Read Empty Flag |

### skid_buffer.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset (Active Low) |
| `s_valid` | input | 1 | Slave valid |
| `s_ready` | output | 1 | Slave ready |
| `s_data` | input | `DATA_WIDTH` | Slave data |
| `m_valid` | output | 1 | Master valid |
| `m_ready` | input | 1 | Master ready |
| `m_data` | output | `DATA_WIDTH` | Master data |

### level_synchronizer.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk_dest` | input | 1 | Destination Clock |
| `rst_dest_n` | input | 1 | Destination Reset (Active Low) |
| `sig_in` | input | 1 | Asynchronous input signal |
| `sig_out` | output | 1 | Synchronized output signal |

### pulse_synchronizer.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk_src` | input | 1 | Source Clock |
| `rst_src_n` | input | 1 | Source Reset (Active Low) |
| `pulse_in` | input | 1 | Source domain pulse |
| `clk_dest` | input | 1 | Destination Clock |
| `rst_dest_n` | input | 1 | Destination Reset (Active Low) |
| `pulse_out` | output | 1 | Destination domain pulse |

### handshake_synchronizer.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk_src` | input | 1 | Source Clock |
| `rst_src_n` | input | 1 | Source Reset |
| `req_in` | input | 1 | Request from source |
| `ack_out` | output | 1 | Acknowledge back to source |
| `data_in` | input | `DATA_WIDTH` | Data from source |
| `clk_dest` | input | 1 | Destination Clock |
| `rst_dest_n` | input | 1 | Destination Reset |
| `req_out` | output | 1 | Request to destination |
| `ack_in` | input | 1 | Acknowledge from destination |
| `data_out` | output | `DATA_WIDTH` | Data to destination |

### gray_to_binary.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `gray_in` | input | `WIDTH` | Gray code input |
| `bin_out` | output | `WIDTH` | Binary output |

### binary_to_gray.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `bin_in` | input | `WIDTH` | Binary input |
| `gray_out` | output | `WIDTH` | Gray code output |

### clock_gating_cell.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `clk_in` | input | 1 | Input Clock |
| `en` | input | 1 | Enable signal |
| `test_en` | input | 1 | Test Enable (DFT) |
| `clk_out` | output | 1 | Gated Clock |

### mux_tree_32b.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `data_in` | input | `32 * DATA_WIDTH` | Flat input data array |
| `sel` | input | 5 | Select line |
| `data_out` | output | `DATA_WIDTH` | Selected data |

### mux_tree_64b.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `data_in` | input | `64 * DATA_WIDTH` | Flat input data array |
| `sel` | input | 6 | Select line |
| `data_out` | output | `DATA_WIDTH` | Selected data |

### priority_encoder_32.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `req` | input | 32 | Request vector |
| `valid` | output | 1 | Any request valid |
| `grant` | output | 5 | Index of highest priority request |

### priority_encoder_64.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `req` | input | 64 | Request vector |
| `valid` | output | 1 | Any request valid |
| `grant` | output | 6 | Index of highest priority request |

### decoder_5to32.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `en` | input | 1 | Enable |
| `sel` | input | 5 | Input select |
| `dec_out` | output | 32 | Decoded one-hot output |

### decoder_6to64.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `en` | input | 1 | Enable |
| `sel` | input | 6 | Input select |
| `dec_out` | output | 64 | Decoded one-hot output |

### carry_lookahead_adder_32.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 32 | Operand A |
| `b` | input | 32 | Operand B |
| `c_in` | input | 1 | Carry in |
| `sum` | output | 32 | Sum result |
| `c_out` | output | 1 | Carry out |

### carry_lookahead_adder_64.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 64 | Operand A |
| `b` | input | 64 | Operand B |
| `c_in` | input | 1 | Carry in |
| `sum` | output | 64 | Sum result |
| `c_out` | output | 1 | Carry out |

### wallace_tree_mult_32.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 32 | Multiplicand |
| `b` | input | 32 | Multiplier |
| `prod` | output | 64 | Product |

### wallace_tree_mult_64.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 64 | Multiplicand |
| `b` | input | 64 | Multiplier |
| `prod` | output | 128 | Product |

### radix4_booth_encoder.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `mult` | input | 3 | 3-bit multiplier window |
| `neg` | output | 1 | Negative flag |
| `zero` | output | 1 | Zero flag |
| `two` | output | 1 | Multiply by 2 flag |
| `one` | output | 1 | Multiply by 1 flag |

### barrel_shifter_64.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `data_in` | input | 64 | Data to shift |
| `shift_amt` | input | 6 | Shift amount |
| `arith` | input | 1 | Arithmetic shift flag |
| `data_out` | output | 64 | Shifted data |

### int4_multiplier.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 4 | Operand A |
| `b` | input | 4 | Operand B |
| `prod` | output | 8 | Product |

### int8_multiplier.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 8 | Operand A |
| `b` | input | 8 | Operand B |
| `prod` | output | 16 | Product |

### bf16_multiplier.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 16 | Bfloat16 Operand A |
| `b` | input | 16 | Bfloat16 Operand B |
| `prod` | output | 16 | Bfloat16 Product |

### bf16_adder.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `a` | input | 16 | Bfloat16 Operand A |
| `b` | input | 16 | Bfloat16 Operand B |
| `sum` | output | 16 | Bfloat16 Sum |

### fp32_fused_mac.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `a` | input | 32 | FP32 Operand A |
| `b` | input | 32 | FP32 Operand B |
| `c` | input | 32 | FP32 Addend C |
| `out` | output | 32 | FP32 MAC Result |

### fp64_fused_mac.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `a` | input | 64 | FP64 Operand A |
| `b` | input | 64 | FP64 Operand B |
| `c` | input | 64 | FP64 Addend C |
| `out` | output | 64 | FP64 MAC Result |

### prng_lfsr.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `seed` | input | 32 | LFSR Seed |
| `load` | input | 1 | Load seed enable |
| `en` | input | 1 | Enable generator |
| `rand_out` | output | 32 | Pseudo-random output |

### pll_clock_generator.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk_ref` | input | 1 | Reference Clock |
| `rst_n` | input | 1 | Reset |
| `mult` | input | 8 | PLL Multiplier |
| `div` | input | 8 | PLL Divider |
| `clk_out` | output | 1 | Generated Clock |
| `locked` | output | 1 | PLL Locked Flag |

### dll_phase_shifter.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk_in` | input | 1 | Input Clock |
| `rst_n` | input | 1 | Reset |
| `phase_sel` | input | 4 | Phase Shift Select |
| `clk_out` | output | 1 | Phase-shifted Clock |
| `locked` | output | 1 | DLL Locked Flag |

### rv64_quad_core_cluster.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset (Active Low) |
| `axi_m_if` | interface | AXI4 | AXI4 Master Interface to NoC/L3 |
| `ext_int` | input | 4 | External Interrupts (1 per core) |

### rv64_core_top.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Core Clock |
| `rst_n` | input | 1 | Core Reset |
| `core_id` | input | 2 | Core Identification (0-3) |
| `icache_if` | inout | INTF | L1 Instruction Cache Interface |
| `dcache_if` | inout | INTF | L1 Data Cache Interface |
| `irq` | input | 1 | Interrupt Request |

### pc_gen_unit.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `stall` | input | 1 | Pipeline Stall |
| `redirect` | input | 1 | Branch Redirect Enable |
| `target_pc` | input | 64 | Redirect Target PC |
| `next_pc` | output | 64 | Next Program Counter |

### fetch_buffer.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `push` | input | 1 | Push Enable (from I-Cache) |
| `pop_cnt` | input | 2 | Pop Count (0 to 2 instructions) |
| `instr_in` | input | 256 | 256-bit Fetch Block |
| `instr_out` | output | 64 | Up to 2 Instructions |
| `empty` | output | 1 | Buffer Empty |

### instr_prefetcher.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `pc_in` | input | 64 | Current PC |
| `prefetch_req` | output | 1 | Request I-Cache Prefetch |
| `prefetch_addr` | output | 64 | Address to Prefetch |

### branch_target_buffer.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `pc` | input | 64 | Current Fetch PC |
| `btb_hit` | output | 1 | BTB Hit |
| `btb_target` | output | 64 | Predicted Target PC |
| `update_en` | input | 1 | Update Enable |
| `update_pc` | input | 64 | Update PC |

### branch_history_table.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `pc` | input | 64 | Instruction PC |
| `predict_taken` | output | 1 | Branch Prediction |
| `update_en` | input | 1 | Update Enable |
| `actual_taken` | input | 1 | Actual Branch Outcome |

### tournament_predictor.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `pred_a` | input | 1 | Prediction from local BHT |
| `pred_b` | input | 1 | Prediction from global BHT |
| `final_pred` | output | 1 | Selected Prediction |
| `update_en` | input | 1 | Update Enable |

### return_address_stack.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `push` | input | 1 | Push on CALL |
| `pop` | input | 1 | Pop on RET |
| `ret_addr_in` | input | 64 | Return Address |
| `ret_addr_out` | output | 64 | Predicted Return Address |

### pre_decode_unit.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `clk` | input | 1 | Clock |
| `instr_in` | input | 64 | Raw Instruction |
| `is_branch` | output | 1 | Branch identifier |
| `is_compressed` | output | 1 | RVC identifier |
| `instr_len` | output | 2 | Instruction length in bytes |

### instr_decoder.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `instr` | input | 32 | 32-bit Instruction |
| `opcode` | output | 7 | Opcode |
| `rs1, rs2, rd` | output | 5 | Register indices |
| `imm` | output | 64 | Sign-extended immediate |
| `alu_op` | output | 4 | ALU Operation |

### compressed_decoder_rvc.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `instr_rvc` | input | 16 | 16-bit Compressed Instr |
| `instr_rv32` | output | 32 | Expanded 32-bit Instr |
| `illegal_instr` | output | 1 | Illegal Instruction Flag |

### micro_op_sequencer.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `complex_instr` | input | 32 | Complex Instruction |
| `uop_out` | output | 64 | Micro-op output |
| `uop_valid` | output | 1 | Micro-op valid |

### register_alias_table.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `arch_reg` | input | 5 | Architectural Register (0-31) |
| `phys_reg` | output | 7 | Physical Register (0-127) |
| `update_en` | input | 1 | Update Map |
| `recover_en` | input | 1 | Rollback Map |

### freelist_manager.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Clock |
| `rst_n` | input | 1 | Reset |
| `pop` | input | 1 | Allocate register |
| `phys_reg_out` | output | 7 | Allocated Physical Register |
| `push` | input | 1 | Free register |
| `phys_reg_in` | input | 7 | Freed Physical Register |

### register_rename_unit.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `clk` | input | 1 | Clock |
| `rs1, rs2, rd` | input | 5 | Arch Registers |
| `prs1, prs2, prd` | output | 7 | Physical Registers |
| `stall` | output | 1 | Stall if freelist empty |

### dispatch_unit_4way.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `clk` | input | 1 | Clock |
| `uop_in` | input | `4 * UOP_WIDTH` | 4 incoming micro-ops |
| `alu_rs_out` | output | `UOP_WIDTH` | To ALU Reservation Station |
| `mem_rs_out` | output | `UOP_WIDTH` | To MEM Reservation Station |
| `rob_alloc` | output | 4 | To ROB |

### issue_queue_manager.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `clk` | input | 1 | Clock |
| `wakeup_bus` | input | `4 * 7` | Broadcast tags |
| `issue_req` | output | 4 | Issue up to 4 instructions |
| `issue_grant` | input | 4 | Issue grants |

### reservation_station_alu_0.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `clk` | input | 1 | Clock |
| `alloc_en` | input | 1 | Allocate Entry |
| `uop_in` | input | `UOP_WIDTH` | Micro-op data |
| `wakeup_tags` | input | `4 * 7` | Tags of completing instructions |
| `issue_out` | output | `UOP_WIDTH` | Ready micro-op to ALU 0 |

### reservation_station_alu_1.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `clk` | input | 1 | Clock |
| `alloc_en` | input | 1 | Allocate Entry |
| `uop_in` | input | `UOP_WIDTH` | Micro-op data |
| `wakeup_tags` | input | `4 * 7` | Tags of completing instructions |
| `issue_out` | output | `UOP_WIDTH` | Ready micro-op to ALU 1 |

### reservation_station_mem.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `clk` | input | 1 | Clock |
| `alloc_en` | input | 1 | Allocate Entry |
| `uop_in` | input | `UOP_WIDTH` | Load/Store micro-op |
| `issue_out` | output | `UOP_WIDTH` | Ready micro-op to AGU |

### reservation_station_branch.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `clk` | input | 1 | Clock |
| `alloc_en` | input | 1 | Allocate Entry |
| `uop_in` | input | `UOP_WIDTH` | Branch micro-op |
| `issue_out` | output | `UOP_WIDTH` | Ready micro-op to Branch Unit |



### 2.5 RV64 Back-End & Memory Execution (Modules 55-79)

This section maps out the Out-of-Order (OoO) execution back-end, the Reorder Buffer (ROB) commit logic, and the Load/Store memory disambiguation flow.

#### Communication Protocol: ROB, Reservation Stations, and ALUs
1.  **Issue & Wakeup:** The `issue_queue_manager` constantly monitors the `wakeup_select_logic`. When an ALU finishes execution, it broadcasts its 7-bit Physical Register File (PRF) `dest_tag` on the `wakeup_bus`.
2.  **Execution Launch:** The Reservation Stations (`reservation_station_alu_0`, etc.) snoop this bus. If a queued micro-op's operands match the broadcasted tag, the operand is marked "Ready". When all operands are ready, the micro-op is launched to the `alu_execution_unit`.
3.  **Completion & Forwarding:** The ALU computes the 64-bit result and immediately routes it to the `forwarding_network_ctrl` to bypass the PRF and directly feed waiting ALUs, completely avoiding pipeline stalls. Simultaneously, the result is written to the `physical_regfile` and a "completion" signal is sent to the `reorder_buffer_ctrl`.

#### Commit Unit & Exception State Machine
The `commit_unit` acts as the definitive architectural state updater. It strictly executes in program order.
*   **FSM Logic:** 
    *   `STATE_IDLE`: Wait for the oldest ROB entry to assert `complete`.
    *   `STATE_COMMIT`: If `complete` is HIGH and no exception is flagged, write the result to the `architectural_regfile`. Send a `push` command to the `freelist_manager` to recycle the stale physical register.
    *   `STATE_TRAP`: If the ROB entry has an `exception_flag`, jump to `exception_handler`.
    *   `STATE_FLUSH`: Assert global `flush_pipeline`. Wipe the Front-End, clear the Issue Queues, and command the `register_alias_table` to rollback its map to the last known good architectural state. Jump to the `trap_vector_ctrl` PC.

#### Memory Disambiguation & Load/Store Queues (LSQ)
The `memory_disambiguation_unit` resolves address conflicts before they hit the L1 D-Cache.
*   **Store-to-Load Forwarding:** If a younger Load in the `load_queue` calculates its Effective Address (via `address_gen_unit`) and it perfectly matches an older uncommitted Store in the `store_queue`, the data is forwarded directly from the Store Queue, bypassing the cache.
*   **Aliasing Hazard:** If the Effective Address of a Load partially overlaps with an older Store, the Load MUST stall (`valid=0`) until the Store commits and writes to the L1 Cache via the `store_buffer`.

#### 2.6 Frozen Signal Interface Matrix (Modules 55-79)

*(All sequential modules strictly include `clk` and `rst_n`)*

### reorder_buffer_ctrl.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `alloc_req` | input | 4 | Allocate 1 to 4 entries |
| `commit_req` | output | 4 | Commit up to 4 instructions |
| `rob_full` | output | 1 | ROB full flag |

### rob_memory_array.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `wr_en` | input | 4 | 4 Write ports |
| `wr_addr` | input | `4 * $clog2(ROB_SIZE)` | Write addresses |
| `rd_en` | input | 4 | 4 Read ports |
| `rd_addr` | input | `4 * $clog2(ROB_SIZE)` | Read addresses |

### commit_unit.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `rob_head_info`| input | `4 * INFO_WIDTH`| Info of oldest instructions |
| `commit_en` | output | 4 | Commit enables |
| `arch_rf_we` | output | 4 | Architectural RF Write Enables |
| `freelist_push_en`| output | 4 | Push stale registers to Freelist |
| `stale_phys_reg` | output | `4 * 7` | Stale Physical Register IDs (7-bit) |

### exception_handler.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `exception_req`| input | 1 | Exception request from ROB |
| `cause` | input | 6 | Exception cause code |
| `flush_pipeline`| output| 1 | Flush signal |
| `trap_pc` | output | 64 | PC to jump to |

### trap_vector_ctrl.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `mtvec` | input | 64 | MTVEC CSR value |
| `cause` | input | 6 | Exception cause code |
| `vector_pc` | output | 64 | Computed Trap Vector PC |

### csr_register_file.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `rd_addr` | input | 12 | CSR Read Address |
| `rd_data` | output | 64 | CSR Read Data |
| `wr_addr` | input | 12 | CSR Write Address |
| `wr_data` | input | 64 | CSR Write Data |
| `wr_en` | input | 1 | CSR Write Enable |

### csr_control_unit.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `uop_csr` | input | `UOP_WIDTH` | CSR Micro-op |
| `csr_rf_we` | output | 1 | Write enable to CSR RF |
| `illegal_access`| output| 1 | Exception on illegal access |

### alu_execution_unit_0.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `rs1_data` | input | 64 | Operand 1 (64-bit) |
| `rs2_data` | input | 64 | Operand 2 (64-bit) |
| `opcode` | input | 4 | ALU Operation |
| `result` | output | 64 | ALU Result (64-bit) |
| `valid` | output | 1 | Result Valid |
| `dest_tag` | output | 7 | Destination Physical Reg ID / Tag (7-bit) |

### alu_execution_unit_1.sv
*(Identical to alu_execution_unit_0.sv)*

### alu_execution_unit_2.sv
*(Identical to alu_execution_unit_0.sv)*

### alu_execution_unit_3.sv
*(Identical to alu_execution_unit_0.sv)*

### branch_execution_unit.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `rs1_data` | input | 64 | Operand 1 |
| `rs2_data` | input | 64 | Operand 2 |
| `pc` | input | 64 | Current PC |
| `branch_taken`| output | 1 | Actual Outcome |
| `target_pc` | output | 64 | Computed Target PC |
| `dest_tag` | output | 7 | Destination Physical Reg Tag |

### address_gen_unit.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `base_addr` | input | 64 | Base Address Register |
| `offset` | input | 64 | Immediate Offset |
| `eff_addr` | output | 64 | Effective Address (Virtual) |

### mul_div_execution_unit.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `rs1_data` | input | 64 | Operand 1 |
| `rs2_data` | input | 64 | Operand 2 |
| `is_div` | input | 1 | 1 for DIV, 0 for MUL |
| `result` | output | 64 | Result |
| `valid` | output | 1 | Valid (Takes multiple cycles) |

### forwarding_network_ctrl.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `alu_results` | input | `4 * 64` | Results from ALUs |
| `mem_result` | input | 64 | Result from Load |
| `fw_rs1_data` | output | `4 * 64` | Forwarded data for RS1 |
| `fw_rs2_data` | output | `4 * 64` | Forwarded data for RS2 |

### load_queue.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `alloc_en` | input | 1 | Allocate Load |
| `address` | input | 64 | Load Address |
| `data_out` | output | 64 | Data returned from Cache |
| `hit_store` | output | 1 | Store-to-Load Forwarding Hit |

### store_queue.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `alloc_en` | input | 1 | Allocate Store |
| `address` | input | 64 | Store Address |
| `data_in` | input | 64 | Store Data |
| `commit_en` | input | 1 | Send to Store Buffer |

### store_buffer.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `push` | input | 1 | Push committed store |
| `address` | input | 64 | Physical Address |
| `data` | input | 64 | Data |
| `dcache_req` | output | 1 | Request to L1 D-Cache |

### memory_disambiguation_unit.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `ld_addr` | input | 64 | Load Address |
| `st_addrs` | input | `SQ_DEPTH * 64`| Addresses in Store Queue |
| `conflict` | output | 1 | Address conflict detected |
| `fwd_data` | output | 64 | Data forwarded from store |

### wakeup_select_logic.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `reqs` | input | 64 | Ready bits in Issue Queue |
| `grants` | output | 4 | Select up to 4 instructions |

### architectural_regfile.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `rd_addr` | input | `4 * 5` | 4 Read Ports (Debug/Trap) |
| `rd_data` | output | `4 * 64` | Read Data |
| `wr_addr` | input | `4 * 5` | 4 Write Ports (Commit) |
| `wr_data` | input | `4 * 64` | Write Data |
| `wr_en` | input | 4 | Write Enables |

### physical_regfile.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `rd_addr` | input | `8 * 7` | 8 Read Ports (Issue) |
| `rd_data` | output | `8 * 64` | Read Data |
| `wr_addr` | input | `4 * 7` | 4 Write Ports (Execution) |
| `wr_data` | input | `4 * 64` | Write Data |
| `wr_en` | input | 4 | Write Enables |

### core_performance_counters.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `event_instr` | input | 1 | Instruction Committed |
| `event_branch`| input | 1 | Branch executed |
| `event_miss` | input | 1 | Branch mispredict |
| `event_cache` | input | 1 | Cache Miss |
| `read_data` | output | 64 | Counter Value |

### core_debug_module.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `jtag_tck` | input | 1 | JTAG Clock |
| `halt_req` | input | 1 | Halt core execution |
| `resume_req` | input | 1 | Resume execution |
| `core_state` | output | 2 | Current debug state |

### trusted_execution_enclave.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `enclave_mode`| output | 1 | Enclave execution active |
| `mem_addr` | input | 64 | Memory Access Address |
| `access_deny` | output | 1 | Access violation flag |

## Section 3: RVV Vector Subsystem (Block 3)

This section mandates the microarchitecture for the RISC-V Vector (RVV) Subsystem. It dictates the wide datapath slicing, parallel execution topology, and specialized memory-access engines.

### 3.1 Datapath & Lane Topology
To achieve maximum vector processing throughput, the datapath is defined as **strictly 512-bits wide**, segmented into four parallel `vector_lane` units.
*   **Vector Register File (`vector_regfile_512b`):** Holds thirty-two 512-bit vector registers. Read/Write ports are full 512-bit width to feed the lane arrays instantly.
*   **Parallel Slicing:** A 512-bit vector is dispatched evenly across 4 parallel lanes (`vector_lane_0` through `vector_lane_3`). Each lane processes a **128-bit slice** per clock cycle.
*   **Mask Routing:** The `vector_mask_regfile` routes a 64-bit mask to the `vector_mask_logic` unit, which dynamically masks element updates per lane.

### 3.2 Dispatch & Load Balancing
The `vector_dispatch_queue` receives vector micro-ops from the scalar core via the `vector_processing_unit`.
*   **Load Balancing:** The dispatch queue monitors the `valid`/`ready` states of all 4 lanes. It broadcasts identical control opcodes to all 4 lanes but routes the 128-bit data slices independently. If any lane asserts `ready == 0`, the dispatch queue asserts backpressure to the scalar core.

### 3.3 Pipeline Timing & Execution Latency
*   **Vector MAC Array (`vector_mac_array`):** The Fused Multiply-Accumulate logic is deeply pipelined to exactly **3 clock cycles** to meet 90nm timing constraints.
    *   *Cycle 1:* Multiplicand alignment and partial product generation.
    *   *Cycle 2:* Wallace tree compression and accumulation addition.
    *   *Cycle 3:* Normalization and rounding.
    *   *Rule:* The `valid_out` signal must correctly delay by 3 cycles relative to `valid_in`.

### 3.4 Gather/Scatter Memory Unit FSM
The `vector_gather_scatter_unit` performs indexed memory operations, requiring complex address generation and AXI4-Full burst management.
*   **FSM Logic:**
    *   `STATE_IDLE`: Wait for `valid_in` containing the base address and offset vector.
    *   `STATE_CALC_ADDR`: Add the base address to all active (unmasked) elements in the offset vector (`v_offsets`).
    *   `STATE_AXI_ISSUE`: Issue parallel AXI4-Full read/write requests. Wait until `axi_awready` (for scatter) or `axi_arready` (for gather) == 1. **Rule:** Because the NoC is 256-bit, all 512-bit vector memory operations MUST be serialized into two back-to-back 256-bit AXI bursts.
    *   `STATE_AXI_WAIT`: Wait for burst response completion.
    *   `STATE_PACK`: Assemble the disjoint memory responses into a contiguous 512-bit vector format.
    *   `STATE_COMMIT`: Assert `valid_out` to write the assembled 512-bit vector back to the `vector_regfile_512b`.

### 3.5 Frozen Signal Interface Matrix (Vector Subsystem)

*(All sequential modules strictly include `clk` and `rst_n` and utilize standard handshakes. Interconnects are strict AXI4-Full).*

### vector_core_top.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `axi_awvalid` | output | 1 | AXI4-Full Write Address Valid |
| `axi_awready` | input | 1 | AXI4-Full Write Address Ready |
| `axi_awaddr` | output | 64 | AXI4-Full Write Address |
| `axi_awlen` | output | 8 | AXI4-Full Burst Length |
| `axi_wvalid` | output | 1 | AXI4-Full Write Data Valid |
| `axi_wready` | input | 1 | AXI4-Full Write Data Ready |
| `axi_wdata` | output | 256 | AXI4-Full Write Data (Downsized from 512) |
| `axi_arvalid` | output | 1 | AXI4-Full Read Address Valid |
| `axi_arready` | input | 1 | AXI4-Full Read Address Ready |
| `axi_araddr` | output | 64 | AXI4-Full Read Address |
| `axi_arlen` | output | 8 | AXI4-Full Burst Length |
| `axi_rvalid` | input | 1 | AXI4-Full Read Data Valid |
| `axi_rready` | output | 1 | AXI4-Full Read Data Ready |
| `axi_rdata` | input | 256 | AXI4-Full Read Data |

### vector_dispatch_queue.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `uop_in` | input | 64 | Vector micro-op from scalar core |
| `valid_in` | input | 1 | Micro-op valid |
| `ready_out` | output | 1 | Queue is ready |
| `issue_uop` | output | 64 | Issued micro-op to lanes |
| `lane_ready`| input | 4 | Ready status of the 4 lanes |

### vector_lane_0.sv (through vector_lane_3.sv)
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `valid_in` | input | 1 | Execute command valid |
| `op_code` | input | 8 | Vector execution opcode |
| `vs1_slice` | input | 128 | Vector operand 1 (128-bit slice) |
| `vs2_slice` | input | 128 | Vector operand 2 (128-bit slice) |
| `vs3_slice` | input | 128 | Vector operand 3 (128-bit slice) |
| `v0_mask` | input | 16 | Mask for this specific 128-bit slice |
| `valid_out` | output | 1 | Result valid |
| `vd_slice` | output | 128 | Result data (128-bit slice) |

### vector_regfile_512b.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `rd_addr_1` | input | 5 | Read port 1 address |
| `rd_data_1` | output | 512 | Read port 1 data (Full 512-bit) |
| `rd_addr_2` | input | 5 | Read port 2 address |
| `rd_data_2` | output | 512 | Read port 2 data (Full 512-bit) |
| `wr_en` | input | 1 | Write enable |
| `wr_addr` | input | 5 | Write address |
| `wr_data` | input | 512 | Write data (Full 512-bit) |

### vector_mac_array.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `valid_in` | input | 1 | Operand valid |
| `sew` | input | 3 | Standard Element Width |
| `vs1` | input | 128 | Operand 1 slice |
| `vs2` | input | 128 | Operand 2 slice |
| `vs3` | input | 128 | Addend slice |
| `valid_out` | output | 1 | Result valid (3 cycles delayed) |
| `vd` | output | 128 | Result slice |

### vector_gather_scatter_unit.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `valid_in` | input | 1 | Command valid |
| `is_store` | input | 1 | 1 = Scatter, 0 = Gather |
| `base_addr` | input | 64 | Scalar base address |
| `v_offsets` | input | 512 | 512-bit vector of offsets |
| `v_data` | input | 512 | 512-bit data to scatter |
| `v0_mask` | input | 64 | Mask for active elements |
| `axi_req_val` | output | 1 | AXI request valid |
| `axi_req_addr`| output | 64 | AXI request address |
| `axi_wdata` | output | 256 | AXI write data (Serialized from 512) |
| `axi_rsp_val` | input | 1 | AXI response valid |
| `axi_rsp_data`| input | 256 | AXI response data (Serialized to 512) |
| `valid_out` | output | 1 | Gather completion valid |
| `vd` | output | 512 | Assembled Gathered Data |

### vector_permutation_network.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `valid_in` | input | 1 | Command valid |
| `vs2` | input | 512 | Source vector |
| `vs1` | input | 512 | Index vector |
| `valid_out` | output | 1 | Result valid |
| `vd` | output | 512 | Permuted vector |

### vector_reduction_unit.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `valid_in` | input | 1 | Command valid |
| `op_type` | input | 4 | Reduction operation (Sum, Max) |
| `vs2` | input | 512 | Source vector to reduce |
| `valid_out` | output | 1 | Result valid |
| `vd_scalar` | output | 64 | Reduced scalar result |

*(Other utility modules: `vector_alu_int`, `vector_alu_fp`, `vector_mask_logic`, `vector_load_store_unit`, `vector_slide_unit`, `vector_forwarding_unit`, `vector_csr_unit`, `vector_commit_buffer`, `vector_processing_unit` adhere to identical strictly pipelined valid/ready protocols and 512-bit/128-bit slicing rules.)*

## Section 4: FPU Subsystem (Block 4)

This section defines the IEEE-754 compliant Floating Point Unit.

### 4.1 IEEE-754 Pipeline Stages & Execution
*   **Multiplier (`fp_multiplier`) & FMA (`fp_fma`):** Deeply pipelined to 4 clock cycles (Align, Multiply, Add/Round, Normalize).
*   **SRT Radix-4 Divider (`fp_divider_srt4`) & SQRT (`fp_sqrt_srt4`):** Unpipelined, multi-cycle execution. Uses an iterative SRT Radix-4 algorithm generating 2 bits of quotient per clock cycle. Average latency for FP64 is 34 cycles.
    *   **FSM Logic:** `STATE_IDLE` -> `STATE_NORMALIZE` -> `STATE_DIVIDE_ITER` (Loops 32 times for FP64) -> `STATE_ROUND` -> `STATE_DONE`.

### 4.2 FPU Forwarding & Exceptions
*   Results from the `fp_fma` and `fp_adder` are routed instantly through the `fp_forwarding_network` back to the `fp_reservation_station` to avoid PRF writeback latency.
*   **Exceptions:** `fp_exception_unit` monitors Inexact (NX), Underflow (UF), Overflow (OF), Divide-by-Zero (DZ), and Invalid (NV) flags, merging them into the `fflags` CSR inside the `fp_csr_unit`.

## Section 5: Advanced Memory Hierarchy (Block 5)

This section maps out the multi-level cache architecture, MESI coherency, and virtual memory translation.

### 5.1 Latency and Data Path Constraints
*   **L1 Caches (`l1_icache_ctrl`, `l1_dcache_ctrl`):** Strictly **1 clock cycle** hit latency. Data bus width is 64-bit to the core.
*   **L2 Cache (`l2_cache_ctrl`):** Strictly **4 clock cycles** hit latency. Data bus width is rigidly **256-bit wide** to match the NoC backbone.
*   **L3 Cache (`l3_cache_ctrl`):** Shared victim cache. Data bus width is **256-bit wide**.

### 5.2 MESI Coherency Directory FSM
The `mesi_coherency_directory` maintains consistency across all compute islands.
*   **FSM - Snoop Invalidate Transaction:**
    1.  `STATE_SNOOP_REQ`: Receives a write request to a shared cache line from the GPU NoC interface.
    2.  `STATE_LOOKUP`: Queries the `snoop_filter_unit`. If the block is cached in the RV64 L2, transition to `STATE_ISSUE_INV`.
    3.  `STATE_ISSUE_INV`: Send explicit "Snoop Invalidate" over the dedicated snoop channel to `l2_cache_ctrl`. Stall the GPU AXI response (`axi_awready` = 0).
    4.  `STATE_WAIT_ACK`: Wait for the L2 Cache to assert `snoop_ack`. If the L2 had the line in `Modified` state, it writes the dirty data back to DDR4 (or forwards it). If `Shared`, it simply flips the tag to `Invalid`.
    5.  `STATE_GRANT`: Once `snoop_ack` is received, assert `axi_awready` to the GPU, granting it Exclusive access to the memory block.

### 5.3 L3 Cache Miss & Arbiter Handshake
*   **Stall Condition:** If the `l3_cache_ctrl` misses, it asserts `l3_miss_stall` to the L2. It then formats an AXI4-Full read request to the `memory_arbiter`. The entire cache hierarchy for that specific address is stalled (`valid=0`) until the `memory_arbiter` routes the DDR4 `axi_rvalid` back up the chain.

### 5.4 Frozen Signal Interface Matrix (Blocks 4 & 5)

*(All sequential modules strictly include `clk` and `rst_n`)*

#### Block 4: FPU Subsystem

### fpu_top.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | input | 1 | Global Core Clock |
| `rst_n` | input | 1 | Global Asynchronous Active-Low Reset |
| `uop_in` | input | 64 | Micro-op from dispatch |
| `valid_in` | input | 1 | Issue valid |
| `ready_out` | output | 1 | FPU ready |
| `result_out`| output | 64 | FPU Result |
| `valid_out` | output | 1 | Result valid |

### fp_adder.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `valid_in` | input | 1 | Operand valid |
| `rs1`, `rs2` | input | 64 | FP64 Operands |
| `rm` | input | 3 | Rounding Mode |
| `valid_out` | output | 1 | Result valid (delayed) |
| `result` | output | 64 | FP64 Sum |
| `fflags` | output | 5 | Exception flags |

### fp_divider_srt4.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `valid_in` | input | 1 | Start division |
| `dividend`, `divisor` | input | 64 | Operands |
| `valid_out` | output | 1 | Div completion flag |
| `quotient` | output | 64 | Result |
| `fflags` | output | 5 | Exception flags |

*(Other FPU Modules: `fp_multiplier`, `fp_sqrt_srt4`, `fp_fma`, `fp_compare`, `fp_converter`, `fp_rounding_unit`, `fp_exception_unit`, `fp_register_file`, `fp_csr_unit`, `fp_issue_queue`, `fp_reservation_station`, `fp_commit_unit`, `fp_forwarding_network`, `fp_pipeline_ctrl` all share identical standard valid/ready pipelines and 64-bit FP data ports.)*

#### Block 5: Advanced Memory Hierarchy

### mmu_top.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `virt_addr` | input | 64 | Virtual Address |
| `satp` | input | 64 | CSR SATP |
| `phys_addr` | output | 64 | Physical Address |
| `page_fault`| output | 1 | Translation Exception |

### tlb_l1_data.sv & tlb_l1_inst.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `vpn` | input | 27 | Virtual Page Number |
| `ppn` | output | 44 | Physical Page Number |
| `tlb_hit` | output | 1 | TLB Hit flag |
| `tlb_miss`| output | 1 | Trigger page walker |

### page_table_walker.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `walk_req`| input | 1 | Start Walk |
| `vpn` | input | 27 | VPN to translate |
| `axi_arvalid`| output| 1 | AXI Read for PTE |
| `walk_done`| output | 1 | Translation complete |

### l1_dcache_ctrl.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `core_req_val`| input | 1 | Request from Core |
| `core_req_addr`| input| 64 | Physical Address |
| `core_rsp_val`| output| 1 | 1-Cycle Hit valid |
| `core_rsp_data`| output| 64 | 64-bit Data to Core |
| `l2_req_val`| output | 1 | Miss Request to L2 |
| `l2_req_addr`| output | 64 | Address to L2 |
| `l2_req_data`| output | 256 | 256-bit Writeback Data to L2 |
| `l2_req_rdy`| input | 1 | Backpressure from L2 |
| `l2_rsp_val`| input | 1 | Fill Response from L2 |
| `l2_rsp_data`| input | 256 | 256-bit Fill Data from L2 |

### l2_cache_ctrl.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `l1_req_val`| input | 1 | Request from L1 |
| `l1_req_addr`| input | 64 | Address from L1 |
| `l1_req_data`| input | 256 | Data from L1 |
| `l1_req_rdy`| output | 1 | Backpressure to L1 |
| `l1_rsp_val`| output | 1 | 4-Cycle Hit valid to L1 |
| `l1_rsp_data`| output | 256 | 256-bit Data to L1 |
| `snoop_req` | input | 1 | MESI Snoop Invalidate |
| `snoop_ack` | output | 1 | MESI Snoop Ack |
| `l3_req_val`| output | 1 | Miss Request to L3 |
| `l3_req_addr`| output | 64 | Miss Address to L3 |
| `l3_req_data`| output | 256 | Writeback Data to L3 |
| `l3_rsp_val`| input | 1 | Fill Response from L3 |
| `l3_rsp_data`| input | 256 | Fill Data from L3 |

### l3_cache_ctrl.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `l2_req_val`| input | 1 | Request from L2 |
| `l2_req_addr`| input | 64 | Address from L2 |
| `l2_req_data`| input | 256 | Data from L2 |
| `l2_rsp_val`| output | 1 | Response Valid to L2 |
| `l2_rsp_data`| output | 256 | 256-bit Data to L2 |
| `l3_miss_stall`| output| 1 | Asserted on L3 Miss |
| `axi_awvalid`| output | 1 | 256-bit AXI4-Full Burst |
| `axi_awaddr` | output | 64 | AXI Write Address |
| `axi_wdata` | output | 256 | AXI Write Data |
| `axi_arvalid`| output | 1 | AXI Read Valid |
| `axi_araddr` | output | 64 | AXI Read Address |
| `axi_rdata` | input | 256 | AXI Read Data |

### mesi_coherency_directory.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `bus_write_req`| input | 1 | Write attempt on NoC |
| `bus_addr` | input | 64 | Shared Address |
| `snoop_req` | output | 1 | Send Snoop to L2 |
| `snoop_ack` | input | 1 | Wait for L2 Flush/Inv |
| `grant_access`| output | 1 | Resume NoC Traffic |

### memory_arbiter.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `l3_axi_awaddr`, `araddr`| input | 64 | AXI Addresses from L3 |
| `l3_axi_wdata` | input | 256 | AXI Write Data from L3 |
| `l3_axi_rdata` | output| 256 | AXI Read Data to L3 |
| `dma_axi_awaddr`, `araddr`| input | 64 | AXI Addresses from DMA |
| `dma_axi_wdata`| input | 256 | AXI Write Data from DMA |
| `dma_axi_rdata`| output| 256 | AXI Read Data to DMA |
| `ddr_axi_awaddr`, `araddr`| output| 64 | Arbitrated AXI Addresses |
| `ddr_axi_wdata`| output| 256 | Arbitrated Write Data |
| `ddr_axi_rdata`| input | 256 | Arbitrated Read Data |

*(Remaining structural arrays and engines: `l1_icache_data_array`, `l1_icache_tag_array`, `l1_dcache_data_array`, `l1_dcache_tag_array`, `l2_cache_data_array`, `l2_cache_tag_array`, `l3_cache_data_array`, `l3_cache_tag_array`, `snoop_filter_unit`, `axi4_full_bridge`, `axi4_lite_bridge`, `dma_controller_ch0`, `dma_controller_ch1`, `memory_protection_unit`, `ecc_encoder_decoder`, `cache_performance_monitor`, `prefetch_engine`, `memory_power_ctrl`, `memory_bist_engine` all strictly follow the 256-bit interconnect and 1-cycle/4-cycle stall logic defined above.)*

## Section 6: Neural Processing Unit (NPU) Subsystem (Block 6)

This section details the microarchitecture of the deeply pipelined, high-throughput Neural Processing Unit, focused on matrix multiplication and tensor activation logic.

### 6.1 Systolic Array & Datapath Topology
*   **128x128 Systolic Array (`npu_systolic_array`):** The core compute engine is a 2D grid of 16,384 MAC units capable of processing a 128x128 matrix multiplication per clock cycle.
*   **Datatypes:** The array natively supports `INT8` (1-cycle MAC) and `FP16` (2-cycle MAC) execution. The data type is controlled via the `npu_csr_config` register.
*   **Weight & Activation Flow:** The `npu_weight_scratchpad` feeds the array horizontally, while the `npu_activation_scratchpad` feeds the array vertically. The partial sums (PSUMs) propagate downwards into the `npu_psum_buffer`.

### 6.2 Dual-Ported SRAM Scratchpads
The local SRAM scratchpads (`npu_activation_scratchpad` and `npu_weight_scratchpad`) are explicitly dual-ported:
*   **Port A (Write-Only):** Connected directly to the `npu_dma_controller` for continuous, high-speed AXI burst fills from the L3 Cache.
*   **Port B (Read-Only):** Connected directly to the `npu_systolic_array` to sustain maximum throughput without contention.

### 6.3 Sparsity Decoder & Zero-Skipping FSM
The `npu_sparsity_decoder` analyzes incoming weight streams before they hit the SRAM.
*   **FSM Logic:**
    *   `STATE_FETCH`: Read compressed weight block from DMA.
    *   `STATE_EVAL`: Check the sparsity bitmap. If a weight is `0`, transition to `STATE_SKIP`, otherwise `STATE_WRITE`.
    *   `STATE_SKIP`: Do not allocate SRAM space. Signal the Systolic Array to bypass the MAC operation for this index (saving dynamic power).
    *   `STATE_WRITE`: Write non-zero weight to the Scratchpad and advance pointers.

### 6.4 NPU DMA Controller & Backpressure
The `npu_dma_controller` streams tensor data from the L3 Cache to the NPU scratchpads without stalling the RV64 Core.
*   **Burst FSM:** `STATE_IDLE` -> `STATE_REQ_BURST` -> `STATE_RECEIVE_BURST` -> `STATE_DONE`.
*   **Strict PSUM Backpressure:** If the `npu_psum_buffer` reaches its watermark, it asserts `psum_stall = 1`. This immediately backpressures the `npu_systolic_array` (`ready = 0`), which cascades back up to halt the `npu_dma_controller`, preventing SRAM overwrite until the `npu_activation_unit` drains the PSUMs.

### 6.5 NPU Pipeline Stages (Post-Processing)
1.  **PSUM Accumulation:** Add partial sums in the `npu_psum_buffer`.
2.  **Activation (`npu_activation_unit`):** Apply non-linear functions (ReLU, Sigmoid).
3.  **Pooling (`npu_pooling_engine`):** Perform Max or Average pooling.
4.  **Writeback:** Send final tensors back to L3 via the DMA write channel.

### 6.6 Frozen Signal Interface Matrix (Modules 147-186)

*(All sequential modules strictly include `clk` and `rst_n`. AXI channels conform strictly to AXI4-Full standard).*

### npu_top.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `axi_awid` | output | 4 | Write Address ID |
| `axi_awaddr` | output | 64 | Write Address |
| `axi_awlen` | output | 8 | Burst Length |
| `axi_awvalid`| output | 1 | Write Address Valid |
| `axi_awready`| input | 1 | Write Address Ready |
| `axi_wdata` | output | 256 | Write Data (NoC matched) |
| `axi_wstrb` | output | 32 | Write Strobes |
| `axi_wlast` | output | 1 | Last Transfer in Burst |
| `axi_wvalid` | output | 1 | Write Data Valid |
| `axi_wready` | input | 1 | Write Data Ready |
| `axi_arid` | output | 4 | Read Address ID |
| `axi_araddr` | output | 64 | Read Address |
| `axi_arlen` | output | 8 | Burst Length |
| `axi_arvalid`| output | 1 | Read Address Valid |
| `axi_arready`| input | 1 | Read Address Ready |
| `axi_rdata` | input | 256 | Read Data |
| `axi_rlast` | input | 1 | Last Read Transfer |
| `axi_rvalid` | input | 1 | Read Data Valid |
| `axi_rready` | output | 1 | Read Data Ready |

### npu_dma_controller.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `cfg_src_addr`| input | 64 | CSR Source Address |
| `cfg_dst_addr`| input | 64 | CSR Dest Address |
| `cfg_size` | input | 32 | Transfer Size |
| `start_dma` | input | 1 | Trigger Burst |
| `axi_arvalid` | output | 1 | Request AXI Read |
| `axi_araddr` | output | 64 | AXI Read Address |
| `axi_rready` | output | 1 | AXI Read Ready |
| `axi_rdata` | input | 256 | AXI Read Data |
| `sram_wr_en` | output | 1 | Write to Scratchpad |
| `sram_wr_data`| output | 256 | Data to Scratchpad |
| `stall_in` | input | 1 | Backpressure from PSUM |

### npu_activation_scratchpad.sv & npu_weight_scratchpad.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `wr_en` | input | 1 | Port A: DMA Write Enable |
| `wr_addr` | input | 16 | Port A: Write Address |
| `wr_data` | input | 256 | Port A: Write Data |
| `rd_en` | input | 1 | Port B: Array Read Enable |
| `rd_addr` | input | 16 | Port B: Read Address |
| `rd_data` | output | 256 | Port B: Read Data |

### npu_systolic_array.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `valid_in` | input | 1 | Inputs Valid |
| `act_in` | input | `128 * 16`| Activation Vector (128 elms, FP16/INT8) |
| `wt_in` | input | `128 * 16`| Weight Vector |
| `is_fp16` | input | 1 | Datatype select |
| `skip_mask` | input | 128 | From Sparsity Decoder |
| `stall_in` | input | 1 | Backpressure from PSUM |
| `psum_out` | output | `128 * 32`| 128 Partial Sums (INT32/FP32) |
| `valid_out` | output | 1 | Output Valid |

### npu_sparsity_decoder.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `compressed_in`| input | 256 | Compressed weights |
| `valid_in` | input | 1 | Input valid |
| `skip_mask` | output | 128 | Zero-skip bitmap |
| `expanded_out` | output | 256 | Padded weights |

### npu_psum_buffer.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `psum_in` | input | `128 * 32`| PSUMs from Array |
| `valid_in` | input | 1 | Input Valid |
| `psum_stall` | output | 1 | Asserted on buffer watermark |
| `acc_out` | output | `128 * 32`| Accumulated Output |

### npu_activation_unit.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `data_in` | input | `128 * 32`| PSUM Data |
| `act_type` | input | 2 | 0=ReLU, 1=Sigmoid, 2=Tanh |
| `data_out` | output | `128 * 16`| Activated Data (Quantized) |

### npu_pooling_engine.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `data_in` | input | `128 * 16`| Activated Data |
| `pool_type` | input | 1 | 0=Max, 1=Avg |
| `data_out` | output | `32 * 16` | Pooled Data |

*(Additional structural NPU sub-modules (147-186) adhere to standard decoupled valid/ready interfaces cascading backpressure to the DMA).*

## Section 7: Graphics Processing Unit (GPU) Subsystem (Block 7)

This section maps out the microarchitecture of the integrated GPU. It dictates the highly-parallel graphics pipeline, the 32-wide SIMD shader execution model, and the complex texture/Z-culling memory hierarchy.

### 7.1 Graphics Pipeline & Load Balancing
The GPU operates as a decoupled coprocessor fed by display lists.
1.  **Command Processor (`gpu_cmd_processor`):** Fetches and decodes API-level graphics commands from system memory.
2.  **Geometry Pipeline (`gpu_geometry_engine`):** Performs vertex shading, primitive assembly, and clipping.
3.  **Rasterizer (`gpu_rasterizer`):** Converts primitives into fragment pixels. It is hardcoded to output exactly **4 pixels per clock cycle**.
4.  **Shader Clusters (`gpu_shader_core`):** A unified architecture executing both vertex and fragment workloads. Work is load-balanced by the `gpu_thread_dispatcher`, which packages available work items into discrete **32-wide SIMD warps (threads)** and assigns them to the least-busy Shader Core.
5.  **Render Output Unit (`gpu_rop_unit`):** Handles depth testing, alpha blending, and writes the final pixels to the Framebuffer via AXI bursts.

### 7.2 FSMs: Command, TMU, Z-Cull, and Decompression
**1. Command Processor FSM (`gpu_cmd_processor`)**
*   `STATE_IDLE`: Wait for the CPU to write the display list base address to the Ring Buffer CSR.
*   `STATE_FETCH_CMD`: Dispatch a 256-bit AXI read to the NoC to fetch the next command batch.
*   `STATE_DECODE`: Parse the 256-bit word into vertex draw calls or state-change commands.
*   `STATE_DISPATCH`: Push commands into the Geometry Engine's FIFO.

**2. Hierarchical Z-Cull FSM (`gpu_hz_cull_unit`)**
*   `STATE_TEST_TILE`: Evaluate a 4x4 pixel tile against the compressed Hi-Z buffer.
*   `STATE_PASS`: All fragments are visible. Forward to the Fragment Shader.
*   `STATE_KILL`: Entire tile is occluded by existing geometry. Discard the 4x4 block to save shader power.
*   `STATE_PARTIAL`: Send only the visible pixels from the tile down the pipeline.

**3. Texture Mapping Unit (TMU) FSM (`gpu_tmu`)**
*   `STATE_RECV_COORDS`: Receive U,V texture coordinates from the Fragment Shader.
*   `STATE_L1_LOOKUP`: Query the local `gpu_l1_tex_cache`. Wait for the strict **2-cycle hit latency**. If miss, transition to `STATE_L3_REQ`.
*   `STATE_L3_REQ`: Issue a memory request to the global L3 cache via the `gpu_mmu`.
*   `STATE_FILTER`: Apply Bilinear or Trilinear filtering to the returned texels.
*   `STATE_RETURN`: Forward the sampled RGBA color back to the Shader.

**4. Texture Decompression FSM (`gpu_tex_decompressor`)**
*   `STATE_EVAL_BLOCK`: Receive a compressed 4x4 texel block (e.g., ASTC or BCn format) from the L1-Tex cache.
*   `STATE_EXTRACT_PALETTE`: Decode the endpoint colors from the block header.
*   `STATE_INTERPOLATE`: Generate the intermediate color palette values.
*   `STATE_MAP_INDICES`: Map each texel's index to the generated palette and output the uncompressed 32-bit RGBA colors.

### 7.3 Data Widths and Handshakes
*   **Shader Cores:** Internally feature 32 parallel ALU lanes executing identical instructions across different pixel data (SIMT model).
*   **NoC Interface:** The main interconnect wrapper (`gpu_axi_wrapper`) strictly enforces a **256-bit wide** data bus for all L2/L3 communication to perfectly match the core SoC backbone.
*   **Shader to ROP Handshake:** Fragment data is passed from the shader to the ROP via a strict `valid`/`ready` streaming handshake. If the ROP stalls (e.g., waiting for framebuffer writes to clear), it asserts `rop_ready = 0`, freezing the final pipeline stage of the shader.

### 7.4 Frozen Signal Interface Matrix (GPU Modules 187-228)

*(All sequential modules strictly include `clk` and `rst_n`)*

### gpu_top.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `axi_awvalid` | output | 1 | 256-bit AXI4-Full Write Valid |
| `axi_awready` | input | 1 | 256-bit AXI4-Full Write Ready |
| `axi_awaddr` | output | 64 | Write Address |
| `axi_wdata` | output | 256 | Strict 256-bit Write Data |
| `axi_arvalid` | output | 1 | 256-bit AXI4-Full Read Valid |
| `axi_arready` | input | 1 | 256-bit AXI4-Full Read Ready |
| `axi_araddr` | output | 64 | Read Address |
| `axi_rdata` | input | 256 | Strict 256-bit Read Data |

### gpu_cmd_processor.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `ring_buffer_base`| input | 64 | Display List pointer |
| `cmd_req_val` | output | 1 | Request AXI Read |
| `cmd_req_addr`| output | 64 | AXI Read Address |
| `cmd_rsp_val` | input | 1 | AXI Read Valid |
| `cmd_rsp_data`| input | 256 | 256-bit Command Data |
| `disp_val` | output | 1 | Dispatch command to pipeline |
| `disp_data` | output | 128 | Decoded instruction |

### gpu_rasterizer.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `prim_in_val` | input | 1 | Primitive geometry valid |
| `prim_v0`, `v1`, `v2`| input | 3x32 | Triangle vertices |
| `frag_out_val`| output | 1 | Output valid |
| `frag_out_xy` | output | 4x32 | 4 Pixels per clock (X,Y) |
| `rast_ready` | input | 1 | Backpressure from Z-Cull |

### gpu_hz_cull_unit.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `tile_in_val` | input | 1 | 4x4 Pixel tile valid |
| `tile_depth` | input | 32 | Max depth of tile |
| `hiz_buffer_rd`| output | 32 | Read compressed Z value |
| `tile_out_val`| output | 1 | Visible tile valid |
| `tile_occluded`| output | 1 | Tile killed flag |

### gpu_shader_core.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `warp_in_val` | input | 1 | 32-wide Warp valid |
| `thread_data` | input | `32*32`| 32 parallel input payloads |
| `tmu_req_val` | output | 1 | Request texture lookup |
| `tmu_req_uv` | output | 64 | U,V Coordinates |
| `tmu_rsp_val` | input | 1 | Texture fetch complete |
| `tmu_rsp_color`| input | 32 | RGBA Color (32-bit) |
| `rop_valid` | output | 1 | Fragment Shader Output Valid |
| `rop_ready` | input | 1 | Strict handshaking from ROP |
| `frag_color` | output | `32*32`| 32 parallel RGBA pixels |

### gpu_tmu.sv (Texture Mapping Unit)
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `req_val` | input | 1 | Request valid |
| `uv_coords` | input | 64 | Texture coords |
| `l1_tex_req` | output | 1 | Request to L1-Tex |
| `l1_tex_rsp` | input | 1 | Strict 2-cycle hit response |
| `l1_tex_data` | input | 256 | Compressed block data |
| `decomp_req` | output | 1 | Send to decompressor |
| `filter_mode` | input | 2 | Point, Bilinear, Trilinear |
| `color_out` | output | 32 | Filtered RGBA Output |

### gpu_tex_decompressor.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `comp_block_val`| input| 1 | Compressed 4x4 block valid |
| `comp_block_data`|input| 128 | Encoded block (e.g., BC1/ASTC) |
| `color_out_val`| output| 1 | Decompressed color valid |
| `color_out_data`|output| `16*32`| 16 uncompressed RGBA pixels |

### gpu_mmu.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `gpu_virt_addr`| input | 64 | Virtual Address from shader/TMU |
| `pt_req_val` | output | 1 | Page table walk request |
| `phys_addr` | output | 64 | Translated Physical Address |
| `page_fault` | output | 1 | Illegal access |

### gpu_rop_unit.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `frag_valid` | input | 1 | From Shader Core |
| `frag_ready` | output | 1 | Backpressure to Shader Core |
| `frag_color` | input | `32*32`| 32 incoming pixels |
| `frag_depth` | input | `32*32`| 32 incoming Z values |
| `fb_write_val`| output | 1 | Framebuffer Write Request |
| `fb_write_addr`| output| 64 | Framebuffer Address |
| `fb_write_data`| output| 256 | 256-bit Framebuffer burst |

*(Other utility modules: `gpu_thread_dispatcher`, `gpu_l1_tex_cache`, `gpu_l2_cache`, `gpu_axi_wrapper`, `gpu_geometry_engine` all strictly follow the Valid/Ready protocols and 256-bit NoC alignment described above).*

## Section 8: Hardware Video Codec (Block 8)

This section details the dedicated hardware accelerator for video decoding (e.g., HEVC/H.264), engineered to sustain **4K@60fps YUV420** throughput.

### 8.1 Macroblock Decoding Pipeline
To achieve 4K@60fps (approx. 500 million pixels/sec), the decoding pipeline is deeply buffered and operates on 16x16 or 32x32 macroblocks.
1.  **Bitstream Parser (`vid_bitstream_parser`):** Parses NAL units and extracts sequence/picture parameter sets.
2.  **Entropy Decoder (`vid_entropy_decoder`):** Lossless decoding of syntax elements.
3.  **Inverse Quantization & Transform (`vid_iq_it_unit`):** Reconstructs residual spatial data.
4.  **Motion Compensation (`vid_motion_comp`):** Fetches reference frames and applies motion vectors.
5.  **Intra Prediction (`vid_intra_predict`):** Generates spatial predictions from neighboring blocks.
6.  **Loop Filter (`vid_loop_filter`):** Applies deblocking to eliminate macroblock edge artifacts.

### 8.2 FSMs: Video DMA and Entropy Decoder
**1. Video DMA Controller FSM (`vid_dma_ctrl`)**
*   `STATE_IDLE`: Wait for codec enable signal.
*   `STATE_REQ_FIFO_FILL`: When the local bitstream FIFO drops below the watermark, issue an AXI4-Full read burst to Main Memory.
*   `STATE_AXI_WAIT`: Wait for the 256-bit burst data.
*   `STATE_PUSH_FIFO`: Push the 256-bit compressed stream into the local `vid_stream_fifo`. If the decoding frame is complete, transition to `STATE_DONE`.

**2. Entropy Decoder FSM (CABAC) (`vid_entropy_decoder`)**
*   `STATE_INIT`: Initialize the CABAC arithmetic decoding engine context models.
*   `STATE_DECODE_BIN`: Decode a single binary symbol (bin) from the bitstream.
*   `STATE_UPDATE_MODEL`: Update the probability context model based on the decoded bin.
*   `STATE_MAP_SYNTAX`: Map the sequence of bins to the actual syntax element (e.g., motion vector difference, transform coefficient). Send to downstream queues.

### 8.3 FSMs: IQ/IT and Motion Compensation
**1. Inverse Quantization & Transform FSM (`vid_iq_it_unit`)**
*   `STATE_FETCH_COEFFS`: Pop a block of quantized transform coefficients from the Entropy Decoder FIFO.
*   `STATE_INV_QUANT`: Multiply by the quantization step size.
*   `STATE_IDCT`: Perform the 2D Inverse Discrete Cosine Transform.
*   `STATE_OUT`: Push the spatial residual block to the reconstruction adder.

**2. Motion Compensation FSM (`vid_motion_comp`)**
*   `STATE_FETCH_MVS`: Read motion vectors from the macroblock header.
*   `STATE_CALC_ADDR`: Calculate the AXI address of the reference frame in the L3 cache/DDR4.
*   `STATE_FETCH_REF`: Issue a 256-bit AXI read burst to fetch the reference macroblock.
*   `STATE_INTERPOLATE`: Apply sub-pixel (half-pel/quarter-pel) FIR filtering to the reference pixels.
*   `STATE_BLEND`: Forward the predicted macroblock to the reconstruction adder.

### 8.4 Frozen Signal Interface Matrix (Video Codec Modules)

*(All sequential modules strictly include `clk` and `rst_n`)*

### vid_codec_top.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `axi_awvalid` | output | 1 | 256-bit AXI4-Full Write Valid |
| `axi_awready` | input | 1 | 256-bit AXI4-Full Write Ready |
| `axi_awaddr` | output | 64 | Write Address (Decoded Frame) |
| `axi_wdata` | output | 256 | Strict 256-bit Write Data (YUV) |
| `axi_arvalid` | output | 1 | 256-bit AXI4-Full Read Valid |
| `axi_arready` | input | 1 | 256-bit AXI4-Full Read Ready |
| `axi_araddr` | output | 64 | Read Address (Bitstream/Ref) |
| `axi_rdata` | input | 256 | Strict 256-bit Read Data |
| `interrupt` | output | 1 | Frame decode complete |

### vid_dma_ctrl.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `stream_base` | input | 64 | Bitstream address |
| `stream_len` | input | 32 | Bitstream length |
| `fifo_full` | input | 1 | Stall from local FIFO |
| `axi_arvalid` | output | 1 | Request AXI Read burst |
| `axi_araddr` | output | 64 | AXI Read Address |
| `axi_rdata` | input | 256 | Compressed data |
| `axi_rvalid` | input | 1 | AXI Read Data Valid |
| `fifo_push` | output | 1 | Push to local FIFO |
| `fifo_data` | output | 256 | Data to local FIFO |

### vid_entropy_decoder.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `bs_valid` | input | 1 | Bitstream valid |
| `bs_data` | input | 32 | 32-bit chunk from parser |
| `bs_ready` | output | 1 | Backpressure to parser |
| `coeff_val` | output | 1 | Syntax element decoded |
| `coeff_data`| output | 32 | Decoded value/coeff |
| `coeff_rdy` | input | 1 | Stall from IQ/IT unit |

### vid_iq_it_unit.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `coeff_val` | input | 1 | Coeff input valid |
| `coeff_data`| input | 32 | Coeff input data |
| `qp_value` | input | 8 | Quantization Parameter |
| `res_val` | output | 1 | Residual output valid |
| `res_data` | output | `16*8`| Residual pixels (16-wide) |

### vid_motion_comp.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `mv_val` | input | 1 | Motion Vector valid |
| `mv_x`, `mv_y`| input | 16 | Motion Vector X/Y |
| `ref_idx` | input | 8 | Reference frame index |
| `axi_arvalid` | output| 1 | Fetch reference block |
| `axi_araddr` | output| 64 | Reference block Address |
| `axi_rdata` | input | 256 | Ref block data |
| `axi_rvalid` | input | 1 | Ref data valid |
| `pred_val` | output| 1 | Prediction valid |
| `pred_data` | output| `16*8`| Predicted pixels |

### vid_loop_filter.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `mb_in_val` | input | 1 | Reconstructed MB valid |
| `mb_in_data`| input | 256 | Unfiltered pixels |
| `bs_param` | input | 8 | Boundary Strength |
| `mb_out_val`| output| 1 | Filtered MB valid |
| `mb_out_data`|output| 256 | Filtered pixels for Framebuffer |

*(The NoC and Peripherals will be defined in subsequent blocks to ensure absolute rigorous precision and avoid hallucination).*

## Section 9: Network-on-Chip (NoC) & Global Peripherals (Block 9)

This section maps the central nervous system of the SoC. The NoC routes high-bandwidth traffic between the compute islands (RV64 Core, NPU, GPU, Video Codec) and the memory subsystem, while the APB bridge connects low-speed peripherals.

### 9.1 NoC 2D-Mesh Topology & Routing
The NoC employs a 2D-Mesh topology utilizing an **X-Y Routing Algorithm**.
*   **Routing Logic:** Flits always traverse the X-axis first until the destination X-coordinate is reached, then traverse the Y-axis. This guarantees deterministic, deadlock-free routing.
*   **Data Widths:** The primary data plane crossbars are rigidly **256-bits wide** (matching the AXI4-Full specification of the compute islands).

### 9.2 Virtual Channel (VC) Allocation FSM
To prevent Head-of-Line (HoL) blocking and manage traffic congestion, each NoC router utilizes 4 Virtual Channels. The `noc_vc_allocator` FSM handles flit arbitration.
*   `STATE_IDLE`: Monitor the input buffers for incoming Head Flits.
*   `STATE_VC_REQ`: Read the destination ID from the Head Flit and request an empty VC from the downstream router.
*   `STATE_ARBITRATE`: If multiple input ports request the same downstream VC, use round-robin arbitration to select a winner.
*   `STATE_VC_GRANT`: Grant the VC to the winning packet. Transition to `STATE_FLIT_FWD`.
*   `STATE_FLIT_FWD`: Forward Body Flits and the Tail Flit. Assert `credit_out` to upstream router. If the downstream buffer fills up (zero credits), transition to `STATE_STALL`.
*   `STATE_STALL`: Halt transmission (`ready=0`) until a downstream credit is received.

### 9.3 NoC Router Latency
The `noc_router` logic is deeply pipelined to a strict **3-cycle flit latency**:
1.  **Cycle 1 (Buffer Write & Decode):** Flit arrives and is written to the input FIFO. The destination is decoded.
2.  **Cycle 2 (Route Compute & Switch Alloc):** The X-Y algorithm computes the exit port; the switch allocator arbitrates port access.
3.  **Cycle 3 (Switch Traversal):** The flit traverses the crossbar matrix and is latched onto the outgoing link.

### 9.4 AXI-to-APB Bridge & Peripherals FSM
Low-speed peripherals (UART, SPI, I2C, Timers) operate on the 32-bit Advanced Peripheral Bus (APB). The `axi_to_apb_bridge` translates 256-bit AXI memory-mapped IO (MMIO) requests down to 32-bit APB transfers.
*   **APB Transfer FSM:**
    *   `STATE_IDLE`: Wait for an AXI AR/AW request mapped to the peripheral address range.
    *   `STATE_SETUP`: Assert `PSEL` (Peripheral Select) and drive `PADDR` and `PWRITE`.
    *   `STATE_ACCESS`: Assert `PENABLE`. Wait for the peripheral to assert `PREADY`.
    *   `STATE_RESPONSE`: De-assert `PENABLE` and map the APB `PRDATA` or write-response back to the AXI bus.

### 9.5 Frozen Signal Interface Matrix (Modules 246-270)

*(All sequential modules strictly include `clk` and `rst_n`)*

### noc_router.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `flit_in_n`, `s`, `e`, `w`, `l` | input | 5x256 | Incoming Flits from 5 directions (North, South, East, West, Local) |
| `valid_in_n`, `s`, `e`, `w`, `l`| input | 5 | Incoming Flit Valid flags |
| `credit_out_n`,`s`,`e`,`w`,`l`| output| 5 | Credits sent to upstream routers |
| `flit_out_n`, `s`, `e`, `w`, `l`| output| 5x256 | Outgoing Flits to 5 directions |
| `valid_out_n`,`s`,`e`,`w`,`l`| output| 5 | Outgoing Flit Valid flags |
| `credit_in_n`, `s`, `e`, `w`, `l`| input | 5 | Credits received from downstream routers |

### noc_network_interface.sv (AXI to NoC Packetizer)
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `axi_awaddr`, `wdata`| input | 64, 256| AXI4-Full Write channels from compute IP |
| `axi_awvalid`,`wvalid`| input | 1, 1 | AXI Write Valid |
| `axi_awready`,`wready`| output| 1, 1 | AXI Write Ready (Backpressure) |
| `flit_out` | output | 256 | Packetized NoC Flit |
| `flit_out_val` | output | 1 | Flit valid |
| `credit_in` | input | 1 | Downstream router credit |

### axi_to_apb_bridge.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `axi_awaddr` | input | 64 | AXI Write Address |
| `axi_awvalid`| input | 1 | AXI Write Valid |
| `axi_awready`| output| 1 | AXI Write Ready |
| `axi_wdata` | input | 256 | AXI Write Data (Lower 32-bits used) |
| `axi_wvalid` | input | 1 | AXI Write Data Valid |
| `axi_wready` | output| 1 | AXI Write Data Ready |
| `axi_araddr` | input | 64 | AXI Read Address |
| `axi_arvalid`| input | 1 | AXI Read Valid |
| `axi_arready`| output| 1 | AXI Read Ready |
| `axi_rdata` | output| 256 | AXI Read Data (Padded 256-bit) |
| `axi_rvalid` | output| 1 | AXI Read Data Valid |
| `axi_rready` | input | 1 | AXI Read Data Ready |
| `PSEL` | output | 1 | APB Peripheral Select |
| `PENABLE` | output | 1 | APB Enable |
| `PWRITE` | output | 1 | APB Write/Read Dir |
| `PADDR` | output | 32 | APB Address |
| `PWDATA` | output | 32 | APB Write Data |
| `PRDATA` | input | 32 | APB Read Data |
| `PREADY` | input | 1 | APB Ready (Stall signal) |

### peripheral_uart.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `PSEL`, `PENABLE`, `PWRITE`| input | 1 | APB Control Bus |
| `PADDR`, `PWDATA` | input | 32 | APB Address & Data |
| `PRDATA` | output | 32 | APB Read Data |
| `PREADY` | output | 1 | APB Ready |
| `uart_rx` | input | 1 | External UART Receive Pin |
| `uart_tx` | output | 1 | External UART Transmit Pin |
| `interrupt` | output | 1 | RX/TX complete interrupt |

### peripheral_spi.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `PSEL`, `PENABLE`, `PWRITE`| input | 1 | APB Control Bus |
| `PADDR`, `PWDATA` | input | 32 | APB Address & Data |
| `PRDATA` | output | 32 | APB Read Data |
| `PREADY` | output | 1 | APB Ready |
| `spi_sclk` | output | 1 | Serial Clock |
| `spi_mosi` | output | 1 | Master Out Slave In |
| `spi_miso` | input | 1 | Master In Slave Out |
| `spi_cs_n` | output | 4 | Chip Select (Active Low) |

### peripheral_timer.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `PSEL`, `PENABLE`, `PWRITE`| input | 1 | APB Control Bus |
| `PADDR`, `PWDATA` | input | 32 | APB Address & Data |
| `PRDATA` | output | 32 | APB Read Data |
| `PREADY` | output | 1 | APB Ready |
| `timer_intr` | output | 1 | Timer Expiration Interrupt |

*(Other peripherals such as `peripheral_i2c`, `peripheral_gpio`, `peripheral_rtc`, and the central `plic_interrupt_controller` follow the identical 32-bit APB protocol structure).*

## Section 10: External Interfaces & SoC Top-Level Wrapper (Block 10)

This final section integrates all sub-systems into the top-level silicon wrapper. It defines the physical DDR4/PCIe interfaces, Clock Domain Crossing (CDC) boundaries, and the "Iterative Conductor" responsible for system boot and power sequencing.

### 10.1 DDR4 Memory Controller (`ddr4_mem_ctrl`)
The DDR4 controller translates 256-bit AXI4-Full NoC requests into physical DDR4 commands.
*   **Data Width:** The PHY interface is strictly **72-bits wide** (64-bit payload + 8-bit inline ECC). AXI bursts are serialized into DDR4 burst length 8 (BL8) transfers.
*   **Address Mapping:** Translates the physical AXI address into a `[Row : Bank Group : Bank : Column]` format to maximize spatial locality and open-page hits.
*   **FSM - JEDEC Initialization:** `STATE_POWERUP` -> `STATE_RESET_WAIT` (500us) -> `STATE_CKE_HIGH` -> `STATE_ZQ_CALIBRATION` -> `STATE_MR_PROGRAM` (Mode Registers 0-6) -> `STATE_IDLE`.
*   **FSM - Command Scheduling:**
    *   `STATE_ACTIVATE`: Issue `ACT` command to open a specific Bank/Row.
    *   `STATE_READ_WRITE`: Issue `RD`/`WR` commands.
    *   `STATE_PRECHARGE`: Issue `PRE` to close the open row if a page-miss occurs.
    *   `STATE_REFRESH`: Periodically preempt all traffic to issue `REF` (Auto-Refresh) commands.

### 10.2 PCIe Gen4 Root Complex (`pcie_root_complex`)
The PCIe Root Complex bridges the internal NoC to external high-speed devices.
*   **Configuration:** Operates as a **x16 Gen4** lane configuration (16 GT/s per lane).
*   **Translation Logic:** Maps AXI4 MMIO reads/writes into PCIe Transaction Layer Packets (TLPs). A memory-mapped write on the AXI bus generates a MWr (Memory Write) TLP.
*   **SerDes Integration:** Connects the digital PCS (Physical Coding Sublayer) directly to the analog PMA (Physical Medium Attachment) via the standard PIPE interface.

### 10.3 Iterative Conductor / System Control Unit (`sys_ctrl_unit`)
The Iterative Conductor is the master brain of the SoC, orchestrating boot-up, resets, and dynamic power management.
*   **Reset Sequencing & Dual-PLLs:**
    1.  Hold the entire SoC in reset (`sys_rst_n = 0`).
    2.  Enable the primary compute PLL and DDR PHY PLL. Wait for `pll_locked` assertion.
    3.  Assert a 10-bit counter. **Wait exactly 1024 clock cycles.**
    4.  Lift the reset on the NoC routers (`noc_rst_n = 1`). Wait 100 cycles.
    5.  Lift the reset on the compute islands (RV64, GPU, NPU).
*   **Power Domain Management:** Uses dynamic clock gating (ICG cells) and power-gating headers to isolate blocks. If the NPU FIFO is empty for >10,000 cycles, the `sys_ctrl_unit` de-asserts `npu_pwr_en`, completely cutting leakage current to Block 6.

### 10.4 Clock Domain Crossing (CDC) & Top-Level Integration
The `soc_top.sv` module instantiates and wires all 280+ sub-modules.
*   **Asynchronous Interrupts:** External pins (e.g., `ext_intr_in`) are completely asynchronous. They are routed through a strict **2-flop synchronizer** (`sync_ff1` -> `sync_ff2`) driven by the core clock before entering the PLIC to prevent metastability.
*   **CDC Strategy:** The RV64 core and NoC operate synchronously at **100MHz**, while the DDR4 PHY operates at **50MHz** to match external board constraints. Standard Gray-coded dual-clock Asynchronous FIFOs are instantiated strictly at the boundary between the NoC (100MHz) and the DDR4 Memory Controller (50MHz) to safely bridge these discrete frequency domains.

### 10.5 Frozen Signal Interface Matrix (External Pads & Top Wrapper)

*(All sequential modules internally use localized `BUFG` clock buffers)*

### ddr4_mem_ctrl.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset (1.6 GHz Domain) |
| `axi_req_val` | input | 1 | NoC Request |
| `axi_req_addr`| input | 64 | NoC Physical Address |
| `axi_wdata` | input | 256 | 256-bit NoC Write Data |
| `dfi_address` | output | 17 | DFI Row/Col Address to PHY |
| `dfi_bank` | output | 2 | DFI Bank Address |
| `dfi_cas_n`, `ras_n`, `we_n`| output| 1 | DFI Command Pins |
| `dfi_wrdata` | output | 72 | 64-bit Data + 8-bit ECC to PHY |

### pcie_root_complex.sv
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `clk`, `rst_n` | input | 1 | Clock / Reset |
| `axi_araddr`, `awaddr`| input | 64 | AXI Address |
| `pipe_tx_data`| output| 512 | 32-bit x 16-lanes to SerDes |
| `pipe_rx_data`| input | 512 | Data from SerDes |
| `pipe_tx_elecidle`| output| 16 | SerDes control |

### sys_ctrl_unit.sv (Iterative Conductor)
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `osc_clk_in` | input | 1 | 50MHz external oscillator |
| `ext_rst_n` | input | 1 | External board reset button |
| `pll_locked` | input | 1 | Dual-PLL lock status |
| `noc_rst_n` | output | 1 | Synchronized NoC Reset (Delayed 1024 cycles) |
| `core_rst_n` | output | 1 | Synchronized Core Reset |
| `npu_pwr_en` | output | 1 | Power-gate enable for NPU |
| `gpu_pwr_en` | output | 1 | Power-gate enable for GPU |

### soc_top.sv (Absolute Top-Level PADs)
| Port | Direction | Width | Description |
| :--- | :--- | :--- | :--- |
| `ext_osc_clk` | input | 1 | External Reference Clock |
| `ext_rst_n` | input | 1 | External Reset Button |
| `ext_intr_in` | input | 1 | Asynchronous External Interrupt |
| `ddr4_ck_p`, `ck_n` | output | 1 | DDR4 Differential Clock |
| `ddr4_a` | output | 17 | DDR4 Physical Address Bus |
| `ddr4_ba` | output | 2 | DDR4 Bank Address |
| `ddr4_bg` | output | 2 | DDR4 Bank Group |
| `ddr4_dq` | inout | 72 | DDR4 64-bit Data + 8-bit ECC Pad |
| `ddr4_dqs_p`, `dqs_n`| inout| 9 | DDR4 Differential Data Strobes |
| `pcie_tx_p`, `tx_n` | output | 16 | PCIe Gen4 x16 Transmit Lanes |
| `pcie_rx_p`, `rx_n` | input | 16 | PCIe Gen4 x16 Receive Lanes |
| `pcie_refclk_p`, `n`| input | 1 | PCIe Differential Reference Clock |
| `uart_tx_pad` | output | 1 | Physical UART TX Pad |
| `uart_rx_pad` | input | 1 | Physical UART RX Pad |
| `i2c_sda_pad`, `scl_pad`| inout| 1 | I2C Peripheral Pads |
| `spi_mosi`, `miso`, `clk`, `cs`| inout| 1,1,1,4| SPI Peripheral Pads |

*(The `soc_top.sv` module instantiates `sys_ctrl_unit`, `rv64_core_top`, `npu_top`, `gpu_top`, `vid_codec_top`, `noc_router`, `ddr4_mem_ctrl`, and `pcie_root_complex`, tying all internal `axi_*` buses and global `clk`/`rst_n` trees together).*


