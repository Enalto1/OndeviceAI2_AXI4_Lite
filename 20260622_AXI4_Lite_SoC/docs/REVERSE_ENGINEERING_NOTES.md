# Reverse Engineering Notes

Canonical project root after Prompt 7.5: D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC. The parent directory D:\OndeviceAI2_AXI4_Lite remains the Git root and may contain other projects.

The completed project should be easy to inspect, explain, debug, and present. These notes define how a future reviewer should reconstruct the design from documentation, source, simulations, and board-demo evidence.

## Recommended Review Order

1. Start with `docs/PROJECT_PLAN.md` for the overall goal, board target, peripheral order, and development phases.
2. Read `docs/SOURCE_AUDIT.md` to understand the original reference RTL files and which modules are reusable leaf cores.
3. Read `docs/REUSE_STRATEGY.md` to understand why wrappers should instantiate existing RTL instead of rewriting it.
4. Read the relevant peripheral spec, such as `docs/specs/axi_gpio_core_SPEC.md`, before opening wrapper RTL.
5. Open the wrapper RTL under `rtl_work/axi_peripherals/<peripheral>/hdl/` and compare its register map to the spec.
6. Trace each reused legacy module instance back to `axi_project_unique_sources/sources`.
7. Review the simple Vivado simulation for reset, AXI read/write, pulse behavior, and reused-core connections.
8. Review MicroBlaze integration and board-demo notes to connect simulation behavior to hardware behavior.
9. Review the separate UVM verification artifacts later, after all custom peripherals are implemented and basic Vivado simulations have passed.
10. Use draw.io and WaveDrom sources to explain architecture and timing without relying on screenshots alone.

## Source Reuse Trace Method

| Question | Expected evidence |
| --- | --- |
| Which legacy RTL module is reused? | Instance name in wrapper plus entry in `SOURCE_AUDIT.md` and `TRACEABILITY_MATRIX.md`. |
| Was the legacy source modified? | It should point to the read-only reference file. If modified, a copied/renamed file under `rtl_work/legacy_adapted` must be documented. |
| What AXI registers control the module? | Peripheral spec register map and wrapper comments. |
| Which signals cross the wrapper/core boundary? | Wrapper block diagram, signal mapping table, and RTL instance connections. |
| How was the behavior verified? | Vivado simulation summary, later UVM scoreboard/coverage summary, and board-demo notes. |

## AXI Wrapper Review Checklist

1. AXI template handshake logic remains recognizable and minimally changed.
2. `s00_axi_aresetn` is converted cleanly to the active-high reset expected by legacy RTL.
3. Address decode matches the documented register map.
4. Writable fields are separated from read-only status/data fields.
5. Write-one-pulse bits produce a one-clock pulse and do not remain stuck high.
6. Level configuration fields hold their values until reset or software rewrite.
7. Reused RTL core inputs are driven from documented register fields or pulses.
8. Reused RTL core outputs are exposed through documented status/data registers.
9. External board pins are named clearly and match board constraints.
10. Comments and docs explain any adapted legacy source or non-obvious behavior.

## Legacy Architecture Comparison

The old design uses a hardware UART/ASCII path:

```text
uart.v
  -> fifo.v
  -> ASCII_decoder.v
  -> virtual switches/buttons/status requests
  -> system_control_unit.v and timer/sensor/display modules
  -> ASCII_sender.v
  -> fifo.v
  -> uart.v
```

The new MicroBlaze design should move command parsing and status formatting into software:

```text
AXI UART Lite
  -> MicroBlaze software parser
  -> AXI register writes/reads
  -> custom AXI4-Lite wrappers
  -> reused legacy leaf modules
```

A future reviewer should confirm that the initial system follows the second architecture and does not accidentally reuse the legacy ASCII parser as the main console path.

## Diagram And Register Map Support

Useful reverse-engineering assets should include:

- Overall MicroBlaze AXI SoC draw.io diagram.
- AXI address map diagram and markdown table.
- Per-peripheral wrapper draw.io diagrams.
- Register maps with offset, name, access type, reset value, bit fields, and software behavior.
- Signal mapping tables from AXI registers to reused RTL ports.
- WaveDrom diagrams for AXI read/write and one-clock command pulses.
- Protocol timing diagrams for sensors, SPI, and I2C.
- RTL hierarchy summaries showing wrappers and reused modules.

## Verification Review Support

Each future verification folder should make these points clear:

- What behavior is checked.
- Which register offsets and bit fields are exercised.
- Which reused RTL outputs are observed.
- What pass/fail condition ends the test.
- How to run the test in Vivado 2020.2 or VCS/Verdi.
- Whether FSDB dumping is optional and how to enable it.

UVM-specific verification review is deferred until all custom AXI4-Lite peripherals are implemented and each one has passed basic Vivado simulation. The later UVM campaign should follow the RAM UVM split reference structure, with common AXI-Lite components added only where they reduce duplication.

## Board Demo Review Support

Each board-demo note should record the board name, clock assumption, Vivado version, build identifier, MicroBlaze command set, UART transcript, external wiring, observed result, and limitations.

## Step 0 Starting Points

After Step 0, the best starting points are:

- `docs/SOURCE_AUDIT.md` for source inventory.
- `docs/REUSE_STRATEGY.md` for what to wrap and what to leave as reference-only.
- `docs/TRACEABILITY_MATRIX.md` for planned artifacts and future status tracking.
- `docs/UVM_REFERENCE_USAGE.md` for the later UVM reference structure.
- `docs/DIAGRAM_ASSET_PLAN.md` for diagram and WaveDrom asset filenames.

## Non-Negotiable Traceability Rules

- Do not hide source reuse behind undocumented wrapper logic.
- Do not rewrite stable reference modules without documenting why.
- Do not let RTL, register maps, diagrams, and software command names drift apart.
- Do not treat passing board behavior as enough; keep simulation and later UVM evidence linked.
- Do not create black-box project assets that cannot be reconstructed from source and docs.

## Prompt 1 Reverse-Engineering Update

After Prompt 1, a reviewer should start GPIO-specific reconstruction here:

