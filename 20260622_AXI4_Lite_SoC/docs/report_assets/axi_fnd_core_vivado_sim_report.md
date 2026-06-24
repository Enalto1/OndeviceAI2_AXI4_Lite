# axi_fnd_core Vivado Simulation Report

## Run Metadata

| Item | Value |
| --- | --- |
| Report generated | 2026-06-22 15:12:49 +09:00 |
| Simulation target | `axi_fnd_core` |
| Tool requirement | Vivado 2020.2 / xsim |
| Vivado executable used | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat` |
| Vivado version | Vivado v2020.2 (64-bit), SW Build 3064766, IP Build 3064653 |
| Exact command | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_fnd_core/run_axi_fnd_core_sim.tcl` |
| Vivado actually run by Codex | Yes |
| Result | PASS |

## Result Summary

The Prompt 6 run completed successfully in Vivado 2020.2/xsim.

Result file:

```text
sim/vivado/axi_fnd_core/axi_fnd_core_sim_result.txt
```

Result file contents:

```text
PASS tests_passed=16 errors=0
```

Console PASS marker:

```text
[TB PASS] axi_fnd_core directed tests passed (16 tests)
```

## Test Results

| Test | Status |
| --- | --- |
| Reset behavior | PASS |
| CONTROL enable/disable | PASS |
| TIMER_VALUE write/read | PASS |
| SENSOR_VALUE write/read | PASS |
| Timer low display mode | PASS |
| Timer high display mode | PASS |
| Distance display mode | PASS |
| DHT humidity display mode | PASS |
| DHT temperature display mode | PASS |
| FND_OUTPUT readback | PASS |
| WSTRB behavior on CONTROL | PASS |
| WSTRB behavior on TIMER_VALUE | PASS |
| WSTRB behavior on SENSOR_VALUE | PASS |
| VERSION read and RO protection | PASS |
| FND_OUTPUT RO protection | PASS |
| Reserved offsets | PASS |

## Logs

Preserved logs:

```text
sim/vivado/axi_fnd_core/logs/axi_fnd_core_sim_20260622_151016_vivado.log
sim/vivado/axi_fnd_core/logs/axi_fnd_core_sim_20260622_151016_xsim.log
```

Vivado also generated project-root log/journal files during the run:

```text
vivado.log
vivado.jou
```

## Warnings Or Errors

No compile, elaboration, or simulation errors were observed in the passing run.

No active Vivado/xsim warnings were found in the preserved logs. The text `WARNING` appears only inside a commented Vivado-generated Tcl line for optional waveform setup, not as an emitted warning.

## Files Compiled

RTL:

- `rtl_work/axi_peripherals/axi_fnd_core/hdl/axi_fnd_core.v`
- `axi_project_unique_sources/sources/fnd_controller.v`

Testbench:

- `sim/vivado/axi_fnd_core/tb_axi_fnd_core.sv`

## Simulation-Specific Settings

The testbench instantiates:

```systemverilog
axi_fnd_core #(
    .FND_DIV_COUNT(8),
    .FND_DOT_THRESHOLD(2)
) dut (...);
```

These overrides are used only for faster simulation scan activity. The production RTL defaults remain unchanged.

## Fixes Made

No RTL, testbench, or Tcl fixes were required after the first Prompt 6 Vivado 2020.2 run. The simulation passed on the initial run.

The reference `fnd_controller.v` remained unchanged.

## Next Step Recommendation

Proceed to Prompt 7: `axi_timer_core` specification.
## Post-Migration Validation

Prompt 7.5 moved the project into the canonical project root and reran this simulation.

| Item | Value |
| --- | --- |
| Canonical project root | `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC` |
| Command used | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_fnd_core/run_axi_fnd_core_sim.tcl` |
| Run directory | `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC` |
| Result | PASS |
| Result file | `sim/vivado/axi_fnd_core/axi_fnd_core_sim_result.txt` |
| Result file contents | `PASS tests_passed=16 errors=0` |
| Vivado log copy | `sim/vivado/axi_fnd_core/logs/axi_fnd_core_sim_20260622_160552_vivado.log` |
| XSim log copy | `sim/vivado/axi_fnd_core/logs/axi_fnd_core_sim_20260622_160552_xsim.log` |
| RTL changed | No |

Post-migration warnings/errors:

- No compile, elaboration, or simulation errors were observed.
- No active Vivado/xsim warning lines were found in the preserved post-migration FND logs.
- Vivado emitted `INFO: [ProjectBase 1-489]` about Windows path length. This is informational and did not affect the passing run.