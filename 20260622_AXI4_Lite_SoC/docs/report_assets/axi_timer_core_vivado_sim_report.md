# axi_timer_core Vivado Simulation Report

## Summary

`axi_timer_core` was simulated with Vivado 2020.2/xsim from the canonical project root.

Final result:

```text
PASS tests_passed=19 errors=0
```

Console marker:

```text
[TB PASS] axi_timer_core directed tests passed (19 tests)
```

## Vivado

| Item | Value |
| --- | --- |
| Vivado executable | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat` |
| Vivado version | Vivado v2020.2, SW Build 3064766, IP Build 3064653 |
| Exact command | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_timer_core/run_axi_timer_core_sim.tcl` |
| Run directory | `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC` |
| Simulation ran | Yes |
| Pass/fail | PASS |

## Files Compiled

Reference Timer RTL:

- `axi_project_unique_sources/sources/stopwatch_datapath.v`
- `axi_project_unique_sources/sources/watch_datapath.v`
- `axi_project_unique_sources/sources/watch_fnd_adapter.v`

Wrapper RTL:

- `rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v`

Testbench:

- `sim/vivado/axi_timer_core/tb_axi_timer_core.sv`

Not compiled:

- `fnd_controller.v`
- `axi_fnd_core.v`
- `top_control_unit.v`
- `top_stopwatch_watch.v`
- GPIO, Sensor, SPI, I2C, UVM, MicroBlaze software, or block-design files

## Fast Tick Strategy

The testbench used simulation-only hierarchical parameter overrides:

```verilog
defparam dut.u_stopwatch_datapath.U_TICK_GEN_100HZ.F_COUNT = 8;
defparam dut.u_watch_datapath.uTICK_GEN_100HZ.F_COUNT = 8;
```

No reference Timer RTL file was modified, and no adapted Timer copy was created.

## Directed Test Results

| Test | Status |
| --- | --- |
| Test 1: Reset behavior | PASS |
| Test 2: CONTROL write/read | PASS |
| Test 3: CONTROL WSTRB behavior | PASS |
| Test 4: COMMAND read-zero behavior | PASS |
| Test 5: Stopwatch clear pulse | PASS |
| Test 6: Stopwatch run/stop up-count behavior | PASS |
| Test 7: Stopwatch down-count behavior | PASS |
| Test 8: Watch set mode control | PASS |
| Test 9: Watch edit ignored when set mode = 0 | PASS |
| Test 10: Watch edit up, hour target | PASS |
| Test 11: Watch edit down, hour target | PASS |
| Test 12: Watch edit-up priority over edit-down | PASS |
| Test 13: Watch minute/second digit target selection | PASS |
| Test 14: WATCH_VALUE adapter readback | PASS |
| Test 15: VERSION read and RO protection | PASS |
| Test 16: Read-only write protection | PASS |
| Test 17: Reserved offset behavior | PASS |
| Test 18: COMMAND WSTRB behavior | PASS |
| Test 19: Timer/FND decoupling compile check | PASS |

## Result File

Path:

```text
sim/vivado/axi_timer_core/axi_timer_core_sim_result.txt
```

Contents:

```text
PASS tests_passed=19 errors=0
```

## Logs

Final passing run:

- `sim/vivado/axi_timer_core/logs/axi_timer_core_sim_20260622_164059_vivado.log`
- `sim/vivado/axi_timer_core/logs/axi_timer_core_sim_20260622_164059_xsim.log`

Earlier debug runs retained:

- `sim/vivado/axi_timer_core/logs/axi_timer_core_sim_20260622_163828_vivado.log`
- `sim/vivado/axi_timer_core/logs/axi_timer_core_sim_20260622_163828_xsim.log`
- `sim/vivado/axi_timer_core/logs/axi_timer_core_sim_20260622_163913_vivado.log`
- `sim/vivado/axi_timer_core/logs/axi_timer_core_sim_20260622_163913_xsim.log`

## Warnings And Errors

Final passing run:

- No `ERROR`, `CRITICAL WARNING`, `WARNING`, `[CHECK FAIL]`, or `[TB FAIL]` lines were found in the final copied Vivado/xsim logs.
- Vivado emitted an informational path-length note because the on-disk simulation project path is longer than 80 characters.

Earlier debug findings:

- First run failed during testbench compile because `packed` was used as a variable name; Vivado 2020.2 treats `packed` as a SystemVerilog keyword.
- Second run compiled and simulated but had two stopwatch testbench check failures caused by stopping/clearing immediately around the accelerated internal stopwatch tick phase. The testbench was updated to align those checks after the internal fast tick returned low.

## Fixes Made

Testbench-only fixes:

1. Renamed local variable `packed` to `watch_packed`.
2. Added `wait_stopwatch_tick_then_low()` and used it before stopwatch stop/clear checks so the directed tests avoid the reused stopwatch tick generator's tick-high phase.

RTL changes:

- `rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v` was not modified during simulation debugging.
- Reference Timer RTL was not modified.
- No adapted Timer copy was created.

## Reference Hashes

Reference Timer RTL hashes after simulation:

```text
A4C721EB0B509C7DBA1FDD2D626840085C7F860BA1745A1F6890B6BE040CB942  axi_project_unique_sources/sources/stopwatch_datapath.v
CAC4C173F3FE96DC80F3B1123B8E066E9060A94E6556B2B04167C1072AF382B5  axi_project_unique_sources/sources/watch_datapath.v
61ADDCDBDE445DAB598D015839E21D136F5F44EC7A77914FC305BCA6D392B947  axi_project_unique_sources/sources/watch_fnd_adapter.v
```

## Timer/FND Decoupling

The Timer simulation passed without compiling `fnd_controller.v` or `axi_fnd_core.v`. `axi_timer_core` remains decoupled from FND hardware.

## Next Step

Prompt 10: `axi_sensor_core` specification.