1. `docs/specs/AXI_ADDRESS_MAP.md` for the global base addresses.
2. `docs/specs/AXI_REGISTER_CONVENTIONS.md` for shared AXI register behavior.
3. `docs/specs/axi_gpio_core_SPEC.md` for the GPIO register map and behavior.
4. `docs/rtl_views/axi_gpio_core_reuse_notes.md` for the actual `button_debounce.v` inspection result.
5. `docs/diagrams/axi_gpio_core_wrapper.drawio` for the wrapper concept.
6. `docs/wavedrom/axi_gpio_write_read.json` and `docs/wavedrom/axi_gpio_button_edge.json` for intended timing behavior.

Important GPIO traceability note:

- `button_debounce.v` can be reused for button edge pulse generation.
- It cannot directly provide `GPIO_IN[20:16] btn_debounced` stable level readback because its `o_btn` is a pulse.
- The future GPIO RTL step must document whether it adds wrapper-side debounced level logic or creates a renamed adapted copy of the debounce module.
- The original reference RTL remains unchanged.

## Prompt 2 Reverse-Engineering Update

Prompt 2 adds the first implementation RTL while leaving the reference source archive unchanged.

Start GPIO RTL inspection here:

1. `docs/specs/axi_gpio_core_SPEC.md` for the expected register map.
2. `rtl_work/axi_peripherals/axi_gpio_core/hdl/axi_gpio_core.v` for the AXI4-Lite wrapper implementation.
3. `rtl_work/legacy_adapted/button_debounce_level/button_debounce_level.v` for the adapted debounce helper.
4. `docs/rtl_views/axi_gpio_core_hierarchy.md` for the hierarchy and signal mapping.
5. `docs/rtl_views/axi_gpio_core_reuse_notes.md` for the reason the adapted debounce copy exists.

Trace the debounce logic this way:

```text
reference button_debounce.v
  -> adapted button_debounce_level.v
  -> five explicit instances in axi_gpio_core.v
  -> GPIO_IN[20:16] debounced level readback
  -> BTN_EDGE[4:0] latched edge flags
```

Important implementation facts:

- The original `axi_project_unique_sources/sources/button_debounce.v` remains unchanged.
- `button_debounce_level.v` preserves the sampled debounce concept and exposes both level and pulse outputs.
- `axi_gpio_core.v` synchronizes `sw_i` and `btn_i` before AXI readback.
- `btn_raw_sync` feeds the adapted debounce helpers.
- Write-only command registers read as zero.
- Reserved local offsets `0x20` to `0x3C` read as zero and ignore writes.
- `VERSION` returns `32'h0001_0000`.
- Simulation, UVM, Vivado project generation, MicroBlaze software, and board demo are still pending.

## Prompt 3 Reverse-Engineering Update

Prompt 3 adds a focused Vivado behavioral simulation bundle for `axi_gpio_core`.

Simulation assets:

1. `sim/vivado/axi_gpio_core/tb_axi_gpio_core.sv`
2. `sim/vivado/axi_gpio_core/run_axi_gpio_core_sim.tcl`
3. `sim/vivado/axi_gpio_core/README.md`
4. `docs/report_assets/axi_gpio_core_vivado_sim_report.md`

Manual run command from project root:

```text
vivado -mode batch -source sim/vivado/axi_gpio_core/run_axi_gpio_core_sim.tcl
```

The testbench is directed, not UVM. It checks reset behavior, all GPIO registers, WSTRB behavior, input synchronization, real debounce timing, edge latch/clear behavior, read-only write protection, and reserved offset behavior.

When reverse-engineering a simulation failure:

1. Start from the failing `[CHECK FAIL]` line in the xsim transcript.
2. Compare the expected value to `docs/specs/axi_gpio_core_SPEC.md`.
3. Inspect the corresponding register behavior in `rtl_work/axi_peripherals/axi_gpio_core/hdl/axi_gpio_core.v`.
4. For button behavior, trace through `rtl_work/legacy_adapted/button_debounce_level/button_debounce_level.v`.
5. Update `docs/report_assets/axi_gpio_core_vivado_sim_report.md` with the result and any RTL fix.

## Prompt 3.5 Reverse-Engineering Update

Prompt 3.5 checked the tool environment and found only Vivado 2024.2 installed/on PATH. Because the project requires Vivado 2020.2, the GPIO simulation was not run and no pass/fail claim is made.

UVM is deferred until after all custom AXI4-Lite peripherals are implemented and each has completed basic Vivado simulation. Prompt 3.6 supersedes the pending GPIO simulation note: the GPIO Vivado 2020.2 simulation has now passed.
## Prompt 3.6 Reverse-Engineering Update

Prompt 3.6 ran the focused GPIO Vivado simulation with `D:\Xilinx\Vivado\2020.2\bin\vivado.bat`.

Final result:

```text
PASS tests_passed=12 errors=0
```

Useful review artifacts:

1. `sim/vivado/axi_gpio_core/axi_gpio_core_sim_result.txt`
2. `sim/vivado/axi_gpio_core/logs/axi_gpio_core_sim_20260622_140733_vivado.log`
3. `sim/vivado/axi_gpio_core/logs/axi_gpio_core_sim_20260622_140733_xsim.log`
4. `docs/report_assets/axi_gpio_core_vivado_sim_report.md`

The fixes made during Prompt 3.6 were simulation-flow and testbench fixes only. The GPIO RTL, adapted debounce RTL, and reference RTL directory remained unchanged.

UVM remains deferred until after all custom AXI4-Lite peripherals are implemented and have basic Vivado simulation results.

## Prompt 4 FND Reverse-Engineering Update

Prompt 4 adds the `axi_fnd_core` specification package. Start FND reconstruction here:

1. `docs/specs/axi_fnd_core_SPEC.md` for the register map, output gating, reset behavior, and external ports.
2. `docs/rtl_views/axi_fnd_core_reuse_notes.md` for the actual `fnd_controller.v` inspection.
3. `docs/specs/axi_fnd_core_SOFTWARE_COMMANDS.md` for planned MicroBlaze UART commands.
4. `docs/specs/axi_fnd_core_VERIFICATION_PLAN.md` for the future Vivado simulation checklist.
5. `docs/diagrams/axi_fnd_core_wrapper.drawio` for wrapper structure.
6. `docs/wavedrom/axi_fnd_register_update.json` and `docs/wavedrom/axi_fnd_enable_disable.json` for intended timing behavior.

