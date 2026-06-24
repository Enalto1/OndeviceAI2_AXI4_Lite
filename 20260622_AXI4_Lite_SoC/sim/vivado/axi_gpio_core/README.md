# axi_gpio_core Vivado Simulation

## Purpose

This folder contains a focused Vivado 2020.2 behavioral simulation for `axi_gpio_core`.

The simulation checks the AXI4-Lite register behavior, LED output register behavior, input synchronization, adapted button debounce level/pulse behavior, reserved register behavior, and WSTRB handling.

## Files Compiled

RTL:

- `../../../rtl_work/axi_peripherals/axi_gpio_core/hdl/axi_gpio_core.v`
- `../../../rtl_work/legacy_adapted/button_debounce_level/button_debounce_level.v`

Testbench:

- `tb_axi_gpio_core.sv`

Script:

- `run_axi_gpio_core_sim.tcl`

## How To Run

From the canonical project root:

```text
cd D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_gpio_core/run_axi_gpio_core_sim.tcl
```

The script derives the project root from its own location, creates/updates an on-disk Vivado work project under `sim/vivado/axi_gpio_core/vivado_work/`, adds the RTL and testbench, sets `tb_axi_gpio_core` as the simulation top, launches behavioral xsim, preserves logs under `sim/vivado/axi_gpio_core/logs/`, and exits nonzero if the testbench result file reports failure.

## Expected Output

Expected passing console markers:

```text
[PASS] Test 1: Reset behavior
...
[PASS] Test 12: WSTRB on command registers
[TB PASS] axi_gpio_core directed tests passed
```

The testbench writes:

```text
sim/vivado/axi_gpio_core/axi_gpio_core_sim_result.txt
```

Expected passing contents:

```text
PASS tests_passed=12 errors=0
```

## Debounce Runtime Note

`button_debounce_level` preserves the reference debounce timing:

```text
F_COUNT = 100_000_000 / 1000
```

At a 100 MHz simulation clock, each debounce sample interval is about 1 ms, and the 8-sample history requires roughly 8 ms of stable input. The directed debounce tests therefore wait about 10 ms for each settle phase. This makes the simulation longer than a pure register test, but it verifies the real configured debounce behavior.

## Test List

1. Reset behavior
2. `GPIO_OUT` write/read
3. `WSTRB` behavior on `GPIO_OUT`
4. `GPIO_SET`
5. `GPIO_CLR`
6. `GPIO_TOGGLE`
7. `GPIO_IN` switch and raw button synchronization
8. Button debounce level and edge flag
9. `BTN_EDGE_CLR`
10. Reserved offsets
11. Read-only write protection
12. `WSTRB` on command registers

## Current Status

Prompt 7.5 path migration validated this simulation from the canonical project root using Vivado 2020.2.