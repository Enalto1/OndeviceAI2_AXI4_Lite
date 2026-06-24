# axi_fnd_core Vivado Simulation

## Purpose

This folder contains a focused Vivado 2020.2 behavioral simulation for `axi_fnd_core`.

The simulation checks the AXI4-Lite register behavior, FND enable/disable gating, output readback, WSTRB behavior, read-only and reserved register protection, and representative scan activity from the reused `fnd_controller.v`.

## Files Compiled

RTL:

- `../../../rtl_work/axi_peripherals/axi_fnd_core/hdl/axi_fnd_core.v`
- `../../../axi_project_unique_sources/sources/fnd_controller.v`

Testbench:

- `tb_axi_fnd_core.sv`

Script:

- `run_axi_fnd_core_sim.tcl`

## How To Run

From the canonical project root:

```text
cd D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_fnd_core/run_axi_fnd_core_sim.tcl
```

The script derives the project root from its own location, creates/updates an on-disk Vivado work project under `sim/vivado/axi_fnd_core/vivado_work/`, launches behavioral xsim, runs until the testbench finishes, preserves logs under `sim/vivado/axi_fnd_core/logs/`, and exits nonzero if the result file reports failure.

## Simulation Parameters

The testbench instantiates:

```systemverilog
axi_fnd_core #(
    .FND_DIV_COUNT(8),
    .FND_DOT_THRESHOLD(2)
) dut (...);
```

The production RTL defaults remain unchanged. The small divider and dot threshold are used only to observe FND scan activity quickly in simulation.

## Expected Output

Expected passing console markers:

```text
[PASS] Test 1: Reset behavior
...
[PASS] Test 16: Reserved offsets
[TB PASS] axi_fnd_core directed tests passed
```

The testbench writes:

```text
sim/vivado/axi_fnd_core/axi_fnd_core_sim_result.txt
```

Expected passing contents:

```text
PASS tests_passed=16 errors=0
```

## Reuse Note

`fnd_controller.v` is compiled as a reference RTL dependency and remains unchanged. The testbench verifies wrapper-level behavior without copying or modifying the reference FND controller.

## Current Status

Prompt 7.5 path migration validated this simulation from the canonical project root using Vivado 2020.2.