Important FND traceability facts:

- The reference `axi_project_unique_sources/sources/fnd_controller.v` remains unchanged.
- `fnd_controller.v` is reusable as-is and should be instantiated by the future wrapper.
- The first FND wrapper is decoupled from timer and sensor hardware; MicroBlaze software will write display values into FND registers.
- `display_enable = 0` blanks the active-low Basys3 FND outputs with `fnd_com_o = 4'b1111` and `fnd_data_o = 8'hFF`.
- UVM remains deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.
## Prompt 5 FND RTL Reverse-Engineering Update

Prompt 5 implements the FND AXI wrapper here:

```text
rtl_work/axi_peripherals/axi_fnd_core/hdl/axi_fnd_core.v
```

Start RTL review with:

1. `docs/specs/axi_fnd_core_SPEC.md` for the intended register map.
2. `rtl_work/axi_peripherals/axi_fnd_core/hdl/axi_fnd_core.v` for the AXI wrapper.
3. `docs/rtl_views/axi_fnd_core_hierarchy.md` for the register-to-port mapping.
4. `docs/rtl_views/axi_fnd_core_reuse_notes.md` for the reference controller inspection.
5. `axi_project_unique_sources/sources/fnd_controller.v` for the unchanged scan and segment controller.

Trace the control/data path this way:

```text
AXI write
  -> CONTROL / TIMER_VALUE / SENSOR_VALUE
  -> u_fnd_controller inputs
  -> fnd_com_raw / fnd_data_raw
  -> display_enable output gating
  -> fnd_com_o / fnd_data_o
  -> FND_OUTPUT readback
```

Important implementation facts:

- `CONTROL[0]` gates the final outputs.
- `CONTROL[2:1]` drives `i_main_mode`.
- `CONTROL[3]` drives `i_display_sel`.
- `TIMER_VALUE[23:0]` drives `msec`, `sec`, `min`, and `hour`.
- `SENSOR_VALUE[24:0]` drives `distance`, `humidity`, and `temperature`.
- `FND_OUTPUT` reads final gated outputs, not raw controller outputs.
- `VERSION` returns `32'h0001_0000`.
- Reserved offsets read zero and ignore writes.
- The reference `fnd_controller.v` remains unchanged.
- FND Vivado simulation is still pending.
- UVM remains deferred until all custom AXI4-Lite peripherals are implemented and have basic Vivado simulation results.
## Prompt 6 FND Simulation Reverse-Engineering Update

Prompt 6 created and ran the focused FND Vivado simulation using:

```text
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_fnd_core/run_axi_fnd_core_sim.tcl
```

Final result:

```text
PASS tests_passed=16 errors=0
```

Useful review artifacts:

1. `sim/vivado/axi_fnd_core/tb_axi_fnd_core.sv`
2. `sim/vivado/axi_fnd_core/run_axi_fnd_core_sim.tcl`
3. `sim/vivado/axi_fnd_core/README.md`
4. `sim/vivado/axi_fnd_core/axi_fnd_core_sim_result.txt`
5. `sim/vivado/axi_fnd_core/logs/axi_fnd_core_sim_20260622_151016_vivado.log`
6. `sim/vivado/axi_fnd_core/logs/axi_fnd_core_sim_20260622_151016_xsim.log`
7. `docs/report_assets/axi_fnd_core_vivado_sim_report.md`

The simulation compiled `axi_fnd_core.v` and the unchanged reference `fnd_controller.v`. It used `FND_DIV_COUNT=8` and `FND_DOT_THRESHOLD=2` only in the testbench instance to observe scan behavior quickly.

No RTL, testbench, or Tcl fixes were needed after the first run. UVM remains deferred until all custom AXI4-Lite peripherals are implemented and have basic Vivado simulation results.
## Prompt 7 Timer Specification Reverse-Engineering Update

Prompt 7 adds the `axi_timer_core` specification package only. No RTL, testbench, simulation run, UVM environment, MicroBlaze software, or Vivado block design was created.

Start Timer reconstruction here:

1. `docs/AXI4_LITE_SOC_FILE_INDEX.md` for the project-owned file inventory and edit policies.
2. `docs/specs/axi_timer_core_SPEC.md` for the Timer register map, reset behavior, WSTRB rules, command pulses, and Timer/FND decoupling policy.
3. `docs/rtl_views/axi_timer_core_reuse_notes.md` for the inspected timer-related reference RTL.
4. `docs/specs/axi_timer_core_SOFTWARE_COMMANDS.md` for planned MicroBlaze UART commands.
5. `docs/specs/axi_timer_core_VERIFICATION_PLAN.md` for the future directed Vivado simulation checklist.
6. `docs/diagrams/axi_timer_core_wrapper.drawio` for wrapper structure.
7. `docs/wavedrom/axi_timer_control_command.json`, `docs/wavedrom/axi_timer_watch_edit.json`, and `docs/wavedrom/axi_timer_read_values.json` for intended timing behavior.

Important Timer traceability facts:

- `stopwatch_datapath.v`, `watch_datapath.v`, and `watch_fnd_adapter.v` are direct reuse candidates.
- `top_control_unit.v` is reference-only; AXI registers replace its legacy button/switch FSM.
- `top_stopwatch_watch.v` is reference-only; it must not be wrapped directly because it mixes debounce, control, datapaths, muxing, and FND output.
- The first Timer wrapper is decoupled from FND hardware. Software will later read Timer values and write `axi_fnd_core` display registers.
- `COMMAND` bits are specified as one-clock pulses, and watch edit pulses are ignored unless `watch_set_mode = 1`.
- Both timer datapaths use default 100 Hz tick generators with about 1,000,000 cycles per tick at 100 MHz. Any future simulation shortcut must use documented adapted copies, not reference RTL edits.
- UVM remains deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.
## Prompt 7.5 Physical Cleanup Reverse-Engineering Update

