# axi_gpio_core Vivado Simulation Report

## Run Metadata

| Item | Value |
| --- | --- |
| Report generated | 2026-06-22 14:10:32 +09:00 |
| Simulation target | `axi_gpio_core` |
| Tool requirement | Vivado 2020.2 / xsim |
| Vivado executable used | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat` |
| Vivado version | Vivado v2020.2 (64-bit), SW Build 3064766, IP Build 3064653 |
| Exact command | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_gpio_core/run_axi_gpio_core_sim.tcl` |
| Vivado actually run by Codex | Yes |
| Result | PASS |

## Result Summary

The final Prompt 3.6 run completed successfully in Vivado 2020.2/xsim.

Result file:

```text
sim/vivado/axi_gpio_core/axi_gpio_core_sim_result.txt
```

Result file contents:

```text
PASS tests_passed=12 errors=0
```

Console PASS marker:

```text
[TB PASS] axi_gpio_core directed tests passed (12 tests)
```

## Test Results

| Test | Status |
| --- | --- |
| Reset behavior | PASS |
| `GPIO_OUT` write/read | PASS |
| `WSTRB` behavior on `GPIO_OUT` | PASS |
| `GPIO_SET` | PASS |
| `GPIO_CLR` | PASS |
| `GPIO_TOGGLE` | PASS |
| `GPIO_IN` switch and raw button synchronization | PASS |
| Button debounce level and edge flag | PASS |
| `BTN_EDGE_CLR` | PASS |
| Reserved offsets | PASS |
| Read-only write protection | PASS |
| `WSTRB` on command registers | PASS |

## Logs

Preserved logs:

```text
sim/vivado/axi_gpio_core/logs/axi_gpio_core_sim_20260622_140733_vivado.log
sim/vivado/axi_gpio_core/logs/axi_gpio_core_sim_20260622_140733_xsim.log
```

Vivado also generated the active project-root log/journal files during the run:

```text
vivado.log
vivado.jou
```

## Warnings Or Errors

No compile, elaboration, or simulation errors remain in the passing run.

Warnings observed in the passing run:

- `XSIM 43-3373`: `$value$plusargs` is used through a void cast in the testbench; Vivado reports that the system function should have an explicit left-hand side. This warning did not affect result-file creation or simulation behavior.
- Vivado reported that the SystemVerilog dynamic `string` object `result_file` was not traceable for waveform viewing. This is a waveform tracing limitation and did not affect the simulation checks.

## Fixes Made In Prompt 3.6

Tcl/environment fixes:

- Changed `run_axi_gpio_core_sim.tcl` from an in-memory Vivado project to an on-disk temporary project under `sim/vivado/axi_gpio_core/vivado_work/`, because Vivado 2020.2 rejected `launch_simulation` from the in-memory project.
- Changed result-file plusarg passing from raw `+RESULT_FILE=...` to XSim-compatible `-testplusarg RESULT_FILE=...` through `set_property -dict`.
- Removed the duplicate Tcl `run all` after `launch_simulation`, because `xsim.simulate.runtime all` already runs the testbench and the extra command left Vivado/xsim alive after completion.

Testbench fix:

- Updated the AXI write task to hold `AWVALID` and `WVALID` for one additional clock after observing the registered `AWREADY/WREADY` response. The prior task released valid too early for the Xilinx-style registered AXI4-Lite template, causing false write timeouts and no write commits.

RTL fixes:

- None. The passing run did not require changes to `axi_gpio_core.v` or `button_debounce_level.v`.

## Earlier Prompt 3.6 Attempts

Before the final passing run, the simulation flow exposed tool/testbench issues:

1. `launch_simulation` failed from the in-memory project with `No open project`.
2. Raw `+RESULT_FILE=...` plusarg syntax was rejected by XSim as a positional option.
3. After the plusarg fix, the testbench produced write timeout failures because the AXI write task deasserted valid too early.

After the Tcl and testbench fixes above, the final Vivado 2020.2 run passed all directed GPIO tests.

## Next Step Recommendation

Proceed to Prompt 4: `axi_fnd_core` specification.
## Post-Migration Validation

Prompt 7.5 moved the project into the canonical project root and reran this simulation.

| Item | Value |
| --- | --- |
| Canonical project root | `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC` |
| Command used | `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_gpio_core/run_axi_gpio_core_sim.tcl` |
| Run directory | `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC` |
| Result | PASS |
| Result file | `sim/vivado/axi_gpio_core/axi_gpio_core_sim_result.txt` |
| Result file contents | `PASS tests_passed=12 errors=0` |
| Vivado log copy | `sim/vivado/axi_gpio_core/logs/axi_gpio_core_sim_20260622_160516_vivado.log` |
| XSim log copy | `sim/vivado/axi_gpio_core/logs/axi_gpio_core_sim_20260622_160516_xsim.log` |
| RTL changed | No |

Post-migration warnings/errors:

- No compile, elaboration, or simulation errors were observed.
- The same known GPIO warnings remain: XSim reports `$value$plusargs` is used without an explicit left-hand side in the testbench, and the dynamic SystemVerilog `string` object `result_file` is not traceable for waveform viewing.
- Vivado emitted `INFO: [ProjectBase 1-489]` about Windows path length. This is informational and did not affect the passing run.