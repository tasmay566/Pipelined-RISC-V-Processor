# Pipelined RISC-V Processor in Verilog

## Project Overview
This project features a fully pipelined, custom single-cycle RISC-V processor implemented in Verilog. Optimized for high-performance execution, the architecture incorporates data hazard forwarding, branch prediction flushes, and is structurally optimized for synthesis using Intel Quartus Prime.

By migrating from a standard single-cycle architecture to a 5-stage pipeline, this implementation ensures efficient instruction throughput while maintaining data integrity through custom hardware units designed to resolve control and data hazards.

## Architectural Details & Pipelining
The core of the processor is built upon a standard 5-stage pipeline: Instruction Fetch (IF), Instruction Decode (ID), Execute (EX), Memory (MEM), and Write Back (WB). 

* **Pipeline Registers:** Four dedicated pipeline registers (`IF_ID`, `ID_EX`, `EX_MEM`, `MEM_WB`) handle the non-blocking assignments of signals and data across stages.
* **Top-Level Integration:** All components are instantiated within the top-level module `PipelinedCPU.v`. 
* **Datapath Modifications:** 
  * The register file's write ports (`regWrite`, `writeReg`, and `writeData`) are strictly wired to the outputs of the `MEM_WB` register to prevent instructions in later stages from corrupting the destination registers of newly decoded instructions.
  * The Program Counter (PC) is propagated down through all pipeline registers to the WB stage to accurately calculate the `PC + 4` return address.

## Hazard Management
To handle structural, data, and control hazards without compromising performance, the processor features dedicated forwarding and hazard detection units.

### 1. Forwarding Unit (Data Hazards)
A combinational logic block resolves `EX` and `MEM` data hazards dynamically.
* Generates two 2-bit control signals (`forwardA` and `forwardB`) that control 3-input multiplexers located immediately before the ALU.
* Allows the processor to route data from the `EX/MEM` or `MEM/WB` registers directly into the ALU, bypassing the register file to resolve dependencies instantly.

### 2. Hazard Detection Unit (Load-Use & Control Hazards)
Evaluates three specific operational states in priority order: Load-use data hazard, Control hazard (branch taken), and Normal sequential execution.
* **Load-Use Stalls:** If a load-use hazard is detected, the unit stalls the pipeline for one clock cycle by freezing the PC (`pcWrite = 0`), preserving the `IF/ID` register (`if_id_write = 0`), and injecting a harmless NOP into the execute stage by forcing control signals to zero.
* **Early Branch Resolution:** The branch target adder and a dedicated comparator are moved to the ID stage to resolve branches early.
* **Branch Flushing:** If a control instruction (`beq`, `bne`, `blt`, `bge`, `jal`, or `jalr`) is taken, the `Branch_Taken` signal asserts high, and the hazard unit flushes the `IF/ID` register (`if_id_flush = 1`) to discard incorrectly fetched instructions.

## Simulation & Verification
The processor was extensively verified against multiple RISC-V assembly programs designed to trigger ex-hazards, mem-hazards, load-use stalls, and branch flushes simultaneously.

* **Register State Verification:** Steady-state final values of all temporary registers perfectly matched expected programmatic outcomes.
* **Waveform Analysis:** Confirmed accurate pipeline propagation (staircase PC values), verified that `pcWrite`, `if_id_write`, and `control_mux_sel` dropped correctly during load-use stalls, and validated that `forwardA/B` dynamically routed corrected data.