Prompt 7.5 moved project-owned folders under:

```text
D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC
```

Use `docs/AXI4_LITE_SOC_FILE_INDEX.md` as the project-root-relative inventory. Use Git-root `PROJECTS_INDEX.md` to distinguish this SoC project from unrelated root-level folders.

The GPIO and FND simulation Tcl scripts now derive the canonical project root from `[info script]`, so they can be launched from the new project root without hard-coded old-root paths.

Reference RTL contents remain unchanged. Timer RTL, Timer simulation, UVM, MicroBlaze software, and Vivado block design work remain not started.
Post-migration validation evidence:

- GPIO result: `sim/vivado/axi_gpio_core/axi_gpio_core_sim_result.txt` contains `PASS tests_passed=12 errors=0`.
- GPIO logs: `sim/vivado/axi_gpio_core/logs/axi_gpio_core_sim_20260622_160516_vivado.log` and `sim/vivado/axi_gpio_core/logs/axi_gpio_core_sim_20260622_160516_xsim.log`.
- FND result: `sim/vivado/axi_fnd_core/axi_fnd_core_sim_result.txt` contains `PASS tests_passed=16 errors=0`.
- FND logs: `sim/vivado/axi_fnd_core/logs/axi_fnd_core_sim_20260622_160552_vivado.log` and `sim/vivado/axi_fnd_core/logs/axi_fnd_core_sim_20260622_160552_xsim.log`.
## Prompt 8 Timer RTL Reverse-Engineering Update

Prompt 8 implements the Timer AXI wrapper here:

```text
rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v
```

Start Timer RTL review with:

1. `docs/specs/axi_timer_core_SPEC.md` for the intended register map and pulse behavior.
2. `rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v` for the AXI wrapper implementation.
3. `docs/rtl_views/axi_timer_core_hierarchy.md` for hierarchy and register-to-port mapping.
4. `docs/rtl_views/axi_timer_core_reuse_notes.md` for reference RTL inspection and Prompt 8 implementation decision.
5. `axi_project_unique_sources/sources/stopwatch_datapath.v`, `watch_datapath.v`, and `watch_fnd_adapter.v` for the unchanged reused leaf modules.

Trace the control path this way:

```text
AXI write to CONTROL
  -> control_reg[0] stopwatch_run
  -> control_reg[1] stopwatch_down
  -> control_reg[8] watch_set_mode
  -> control_reg[10:9] watch_time_sel
  -> control_reg[11] watch_digit_sel
  -> reused datapath inputs
```

Trace command pulses this way:

```text
AXI write to COMMAND
  -> COMMAND[0] + WSTRB[0] -> one-clock stopwatch_clear_pulse
  -> COMMAND[8] + WSTRB[1] + watch_set_mode -> one-clock watch_edit_cmd = 2'b01
  -> COMMAND[9] + WSTRB[1] + watch_set_mode -> one-clock watch_edit_cmd = 2'b10
```

If edit-up and edit-down are written together, edit-up has priority. If `watch_set_mode` is zero, watch edit commands are ignored.

Trace watch readback this way:

```text
u_watch_datapath raw split digits
  -> u_watch_fnd_adapter
  -> WATCH_VALUE packed hour/min/sec/msec
```

`axi_timer_core` remains decoupled from FND hardware: it does not instantiate `fnd_controller` or `axi_fnd_core`, and it has no FND output pins. MicroBlaze software will later read Timer values and write `axi_fnd_core` display registers.

Timer Vivado simulation is still pending. No simulation testbench, UVM environment, MicroBlaze software, or Vivado block design was created in Prompt 8.
## Prompt 9 Timer Simulation Reverse-Engineering Update

Prompt 9 created and ran the focused Timer Vivado simulation using:

```text
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_timer_core/run_axi_timer_core_sim.tcl
```

Final result:

```text
PASS tests_passed=19 errors=0
```

Useful review artifacts:

1. `sim/vivado/axi_timer_core/tb_axi_timer_core.sv`
2. `sim/vivado/axi_timer_core/run_axi_timer_core_sim.tcl`
3. `sim/vivado/axi_timer_core/README.md`
4. `sim/vivado/axi_timer_core/axi_timer_core_sim_result.txt`
5. `sim/vivado/axi_timer_core/logs/axi_timer_core_sim_20260622_164059_vivado.log`
6. `sim/vivado/axi_timer_core/logs/axi_timer_core_sim_20260622_164059_xsim.log`
7. `docs/report_assets/axi_timer_core_vivado_sim_report.md`

The simulation compiled `axi_timer_core.v` plus the unchanged reference Timer RTL files `stopwatch_datapath.v`, `watch_datapath.v`, and `watch_fnd_adapter.v`. It did not compile FND RTL, GPIO RTL, Sensor/SPI/I2C RTL, UVM files, MicroBlaze software, or Vivado block-design files.

The testbench used simulation-only `defparam` overrides to set both reused 100 Hz generators to `F_COUNT = 8`. No reference Timer RTL was modified and no adapted Timer copy was created.

Debug history:

- First run exposed a testbench-only SystemVerilog keyword issue: local variable `packed` was renamed to `watch_packed`.
- Second run exposed a deterministic testbench timing issue around the accelerated stopwatch tick. The testbench now waits for the internal fast tick to return low before stopwatch stop/clear checks.
- No `axi_timer_core.v` changes were required.

UVM remains deferred until all custom AXI4-Lite peripherals are implemented and have basic Vivado simulation results.

## Unattended Phase A Sensor Specification Reverse-Engineering Update

The Sensor specification package was created from direct inspection of:

1. `axi_project_unique_sources/sources/sr04.v`
2. `axi_project_unique_sources/sources/dht11.v`

Start Sensor reconstruction here:

1. `docs/specs/axi_sensor_core_SPEC.md` for the register map, external pins, WSTRB behavior, and command pulse policy.
2. `docs/rtl_views/axi_sensor_core_reuse_notes.md` for inspected source ports and reuse decisions.
3. `docs/specs/axi_sensor_core_VERIFICATION_PLAN.md` for the future directed Vivado simulation checklist.
4. `docs/specs/axi_sensor_core_SOFTWARE_COMMANDS.md` for planned MicroBlaze UART commands.
5. `docs/diagrams/axi_sensor_core_wrapper.drawio` and the Sensor WaveDrom files for architecture/timing intent.

Important facts:

- `sr04.v` top port `ultra_btn` is the SR04 start request; `distance[8:0]` and `trig` are exposed by the planned wrapper.
- `dht11.v` top port `dht_btn` is the DHT start request; `hm`, `tm`, and `led` are exposed by the planned wrapper.
- `dht11.led` is documented as the live valid/status signal.
- Full DHT11 protocol response modeling is deferred unless practical in the first basic simulation.
- Reference Sensor RTL remains unchanged.
- UVM, MicroBlaze software, and Vivado block design remain uncreated.

## Unattended Phase B Sensor RTL Reverse-Engineering Update

Phase B implements the Sensor AXI wrapper here:

```text
rtl_work/axi_peripherals/axi_sensor_core/hdl/axi_sensor_core.v
```

Start Sensor RTL review with:

1. `docs/specs/axi_sensor_core_SPEC.md` for the register map and command pulse behavior.
2. `rtl_work/axi_peripherals/axi_sensor_core/hdl/axi_sensor_core.v` for the AXI wrapper.
3. `docs/rtl_views/axi_sensor_core_hierarchy.md` for hierarchy and register-to-port mapping.
4. `docs/rtl_views/axi_sensor_core_reuse_notes.md` for inspected source interfaces and reuse decisions.
5. `axi_project_unique_sources/sources/sr04.v` and `dht11.v` for unchanged reused leaf modules.

Trace the control path this way:

```text
AXI write to CONTROL
  -> control_reg[0] sr04_enable
  -> control_reg[8] dht_enable
```

Trace command pulses this way:

```text
AXI write to COMMAND
  -> COMMAND[0] + WSTRB[0] + sr04_enable -> one-clock sr04_start_pulse
  -> COMMAND[8] + WSTRB[1] + dht_enable -> one-clock dht_start_pulse
```

`axi_sensor_core` remains decoupled from FND hardware. No reference Sensor RTL was modified and no adapted Sensor copy was created.

## Unattended Phase C Sensor Simulation Reverse-Engineering Update

The focused `axi_sensor_core` Vivado 2020.2 simulation passed using:

```text
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_sensor_core/run_axi_sensor_core_sim.tcl
```

Result evidence:

- `sim/vivado/axi_sensor_core/axi_sensor_core_sim_result.txt` contains `PASS tests_passed=17 errors=0`.
- Vivado log: `sim/vivado/axi_sensor_core/logs/axi_sensor_core_sim_20260622_190239_vivado.log`.
- xsim log: `sim/vivado/axi_sensor_core/logs/axi_sensor_core_sim_20260622_190239_xsim.log`.
- Report: `docs/report_assets/axi_sensor_core_vivado_sim_report.md`.

The simulation compiled only `sr04.v`, `dht11.v`, `axi_sensor_core.v`, and `tb_axi_sensor_core.sv`. It did not compile GPIO, FND, Timer, SPI, I2C, UVM, MicroBlaze software, or block-design files.

The DHT11 check is limited to start-line/status sanity; full DHT11 frame modeling remains future verification work. No Sensor RTL fixes were required, and the reference Sensor RTL remained unchanged.

## Unattended Phase D SPI Specification Reverse-Engineering Update

The SPI specification package was created after Sensor simulation passed.

Start SPI reconstruction here:

1. `docs/specs/axi_spi_core_SPEC.md` for the register map, external master pins, WSTRB behavior, and command policy.
2. `docs/rtl_views/axi_spi_core_reuse_notes.md` for inspected `spi_master_byte.sv` and `spi_slave_byte.sv` ports.
3. `docs/specs/axi_spi_core_VERIFICATION_PLAN.md` for the future directed Vivado simulation checklist.
4. `docs/specs/axi_spi_core_SOFTWARE_COMMANDS.md` for planned MicroBlaze UART commands.
5. `docs/diagrams/axi_spi_core_wrapper.drawio` and the SPI WaveDrom files for architecture/timing intent.

Important SPI traceability facts:

- `spi_master_byte.sv` is the direct reuse candidate for the first master-only AXI wrapper.
- `spi_slave_byte.sv` is optional for later slave/loopback support.
- SPI RTL was intentionally not implemented in this unattended run.
- Reference SPI RTL remained unchanged.
- UVM, MicroBlaze software, and Vivado block design remain uncreated.

## Prompt 14 SPI RTL Reverse-Engineering Update

Prompt 14 implements the first master-only SPI AXI wrapper here:

```text
rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v
```

Start SPI RTL inspection with:

1. `docs/specs/axi_spi_core_SPEC.md` for the register map and command policy.
2. `rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v` for the AXI wrapper.
3. `docs/rtl_views/axi_spi_core_hierarchy.md` for register-to-port mapping.
4. `docs/rtl_views/axi_spi_core_reuse_notes.md` for inspected source interfaces and reuse decisions.

Trace path:

```text
CONTROL[1:0]/CONTROL[2] -> control_reg -> spi_master_byte.cpol/cpha
CLKDIV[15:0] -> clkdiv_reg -> clk_div_to_master -> spi_master_byte.clk_div
TXDATA[7:0] -> txdata_reg -> spi_master_byte.tx_data
COMMAND[0] accepted write -> spi_start_pulse -> spi_master_byte.start
spi_master_byte.rx_data -> RXDATA[7:0]
spi_master_byte.busy/done -> STATUS[0]/done_sticky
```

`COMMAND[0]` reads zero and generates one clock of `spi_start_pulse` only when `WSTRB[0]`, `WDATA[0]`, `CONTROL[0] enable`, and `~spi_busy` are all true. Disabled or busy start writes are ignored and do not clear `done_sticky`.

`done_sticky` clears on reset and on a new accepted start. It sets when `spi_done` pulses from `u_spi_master_byte`.

`CLKDIV` may store and read back zero, but `clk_div_to_master` clamps zero to `16'h0001` before driving the reused SPI master.

The wrapper does not instantiate `spi_slave_byte`, GPIO, FND, Timer, Sensor, I2C, UVM, MicroBlaze software, or block-design constructs. SPI simulation remains pending, and no `sim/vivado/axi_spi_core` directory was created in Prompt 14.
## Prompt 15 SPI Simulation Reverse-Engineering Update

Prompt 15 created and ran the focused `axi_spi_core` Vivado 2020.2 simulation using:

```text
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_spi_core/run_axi_spi_core_sim.tcl
```

Result evidence:

- `sim/vivado/axi_spi_core/axi_spi_core_sim_result.txt` contains `PASS tests_passed=20 errors=0`.
- Vivado log: `sim/vivado/axi_spi_core/logs/axi_spi_core_sim_20260622_212929_vivado.log`.
- xsim log: `sim/vivado/axi_spi_core/logs/axi_spi_core_sim_20260622_212929_xsim.log`.
- Report: `docs/report_assets/axi_spi_core_vivado_sim_report.md`.

The simulation compiled only `spi_master_byte.sv`, `axi_spi_core.v`, and `tb_axi_spi_core.sv`. It did not compile `spi_slave_byte.sv`, GPIO, FND, Timer, Sensor, I2C, UVM, MicroBlaze software, or block-design files.

The directed testbench covers reset, `CONTROL`, `CLKDIV`, `TXDATA`, `COMMAND`, `RXDATA`, `STATUS`, `VERSION`, WSTRB behavior, read-only protection, reserved offsets, start gating, busy handling, `done_sticky`, CPOL idle behavior, CPHA/mode transfer sanity, deterministic-MISO RXDATA behavior, and the `CLKDIV` zero clamp.

No RTL, testbench, or Tcl fixes were required after the first SPI simulation run. Reference SPI RTL remained unchanged, and `axi_spi_core.v` was not modified during Prompt 15 debugging.
## Prompt 16 I2C Specification Reverse-Engineering Update

Prompt 16 adds the `axi_i2c_core` specification package only. No I2C RTL, AXI wrapper, Vivado simulation testbench, simulation run, UVM environment, MicroBlaze software, or Vivado block design was created.

Start I2C reconstruction here:

1. `docs/specs/axi_i2c_core_SPEC.md` for the register map, open-drain ports, WSTRB behavior, command priority, reset behavior, and parameter policy.
2. `docs/rtl_views/axi_i2c_core_reuse_notes.md` for the inspected `i2c_master_core.sv` and `i2c_slave_core.sv` interfaces.
3. `docs/specs/axi_i2c_core_SOFTWARE_COMMANDS.md` for planned low-level MicroBlaze UART commands.
4. `docs/specs/axi_i2c_core_VERIFICATION_PLAN.md` for the future directed Vivado simulation checklist.
5. `docs/diagrams/axi_i2c_core_wrapper.drawio` and the I2C WaveDrom files for architecture and timing intent.

Important I2C traceability facts:

- `i2c_master_core.sv` is the direct reuse candidate for the first master-only AXI wrapper.
- `i2c_slave_core.sv` remains optional/reference-only for later slave mode, board-to-board testing, or loopback-style verification if explicitly requested.
- The first wrapper is specified as low-level master-only: software issues `START`, `STOP`, `WRITE_BYTE`, and `READ_BYTE` commands.
- The first wrapper exposes open-drain `inout` pins `i2c_scl_io` and `i2c_sda_io`; external pull-ups are required on hardware and should be modeled in simulation.
- `COMMAND` writes generate one-clock `cmd_valid` pulses only when `CONTROL.enable=1` and `cmd_ready=1`.
- Command priority is `START` > `STOP` > `WRITE_BYTE` > `READ_BYTE`.
- I2C speed is a synthesis-time parameter decision through `I2C_CLK_HZ` and `I2C_BUS_HZ`; no runtime clock divider is specified in the first version.
- Reference I2C RTL remained unchanged.
- UVM remains deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.
## Prompt 17 I2C RTL Reverse-Engineering Update

Prompt 17 implements the first master-only I2C AXI wrapper here:

```text
rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v
```

Start I2C RTL inspection with:

1. `docs/specs/axi_i2c_core_SPEC.md` for the intended register map and behavior.
2. `rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v` for the AXI wrapper implementation.
3. `docs/rtl_views/axi_i2c_core_hierarchy.md` for register-to-port mapping.
4. `docs/rtl_views/axi_i2c_core_reuse_notes.md` for inspected source interfaces and Prompt 17 implementation decisions.
5. `axi_project_unique_sources/sources/i2c_master_core.sv` for the unchanged reused master.

Trace the control path this way:

```text
AXI write to CONTROL
  -> control_reg[0] enable
  -> control_reg[1] read_ack
  -> i2c_master_core.read_ack
```

Trace command pulses this way:

```text
AXI write to COMMAND
  -> WSTRB[0] && CONTROL.enable && i2c_cmd_ready && |WDATA[3:0]
  -> one-clock i2c_cmd_valid_pulse
  -> i2c_cmd_code priority: START, STOP, WRITE_BYTE, READ_BYTE
  -> i2c_master_core.cmd_valid/cmd
```

Trace data and status this way:

```text
TXDATA[7:0] -> i2c_master_core.tx_byte
i2c_master_core.rx_byte -> RXDATA[7:0]
i2c_master_core.busy/cmd_ready/nack -> STATUS
i2c_done -> done_sticky
i2c_done && i2c_nack -> nack_sticky
```

Open-drain SCL/SDA behavior:

```text
i2c_master_core.scl_drive_low -> drive i2c_scl_io low or release to high-Z
i2c_master_core.sda_drive_low -> drive i2c_sda_io low or release to high-Z
i2c_scl_io/i2c_sda_io -> sampled back as scl_in/sda_in
```

The wrapper does not instantiate `i2c_slave_core`, GPIO, FND, Timer, Sensor, SPI, UVM, MicroBlaze software, or block-design constructs. I2C simulation remains pending and no `sim/vivado/axi_i2c_core` directory was created in Prompt 17.
## Prompt 18 I2C Simulation Reverse-Engineering Update

Prompt 18 created and ran the focused `axi_i2c_core` Vivado 2020.2 simulation using:

```text
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source sim/vivado/axi_i2c_core/run_axi_i2c_core_sim.tcl
```

Result evidence:

- `sim/vivado/axi_i2c_core/axi_i2c_core_sim_result.txt` contains `PASS tests_passed=23 errors=0`.
- Vivado log: `sim/vivado/axi_i2c_core/logs/axi_i2c_core_sim_20260622_221807_vivado.log`.
- xsim log: `sim/vivado/axi_i2c_core/logs/axi_i2c_core_sim_20260622_221807_xsim.log`.
- Report: `docs/report_assets/axi_i2c_core_vivado_sim_report.md`.

The simulation compiled only `i2c_master_core.sv`, `axi_i2c_core.v`, and `tb_axi_i2c_core.sv`. It did not compile `i2c_slave_core.sv`, GPIO, FND, Timer, Sensor, SPI, UVM, MicroBlaze software, or block-design files.

The directed testbench covers reset, `CONTROL`, `TXDATA`, `COMMAND`, `RXDATA`, `STATUS`, `BUS_STATUS`, `VERSION`, WSTRB behavior, read-only protection, reserved offsets, command gating, command priority, busy handling, `done_sticky`, `nack_sticky`, ACK/NACK write-byte behavior, read-byte behavior, open-drain SCL/SDA behavior, and I2C-only compile independence.

The testbench models external I2C pull-ups with `tri1` nets and uses simple SDA low/high-Z stimulus for ACK/NACK/read cases. No RTL, testbench, or Tcl fixes were required after the first I2C simulation run. Reference I2C RTL remained unchanged, and `axi_i2c_core.v` was not modified during Prompt 18 debugging.
## Prompt 19 Baseline Review And Integration Preparation Update

Prompt 19 reviewed the six implemented custom AXI4-Lite peripherals and prepared the project for the next packaging/integration phase. No RTL, reference RTL, UVM, MicroBlaze software, packaged IP, block design, bitstream, or Vitis workspace was created.

Fresh regression evidence:

```text
powershell.exe -NoProfile -ExecutionPolicy Bypass -File sim\vivado\run_all_peripheral_sims.ps1
```

The regression ran from `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC` using `D:\Xilinx\Vivado\2020.2\bin\vivado.bat`. It passed all six focused simulations:

- GPIO: `PASS tests_passed=12 errors=0`
- FND: `PASS tests_passed=16 errors=0`
- Timer: `PASS tests_passed=19 errors=0`
- Sensor: `PASS tests_passed=17 errors=0`
- SPI: `PASS tests_passed=20 errors=0`
- I2C: `PASS tests_passed=23 errors=0`

Start future integration work from:

1. `docs/report_assets/custom_peripheral_baseline_review.md`
2. `docs/report_assets/full_peripheral_regression_report.md`
3. `docs/integration/MICROBLAZE_INTEGRATION_PLAN.md`
4. `docs/integration/CUSTOM_IP_PACKAGING_PLAN.md`
5. `docs/integration/AXI_ADDRESS_ASSIGNMENT_FINAL_CHECK.md`
6. `docs/integration/PERIPHERAL_EXTERNAL_PORT_SUMMARY.md`
7. `docs/integration/MICROBLAZE_SOFTWARE_COMMAND_MATRIX.md`
8. `docs/integration/INTEGRATION_RISK_CHECKLIST.md`

No verified Basys3 XDC file was present in the canonical project root, so exact board pins remain a future constraints step.

## Prompt 20 Custom IP Packaging Reverse-Engineering Update

Prompt 20 packaged the implemented and simulation-passing custom AXI4-Lite wrappers into local Vivado 2020.2 IP. The packaging flow used direct wrapper and dependency source lists from the Prompt 19 packaging plan and did not change any RTL behavior.

Packaging command:

```text
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/package_all_custom_ip.tcl
```

Packaging outputs:

- `vivado/scripts/package_all_custom_ip.tcl`
- `vivado/scripts/package_common_custom_ip.tcl`
- `vivado/scripts/package_axi_gpio_core.tcl`
- `vivado/scripts/package_axi_fnd_core.tcl`
- `vivado/scripts/package_axi_timer_core.tcl`
- `vivado/scripts/package_axi_sensor_core.tcl`
- `vivado/scripts/package_axi_spi_core.tcl`
- `vivado/scripts/package_axi_i2c_core.tcl`
- `vivado/ip_repo/<ip_name>/component.xml` for all six packaged IPs
- `docs/report_assets/custom_ip_packaging_report.md`

Validation confirmed that all six IPs are visible through the local Vivado IP catalog as `user.org:user:<ip_name>:1.0`. Each package has `S00_AXI`, associated `s00_axi_aclk`, active-low `s00_axi_aresetn`, and the expected external wrapper ports. SPI and I2C keep their `.sv` dependencies as SystemVerilog sources in the packaged IP metadata.

No MicroBlaze block design, software, bitstream, Vitis workspace, or UVM environment was created. Reference RTL and project RTL wrappers remained unchanged.

## Prompt 21 MicroBlaze Block Design Reverse-Engineering Update

Prompt 21 created the first MicroBlaze Basys3 block design from the packaged local IP repository. The design uses part `xc7a35tcpg236-1`; no Basys3 `board_part` was available in this Vivado 2020.2 installation, so the project remains part-only until XDC work.

The block design contains MicroBlaze, MDM debug, Processor System Reset, SmartConnect, AXI UART Lite, LMB local memory, and the six packaged local IPs. `clk_100mhz_i` is the shared system clock. `reset_i` is an active-high external reset into Processor System Reset. The active-low peripheral reset output drives AXI UART Lite and the six custom `s00_axi_aresetn` pins.

Vivado validation passed:

```text
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/create_microblaze_basys3_bd.tcl
```

Address assignments matched the planned map exactly: AXI UART Lite at `0x4060_0000`, and custom IPs at `0x44A0_0000` through `0x44A5_0000` with 64 KB ranges.

A real block-design metadata issue was observed in the packaged IP `component.xml` files: clock `ASSOCIATED_BUSIF` used `s00_axi:S00_AXI`, which caused duplicate clock-association critical warnings. Prompt 21 fixed only generated IP metadata by normalizing this value to `S00_AXI`; RTL wrappers, reference RTL, and packaged HDL source copies were not changed.

No bitstream, synthesis, implementation, XDC pin assignment, hardware export, Vitis workspace, C software, UVM environment, or board demo was created.


## Prompt 22 Basys3 XDC Reverse-Engineering Update

Prompt 22 constrained the actual `microblaze_axi_soc_bd_wrapper.v` top-level ports for Basys3. No verified master XDC was present in the canonical project root, so the constraints were created from the requested Basys3 pin map and checked against the generated wrapper.

The dedicated Basys3 `CPU_RESETN` pin C12 is used for system reset. Because `proc_sys_reset_0/CONFIG.C_EXT_RESET_HIGH` is read-only in the opened Vivado 2020.2 block design, the BD now includes `rstn_inv_0`, a `util_vector_logic` NOT block. The final reset path is `reset_i` active-low -> `rstn_inv_0` -> `proc_sys_reset_0/ext_reset_in` active-high. The five normal push buttons remain available as `btn_i[4:0]`.

Final command:

```text
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/apply_basys3_xdc.tcl
```

Validation passed with no final `ERROR:`, `CRITICAL WARNING:`, or `WARNING:` log lines. No synthesis, implementation, bitstream, XSA export, Vitis workspace, user MicroBlaze C application, UVM environment, board demo, RTL change, or reference RTL change was made.

## Prompt 22 v1 Reset Revision Support Update

A revised Prompt 22 pass added explicit reset revision support. The main XDC keeps `reset_i` on CPU_RESETN C12 as the first-pass default, while `constraints/basys3/reset_options/` now contains a default C12 snippet and a commented external PMOD active-low reset template.

The final `apply_basys3_xdc.tcl` checks the existing reset topology before editing the BD. With `rstn_inv_0` already present and correctly connected, the final run left the BD and wrapper unchanged on that run while still validating the design and XDC.

Final revised command:

```text
D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/apply_basys3_xdc.tcl
```

The final revised log `basys3_xdc_apply_v1_20260623_002733_vivado.log` has no `ERROR:`, `CRITICAL WARNING:`, or `WARNING:` lines. No bitstream, synthesis, implementation, XSA export, Vitis workspace, user MicroBlaze C application, UVM environment, board demo, RTL change, or reference RTL change was made.

## Prompt 23 Bitstream Build Notes

Vivado 2020.2 successfully built the integrated MicroBlaze AXI4-Lite SoC through bitstream and exported an XSA with the bitstream included. No RTL or reference RTL edits were needed.

Important implementation discovery: the Prompt 22 CPU_RESETN/C12 reset assignment is not valid for the selected part `xc7a35tcpg236-1`; Vivado rejected it during XDC parsing. The reset fallback now uses external PMOD JA4/G2 active-low wiring with `PULLUP true`, while preserving the existing BD inverter `rstn_inv_0` and all five GPIO buttons.

Build observations to carry forward:

- Timing met at 100 MHz: WNS `1.772 ns`, TNS `0.000 ns`, WHS `0.023 ns`.
- DRC had no errors or critical warnings, but retained 11 warnings: CFGBVS/CONFIG_VOLTAGE not explicitly set, MicroBlaze DSP pipelining advisories, inout buffering warnings for DHT11/I2C, and no-routable-load advisories inside generated Xilinx IP.
- The build log contains repeated MDM debug generated-clock critical warnings, but user timing constraints are met.
- The XSA currently contains the generated bootloop ELF output product from the MicroBlaze IP, not user-created software.

## Prompt 24 Software Bring-Up Notes

Prompt 24 added the first MicroBlaze software layer without modifying RTL, the Vivado block design, the bitstream, or the XSA.

Important carry-forward facts:

- The software base-address fallbacks match the Prompt 23 block-design address report.
- `xparameters.h` macros are preferred when present; fixed addresses are used only as fallbacks.
- UART console I/O uses the standalone BSP `inbyte`/`outbyte` path and expects AXI UART Lite to be selected as stdin/stdout by the BSP.
- Sensor, SPI, and I2C commands remain register-level bring-up helpers. They do not claim external-device success without board evidence.
- XSCT/Vitis 2020.2 is currently missing, so compile feedback is not available yet.
- Reset remains external active-low PMOD JA4/G2 with pullup.

## Prompt 24.5 Toolchain Discovery Notes

Prompt 24.5 confirmed that the current machine has discoverable XSCT executables only under Xilinx 2024.2 paths. These were deliberately not used for the MicroBlaze software build because the project flow requires the 2020.2 toolchain for this handoff.

Software static checks passed, including file presence, base-address fallback constants, version offset usage, global command support, and absence of source-level board-success claims.

Carry-forward: the next software step needs a valid Vitis/XSCT 2020.2 path before any board bring-up can be attempted.

## Vitis 2020.2 Build Notes

After installing Vitis 2020.2, the build wrapper selected `D:\Xilinx\Vitis\2020.2\bin\xsct.bat` and generated the Vitis workspace, platform, standalone BSP, application project, and ELF.

Observed non-fatal build messages included deprecated `sysconfig` warnings from Vitis 2020.2 and a BSP `microblaze_sleep.c` pragma note. No build-stopping errors were observed.

The generated ELF is ready for a future board programming and UART smoke test step, but no board-level success has been claimed.

## Prompt 25A Offline Board Bring-up Notes

The board package was prepared without running hardware commands. The reset policy remains PMOD JA4/G2 active-low with pull-up behavior; onboard buttons remain GPIO inputs. The UART terminal setting for future manual testing is 9600 baud, 8 data bits, no parity, 1 stop bit, no flow control.

The checksum manifest captures the current bitstream, XSA, ELF, programming scripts, and UART smoke sequence so future board tests can confirm the exact artifacts used.

No board response or peripheral behavior has been observed yet.
