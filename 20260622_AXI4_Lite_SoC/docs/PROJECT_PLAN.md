# Project Plan

## Objective

Build a Basys3-first MicroBlaze AXI4-Lite multi-peripheral SoC that reuses existing legacy RTL cores as internal leaf modules behind custom AXI4-Lite slave wrappers.

Target system concept:

```text
PC terminal
  -> Xilinx AXI UART Lite
  -> MicroBlaze software command parser
  -> AXI Interconnect
  -> custom AXI4-Lite slave peripherals
  -> reused legacy RTL cores
  -> Basys3 external devices
```

The project should demonstrate that an earlier RTL-only UART/control architecture was reorganized into a software-controlled MicroBlaze AXI4-Lite SoC.

## Tool And Board Targets

| Item | Decision |
| --- | --- |
| Primary FPGA board | Basys3 |
| Optional later board | Zybo Z7-20 |
| Required Vivado version | Vivado 2020.2 |
| Main console | Xilinx AXI UART Lite |
| Main AXI master | MicroBlaze |
| Custom peripheral bus role | AXI4-Lite slaves |
| Initial verification approach | Peripheral-by-peripheral Vivado simulation first; UVM is deferred until all custom peripherals have RTL and basic Vivado simulation coverage |

## Planned Custom AXI4-Lite Peripherals

| Order | Peripheral | Role | Main reused RTL |
| --- | --- | --- | --- |
| 1 | `axi_gpio_core` | LED output, switch input, button input, optional debounce/edge detect | `button_debounce.v`, optional `INPUT_Merger_sw4.v` |
| 2 | `axi_fnd_core` | Basys3 FND display peripheral | `fnd_controller.v` |
| 3 | `axi_timer_core` | Stopwatch and watch peripheral | `stopwatch_datapath.v`, `watch_datapath.v`, `watch_fnd_adapter.v` |
| 4 | `axi_sensor_core` | DHT11 and SR04 sensor peripheral | `dht11.v`, `sr04.v` |
| 5 | `axi_spi_core` | SPI controller peripheral | `spi_master_byte.sv`, optional `spi_slave_byte.sv` |
| 6 | `axi_i2c_core` | I2C controller peripheral | `i2c_master_core.sv`, optional `i2c_slave_core.sv` |

## Main RTL Development Flow

| Step | Purpose | Expected outputs |
| --- | --- | --- |
| 1. Plan / source audit | Audit source and define project structure | Step 0 docs, source reuse matrix, risk plan, diagram asset plan |
| 2. Spec | Define one peripheral at a time before RTL | Register map, signal map, wrapper block diagram, test plan |
| 3. RTL wrapper | Build AXI wrapper around reused RTL | Verilog AXI4-Lite slave wrapper, source reuse notes, updated traceability |
| 4. Vivado simulation | Run focused wrapper simulation | Vivado 2020.2 simulation Tcl, waveform expectations, pass/fail notes |
| 5. Repeat peripherals | Complete GPIO, FND, Timer, Sensor, SPI, and I2C through spec/RTL/basic sim | One basic Vivado simulation package per custom AXI4-Lite peripheral |
| 6. MicroBlaze block design integration | Integrate custom peripherals behind AXI Interconnect | Vivado block design or script, address assignment, XDC integration |
| 7. Board demonstration | Demonstrate the MicroBlaze-controlled system on Basys3 | MicroBlaze C app, UART demo transcript, board notes |
| 8. Presentation/report | Prepare reviewable final assets | Draw.io diagrams, WaveDrom timing, RTL hierarchy, report tables, demo notes |

## Separate UVM Verification Flow

UVM is a separate later verification process. It should not be started immediately after only the GPIO basic simulation exists.

| Step | Policy |
| --- | --- |
| 1 | Start only after all custom AXI4-Lite peripherals are implemented. |
| 2 | Start only after each peripheral has passed its basic Vivado simulation. |
| 3 | Follow the RAM UVM split reference structure. |
| 4 | Build common AXI-Lite UVM components if useful. |
| 5 | Create peripheral-specific sequences, scoreboards, and coverage. |
| 6 | Add final UVM results to the report after the later UVM campaign. |

## Milestone Order

1. Complete Step 0 source audit and planning documents.
2. Define `axi_gpio_core` specification and register map.
3. Implement `axi_gpio_core` AXI wrapper using Vivado 2020.2 AXI4-Lite template style.
4. Create and run the `axi_gpio_core` Vivado simulation.
5. Repeat the spec, RTL wrapper, and basic Vivado simulation flow for FND, Timer, Sensor, SPI, and I2C.
6. Integrate the custom peripherals into a MicroBlaze Basys3 block design.
7. Verify the integrated design through AXI UART Lite commands and board demonstration.
8. Prepare final presentation/report assets.
9. Run the separate UVM verification flow after all custom peripherals have basic passing Vivado simulations.

## Expected Outputs Per Peripheral

| Output type | Expected artifact |
| --- | --- |
| Specification | `docs/specs/<peripheral>_SPEC.md` planned for later |
| Register map | Included in the peripheral spec and traceability matrix |
| Wrapper RTL | `rtl_work/axi_peripherals/<peripheral>/hdl/<peripheral>.v` planned for later |
| Vivado simulation | `sim/vivado/<peripheral>/tb_<peripheral>.*` and `run_<peripheral>_sim.tcl` planned for later |
| UVM verification | `uvm/<peripheral>_uvm/*` deferred until all custom peripherals are implemented and basic Vivado simulations pass |
| Block diagram | `docs/diagrams/<peripheral>_wrapper.drawio` planned for later |
| Timing diagram | `docs/wavedrom/<peripheral>_timing.json` as needed |
| Board demo notes | `docs/report_assets/<peripheral>_board_demo.md` planned for later |

## Step 0 Non-Goals

The following are intentionally not part of Step 0:

- No GPIO/FND/Timer/Sensor/SPI/I2C RTL implementation.
- No AXI wrapper creation.
- No Vivado project or block design creation.
- No UVM environment creation.
- No modification of reference RTL.
- No modification of RAM UVM reference files.

## Prompt 1 Status Update

Prompt 1 completed the global AXI address map and the `axi_gpio_core` specification package.

Created specification baseline:

- `docs/specs/AXI_ADDRESS_MAP.md`
- `docs/specs/AXI_REGISTER_CONVENTIONS.md`
- `docs/specs/axi_gpio_core_SPEC.md`
- `docs/specs/axi_gpio_core_VERIFICATION_PLAN.md`
- `docs/specs/axi_gpio_core_SOFTWARE_COMMANDS.md`
- `docs/rtl_views/axi_gpio_core_reuse_notes.md`

Created editable diagram/timing sources:

- `docs/diagrams/overall_microblaze_axi_soc.drawio`
- `docs/diagrams/axi_address_map.drawio`
- `docs/diagrams/axi_gpio_core_wrapper.drawio`
- `docs/wavedrom/axi_lite_write.json`
- `docs/wavedrom/axi_lite_read.json`
- `docs/wavedrom/axi_gpio_write_read.json`
- `docs/wavedrom/axi_gpio_button_edge.json`

Next recommended milestone:

1. Resolve the `btn_debounced` level implementation choice for `axi_gpio_core`.
2. Implement `axi_gpio_core` RTL wrapper using the Vivado 2020.2 Xilinx AXI4-Lite slave template style.
3. Keep the reference `button_debounce.v` unchanged.

## Prompt 3 Status Update

Prompt 3 created a focused Vivado 2020.2 behavioral simulation bundle for `axi_gpio_core`.

Created:

- `sim/vivado/axi_gpio_core/tb_axi_gpio_core.sv`
- `sim/vivado/axi_gpio_core/run_axi_gpio_core_sim.tcl`
- `sim/vivado/axi_gpio_core/README.md`
- `docs/report_assets/axi_gpio_core_vivado_sim_report.md`

The simulation is directed and covers reset, register read/write behavior, WSTRB, synchronized inputs, debounce level/edge behavior, edge clearing, reserved offsets, and read-only write protection.

## Prompt 3.5 Flow Policy Update

Prompt 3.5 checked for Vivado 2020.2 and confirmed that only Vivado 2024.2 is currently installed/on PATH in this environment. The GPIO simulation remains created but not run.

The project flow decision is now:

1. Complete each custom AXI4-Lite peripheral through spec, RTL wrapper, and basic Vivado simulation.
2. Repeat that flow for GPIO, FND, Timer, Sensor, SPI, and I2C.
3. Integrate the custom peripherals into the MicroBlaze block design after the peripheral RTL/simulation baseline exists.
4. Keep UVM as a separate later verification process after all custom peripherals are implemented and have basic Vivado simulation results.

Next recommended milestone:

1. Superseded by Prompt 3.6: GPIO Vivado simulation passed in Vivado 2020.2.
2. Proceed to Prompt 4: axi_fnd_core specification.

## Prompt 3.6 Simulation Status Update

Prompt 3.6 ran the GPIO Vivado simulation using `D:\Xilinx\Vivado\2020.2\bin\vivado.bat`.

Final simulation result:

- `PASS tests_passed=12 errors=0`
- All 12 directed GPIO tests passed.
- No RTL changes were required.
- Tcl/testbench fixes were limited to Vivado 2020.2 project/plusarg handling, duplicate-run cleanup, and AXI write-task handshake timing.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

Next recommended milestone:

1. Proceed to Prompt 4: `axi_fnd_core` specification.
## Prompt 4 FND Specification Status Update

Prompt 4 completed the `axi_fnd_core` specification package only.

Created:

- `docs/specs/axi_fnd_core_SPEC.md`
- `docs/specs/axi_fnd_core_VERIFICATION_PLAN.md`
- `docs/specs/axi_fnd_core_SOFTWARE_COMMANDS.md`
- `docs/rtl_views/axi_fnd_core_reuse_notes.md`
- `docs/diagrams/axi_fnd_core_wrapper.drawio`
- `docs/wavedrom/axi_fnd_register_update.json`
- `docs/wavedrom/axi_fnd_enable_disable.json`

`fnd_controller.v` was inspected and documented as reusable as-is. FND RTL, FND Vivado simulation, UVM, MicroBlaze software, and Vivado block design work were not started.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

Next recommended milestone:

1. Implement `axi_fnd_core` RTL wrapper from the Prompt 4 specification.
## Prompt 5 FND RTL Status Update

Prompt 5 implemented the `axi_fnd_core` RTL wrapper only.

Created:

- `rtl_work/axi_peripherals/axi_fnd_core/hdl/axi_fnd_core.v`
- `docs/rtl_views/axi_fnd_core_hierarchy.md`

Updated:

- `docs/rtl_views/axi_fnd_core_reuse_notes.md`
- `docs/TRACEABILITY_MATRIX.md`
- `docs/REVERSE_ENGINEERING_NOTES.md`

`fnd_controller.v` remains unchanged and is instantiated by the wrapper as `u_fnd_controller`. FND Vivado simulation, UVM, MicroBlaze software, and Vivado block design work remain not started.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

Next recommended milestone:

1. Create and run the `axi_fnd_core` Vivado simulation.
## Prompt 6 FND Simulation Status Update

Prompt 6 created and ran the `axi_fnd_core` Vivado 2020.2 behavioral simulation.

Created:

- `sim/vivado/axi_fnd_core/tb_axi_fnd_core.sv`
- `sim/vivado/axi_fnd_core/run_axi_fnd_core_sim.tcl`
- `sim/vivado/axi_fnd_core/README.md`
- `docs/report_assets/axi_fnd_core_vivado_sim_report.md`

Final simulation result:

- `PASS tests_passed=16 errors=0`
- All 16 directed FND tests passed.
- No RTL changes were required during Prompt 6.
- The reference `fnd_controller.v` remained unchanged.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

Next recommended milestone:

1. Proceed to Prompt 7: `axi_timer_core` specification.
## Prompt 7 Timer Specification Status Update

Prompt 7 completed the `axi_timer_core` specification package only.

Created:

- `docs/specs/axi_timer_core_SPEC.md`
- `docs/specs/axi_timer_core_VERIFICATION_PLAN.md`
- `docs/specs/axi_timer_core_SOFTWARE_COMMANDS.md`
- `docs/rtl_views/axi_timer_core_reuse_notes.md`
- `docs/diagrams/axi_timer_core_wrapper.drawio`
- `docs/wavedrom/axi_timer_control_command.json`
- `docs/wavedrom/axi_timer_watch_edit.json`
- `docs/wavedrom/axi_timer_read_values.json`
- `docs/AXI4_LITE_SOC_FILE_INDEX.md`

Timer decisions:

- `stopwatch_datapath.v`, `watch_datapath.v`, and `watch_fnd_adapter.v` are direct reuse candidates.
- `top_control_unit.v` and `top_stopwatch_watch.v` are reference-only legacy files.
- `axi_timer_core` stays decoupled from `axi_fnd_core`; MicroBlaze software will later bridge Timer values into FND display registers.
- The future Timer simulation must account for the reused 100 Hz tick generators without modifying reference RTL.

No Timer RTL, AXI wrapper, Vivado simulation testbench, simulation run, UVM environment, MicroBlaze software, or Vivado block design was created in Prompt 7.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

Next recommended milestone:

1. Implement `axi_timer_core` RTL wrapper from the Prompt 7 specification.
## Prompt 7.5 Physical Cleanup Status Update

Prompt 7.5 physically moved the current AXI4-Lite SoC project into its canonical root:

```text
D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC
```

The parent directory remains the Git root and may contain other projects or unclassified content.

Moved project-owned folders:

- `docs`
- `rtl_work`
- `sim`
- `axi_project_unique_sources`
- `UVM_testbench_ref`

Root-level Vivado log/journal files were archived under:

```text
20260622_AXI4_Lite_SoC/_archive/root_vivado_logs
```

GPIO and FND simulation Tcl scripts were updated to derive the project root from `[info script]`. Timer remains spec complete with RTL not started and simulation not started.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

Next recommended milestone after post-migration validation:

1. Implement `axi_timer_core` RTL wrapper from the Prompt 7 specification.
Prompt 7.5 post-migration validation result:

- GPIO Vivado 2020.2 simulation still passes: `PASS tests_passed=12 errors=0`.
- FND Vivado 2020.2 simulation still passes: `PASS tests_passed=16 errors=0`.
- No RTL changed during path migration.
## Prompt 8 Timer RTL Status Update

Prompt 8 implemented the `axi_timer_core` RTL wrapper only.

Created:

- `rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v`
- `docs/rtl_views/axi_timer_core_hierarchy.md`

Updated:

- `docs/rtl_views/axi_timer_core_reuse_notes.md`
- `docs/TRACEABILITY_MATRIX.md`
- `docs/REVERSE_ENGINEERING_NOTES.md`
- `docs/AXI4_LITE_SOC_FILE_INDEX.md`

Timer implementation decisions:

- Directly instantiated `stopwatch_datapath`, `watch_datapath`, and `watch_fnd_adapter`.
- Did not instantiate `top_control_unit`, `top_stopwatch_watch`, `fnd_controller`, or `axi_fnd_core`.
- Did not create an adapted Timer copy.
- Kept Timer decoupled from FND.
- Kept reference timer RTL unchanged.
- Timer simulation, UVM, MicroBlaze software, and Vivado block design work remain not started.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

Next recommended milestone:

1. Create and run the `axi_timer_core` Vivado 2020.2 simulation.
## Prompt 9 Timer Simulation Status Update

Prompt 9 created and ran the `axi_timer_core` Vivado 2020.2 behavioral simulation.

Created:

- `sim/vivado/axi_timer_core/tb_axi_timer_core.sv`
- `sim/vivado/axi_timer_core/run_axi_timer_core_sim.tcl`
- `sim/vivado/axi_timer_core/README.md`
- `docs/report_assets/axi_timer_core_vivado_sim_report.md`

Final simulation result:

- `PASS tests_passed=19 errors=0`
- All 19 directed Timer tests passed.
- The testbench used simulation-only `defparam` fast tick overrides with `F_COUNT = 8`.
- Testbench-only fixes were made for a Vivado keyword collision and deterministic stopwatch stop/clear timing around the accelerated tick.
- No Timer RTL changes were required during Prompt 9.
- The reference Timer RTL remained unchanged.
- No adapted Timer copy was created.
- Timer remains decoupled from FND.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

Next recommended milestone:

1. Proceed to Prompt 10: `axi_sensor_core` specification.

## Unattended Phase A Sensor Specification Status Update

The Sensor specification package was created.

Created:

- `docs/specs/axi_sensor_core_SPEC.md`
- `docs/specs/axi_sensor_core_VERIFICATION_PLAN.md`
- `docs/specs/axi_sensor_core_SOFTWARE_COMMANDS.md`
- `docs/rtl_views/axi_sensor_core_reuse_notes.md`
- `docs/diagrams/axi_sensor_core_wrapper.drawio`
- `docs/wavedrom/axi_sensor_command_status.json`
- `docs/wavedrom/axi_sensor_sr04_echo.json`
- `docs/wavedrom/axi_sensor_dht11_start.json`

Source inspection found no critical ambiguity blocking the first `axi_sensor_core` RTL wrapper. The wrapper should directly instantiate `sr04` and `dht11`, map `dht11.led` to `dht_valid_live`, and keep Sensor independent from FND.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

## Unattended Phase B Sensor RTL Status Update

The Sensor RTL wrapper was implemented.

Created:

- `rtl_work/axi_peripherals/axi_sensor_core/hdl/axi_sensor_core.v`
- `docs/rtl_views/axi_sensor_core_hierarchy.md`

Updated:

- `docs/rtl_views/axi_sensor_core_reuse_notes.md`
- `docs/TRACEABILITY_MATRIX.md`
- `docs/REVERSE_ENGINEERING_NOTES.md`
- `docs/AXI4_LITE_SOC_FILE_INDEX.md`

Implementation decisions:

- Directly instantiated `sr04` and `dht11`.
- Did not create an adapted Sensor copy.
- Kept reference Sensor RTL unchanged.
- Kept Sensor decoupled from FND.
- Sensor Vivado simulation remains pending.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

## Unattended Phase C Sensor Simulation Status Update

The Sensor Vivado 2020.2 simulation was created and passed.

Created:

- `sim/vivado/axi_sensor_core/tb_axi_sensor_core.sv`
- `sim/vivado/axi_sensor_core/run_axi_sensor_core_sim.tcl`
- `sim/vivado/axi_sensor_core/README.md`
- `docs/report_assets/axi_sensor_core_vivado_sim_report.md`

Final simulation result:

- `PASS tests_passed=17 errors=0`
- All 17 directed Sensor tests passed.
- The testbench used simulation-only fast tick overrides for `sr04` and `dht11`.
- Full DHT11 response-frame modeling remains future verification work.
- No Sensor RTL fixes were required.
- The reference Sensor RTL remained unchanged.
- No adapted Sensor copy was created.
- Sensor remains decoupled from FND.

## Unattended Phase D SPI Specification Status Update

The SPI specification package was created.

Created:

- `docs/specs/axi_spi_core_SPEC.md`
- `docs/specs/axi_spi_core_VERIFICATION_PLAN.md`
- `docs/specs/axi_spi_core_SOFTWARE_COMMANDS.md`
- `docs/rtl_views/axi_spi_core_reuse_notes.md`
- `docs/diagrams/axi_spi_core_wrapper.drawio`
- `docs/wavedrom/axi_spi_transaction.json`
- `docs/wavedrom/axi_spi_control_status.json`

Source inspection found that `spi_master_byte.sv` is a direct reuse candidate for the first master-only AXI wrapper. `spi_slave_byte.sv` remains optional for later slave or loopback support.

SPI RTL, SPI simulation, UVM, MicroBlaze software, and Vivado block design work remain intentionally not started.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

Next recommended milestone:

1. Implement `axi_spi_core` RTL wrapper.
## Prompt 14 SPI RTL Status Update

The SPI RTL wrapper was implemented.

Created:

- `rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v`
- `docs/rtl_views/axi_spi_core_hierarchy.md`

Updated:

- `docs/rtl_views/axi_spi_core_reuse_notes.md`
- `docs/TRACEABILITY_MATRIX.md`
- `docs/REVERSE_ENGINEERING_NOTES.md`
- `docs/AXI4_LITE_SOC_FILE_INDEX.md`

Implementation decisions:

- Directly instantiated `spi_master_byte` as `u_spi_master_byte`.
- Did not instantiate `spi_slave_byte`.
- Kept reference SPI RTL unchanged.
- Kept the first wrapper master-only.
- Implemented `CLKDIV` zero clamping only at `clk_div_to_master`; register readback preserves the stored value.
- SPI Vivado simulation remains pending.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

Next recommended milestone:

1. Create and run the `axi_spi_core` Vivado 2020.2 simulation.
## Prompt 15 SPI Simulation Status Update

The SPI Vivado 2020.2 simulation was created and passed.

Created:

- `sim/vivado/axi_spi_core/tb_axi_spi_core.sv`
- `sim/vivado/axi_spi_core/run_axi_spi_core_sim.tcl`
- `sim/vivado/axi_spi_core/README.md`
- `docs/report_assets/axi_spi_core_vivado_sim_report.md`

Final simulation result:

- `PASS tests_passed=20 errors=0`
- All 20 directed SPI tests passed.
- The testbench used deterministic constant-MISO stimulus for RXDATA checks.
- `spi_master_byte.sv` was compiled as SystemVerilog.
- `spi_slave_byte.sv` remained optional/reference-only and uncompiled.
- No SPI RTL, testbench, or Tcl fixes were required after the first run.
- The reference SPI RTL remained unchanged.
- SPI remains independent from GPIO, FND, Timer, Sensor, I2C, UVM, MicroBlaze software, and block-design files.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

Next recommended milestone:

1. Proceed to Prompt 16: `axi_i2c_core` specification.
## Prompt 16 I2C Specification Status Update

Prompt 16 completed the `axi_i2c_core` specification package only.

Created:

- `docs/specs/axi_i2c_core_SPEC.md`
- `docs/specs/axi_i2c_core_VERIFICATION_PLAN.md`
- `docs/specs/axi_i2c_core_SOFTWARE_COMMANDS.md`
- `docs/rtl_views/axi_i2c_core_reuse_notes.md`
- `docs/diagrams/axi_i2c_core_wrapper.drawio`
- `docs/wavedrom/axi_i2c_command_status.json`
- `docs/wavedrom/axi_i2c_write_byte.json`
- `docs/wavedrom/axi_i2c_read_byte.json`

I2C decisions:

- `i2c_master_core.sv` is the direct reuse candidate for the first master-only AXI wrapper.
- `i2c_slave_core.sv` remains optional/reference-only for later slave mode, board-to-board testing, or loopback-style verification if explicitly requested.
- The first wrapper is a low-level command peripheral: MicroBlaze software issues `START`, `STOP`, `WRITE_BYTE`, and `READ_BYTE`.
- The first wrapper exposes open-drain `inout` pins `i2c_scl_io` and `i2c_sda_io`.
- I2C speed is controlled by synthesis-time wrapper parameters, not a runtime divider register.

No I2C RTL, AXI wrapper, Vivado simulation testbench, simulation run, UVM environment, MicroBlaze software, or Vivado block design was created in Prompt 16.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

Next recommended milestone:

1. Proceed to Prompt 17: implement `axi_i2c_core` RTL wrapper from the Prompt 16 specification.
## Prompt 17 I2C RTL Status Update

Prompt 17 implemented the `axi_i2c_core` RTL wrapper only.

Created:

- `rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v`
- `docs/rtl_views/axi_i2c_core_hierarchy.md`

Updated:

- `docs/rtl_views/axi_i2c_core_reuse_notes.md`
- `docs/TRACEABILITY_MATRIX.md`
- `docs/REVERSE_ENGINEERING_NOTES.md`
- `docs/AXI4_LITE_SOC_FILE_INDEX.md`

Implementation decisions:

- Directly instantiated `i2c_master_core` as `u_i2c_master_core`.
- Did not instantiate `i2c_slave_core`.
- Kept the first wrapper master-only and low-level command driven.
- Implemented open-drain `i2c_scl_io` and `i2c_sda_io` behavior.
- Kept reference I2C RTL unchanged.

I2C Vivado simulation, UVM, MicroBlaze software, Vivado block design, and board demo remain not started.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

Next recommended milestone:

1. Create and run the `axi_i2c_core` Vivado 2020.2 simulation.
## Prompt 18 I2C Simulation Status Update

The I2C Vivado 2020.2 simulation was created and passed.

Created:

- `sim/vivado/axi_i2c_core/tb_axi_i2c_core.sv`
- `sim/vivado/axi_i2c_core/run_axi_i2c_core_sim.tcl`
- `sim/vivado/axi_i2c_core/README.md`
- `docs/report_assets/axi_i2c_core_vivado_sim_report.md`

Final simulation result:

- `PASS tests_passed=23 errors=0`
- All 23 directed I2C tests passed.
- The testbench modeled open-drain pull-ups with `tri1` SCL/SDA nets.
- `i2c_master_core.sv` was compiled as SystemVerilog.
- `i2c_slave_core.sv` remained optional/reference-only and uncompiled.
- No I2C RTL, testbench, or Tcl fixes were required after the first run.
- The reference I2C RTL remained unchanged.
- I2C remains independent from GPIO, FND, Timer, Sensor, SPI, UVM, MicroBlaze software, and block-design files.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

Next recommended milestone:

1. Proceed to Prompt 19: full custom peripheral baseline review and MicroBlaze integration preparation.
## Prompt 19 Baseline Review And Integration Preparation Status Update

Prompt 19 completed the full custom peripheral baseline review and integration-preparation package.

Created:

- `sim/vivado/run_all_peripheral_sims.ps1`
- `docs/report_assets/full_peripheral_regression_report.md`
- `docs/report_assets/custom_peripheral_baseline_review.md`
- `docs/integration/MICROBLAZE_INTEGRATION_PLAN.md`
- `docs/integration/AXI_ADDRESS_ASSIGNMENT_FINAL_CHECK.md`
- `docs/integration/CUSTOM_IP_PACKAGING_PLAN.md`
- `docs/integration/PERIPHERAL_EXTERNAL_PORT_SUMMARY.md`
- `docs/integration/BASYS3_EXTERNAL_IO_PLANNING.md`
- `docs/integration/MICROBLAZE_SOFTWARE_COMMAND_MATRIX.md`
- `docs/integration/INTEGRATION_RISK_CHECKLIST.md`
- `docs/diagrams/microblaze_axi_soc_integration_ready.drawio`
- `docs/wavedrom/microblaze_uart_to_axi_command_flow.json`

Full regression:

- Ran `sim/vivado/run_all_peripheral_sims.ps1` with Vivado 2020.2.
- GPIO, FND, Timer, Sensor, SPI, and I2C all passed with the expected result strings.
- Fresh report: `docs/report_assets/full_peripheral_regression_report.md`.

Integration status:

- All six custom AXI4-Lite peripherals have implemented RTL and passing focused Vivado simulations.
- IP packaging is prepared but not started.
- MicroBlaze block design is prepared but not started.
- MicroBlaze software command matrix is prepared but no C code was created.
- UVM remains deferred.
- Board demo and exact XDC mapping remain not started.

Next recommended milestone:

1. Proceed to Prompt 20: package custom AXI peripherals as local Vivado IP, or create packaging Tcl if manual IP packaging is preferred.

## Prompt 20 Custom IP Packaging Status Update

Prompt 20 created repeatable Vivado 2020.2 Tcl automation and packaged all six custom AXI4-Lite peripherals as local reusable IP.

Created:

- `vivado/scripts/package_common_custom_ip.tcl`
- `vivado/scripts/package_all_custom_ip.tcl`
- `vivado/scripts/package_axi_gpio_core.tcl`
- `vivado/scripts/package_axi_fnd_core.tcl`
- `vivado/scripts/package_axi_timer_core.tcl`
- `vivado/scripts/package_axi_sensor_core.tcl`
- `vivado/scripts/package_axi_spi_core.tcl`
- `vivado/scripts/package_axi_i2c_core.tcl`
- `vivado/ip_repo/axi_gpio_core`
- `vivado/ip_repo/axi_fnd_core`
- `vivado/ip_repo/axi_timer_core`
- `vivado/ip_repo/axi_sensor_core`
- `vivado/ip_repo/axi_spi_core`
- `vivado/ip_repo/axi_i2c_core`
- `docs/report_assets/custom_ip_packaging_report.md`

Final packaging run:

- Command: `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/package_all_custom_ip.tcl`
- Result: PASS
- IP catalog refresh: PASS
- Log copy: `vivado/ip_repo/package_all_custom_ip_20260622_225119_vivado.log`

No RTL wrappers or reference RTL files were modified. No MicroBlaze block design, bitstream, Vitis workspace, C software, or UVM environment was created.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass. After Prompt 20, the immediate integration path is to create the MicroBlaze Basys3 block design using the packaged local IP.

Next recommended milestone:

1. Proceed to Prompt 21: Create MicroBlaze Basys3 block design using packaged local IP.

## Prompt 21 MicroBlaze Block Design Status Update

Prompt 21 created the Basys3-targeted MicroBlaze AXI4-Lite block design using the packaged local custom IP repository.

Created:

- `vivado/scripts/create_microblaze_basys3_bd.tcl`
- `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.xpr`
- `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.srcs/sources_1/bd/microblaze_axi_soc_bd/microblaze_axi_soc_bd.bd`
- `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.gen/sources_1/bd/microblaze_axi_soc_bd/hdl/microblaze_axi_soc_bd_wrapper.v`
- `docs/report_assets/microblaze_bd_creation_report.md`
- `docs/integration/MICROBLAZE_BD_SUMMARY.md`
- `docs/integration/BD_EXTERNAL_PORT_SUMMARY.md`
- `docs/integration/BD_ADDRESS_MAP_VERIFICATION.md`
- `docs/integration/BD_NEXT_STEPS.md`

Final run:

- Command: `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/create_microblaze_basys3_bd.tcl`
- Result: PASS
- `validate_bd_design`: PASS
- Address map: PASS for AXI UART Lite and all six custom IPs
- HDL wrapper: generated

No RTL wrappers or reference RTL files were modified. No XDC pin map, synthesis, implementation, bitstream, hardware export, Vitis workspace, C software, UVM environment, or board demo was created.

Next recommended milestone:

1. Proceed to Prompt 22: Basys3 XDC pin mapping and constraints preparation.


## Prompt 22 Basys3 XDC Constraint Status Update

Prompt 22 created and applied the Basys3 XDC constraints for the MicroBlaze AXI4-Lite SoC.

Created:

- `constraints/basys3/basys3_axi_soc.xdc`
- `vivado/scripts/apply_basys3_xdc.tcl`
- `docs/integration/BASYS3_XDC_PIN_MAP.md`
- `docs/integration/BASYS3_RESET_POLICY.md`
- `docs/report_assets/basys3_xdc_constraints_report.md`

Validation:

- Command: `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/apply_basys3_xdc.tcl`
- Result: PASS
- XDC added to `constrs_1`: PASS
- `validate_bd_design`: PASS
- XDC port existence and duplicate pin checks: PASS

Reset policy changed from the Prompt 21 active-high external reset assumption to an active-low external reset topology with BD cell `rstn_inv_0` before `proc_sys_reset_0/ext_reset_in`. Prompt 23 superseded the earlier CPU_RESETN/C12 pin assignment with PMOD JA4/G2 after Vivado rejected C12 for the selected part.

No RTL wrappers or reference RTL files were modified. No synthesis, implementation, bitstream, XSA export, Vitis workspace, user MicroBlaze C application, UVM environment, or board demo was created.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.

Next recommended milestone:

1. Proceed to Prompt 23: Synthesis, implementation, bitstream generation, and hardware export preparation.

## Prompt 22 v1 Reset Revision Support Status Update

Prompt 22 v1 reset revision support is complete.

Additional created files:

- `constraints/basys3/reset_options/README.md`
- `constraints/basys3/reset_options/reset_cpu_resetn_c12.xdc`
- `constraints/basys3/reset_options/reset_external_pmod_template.xdc`
- `docs/integration/BASYS3_RESET_REVISION_GUIDE.md`

The current reset assignment is external PMOD JA4/G2 active-low through `rstn_inv_0`; CPU_RESETN/C12 is historical only after the Prompt 23 Vivado pin rejection. The final apply script validates the existing reset topology without unnecessarily regenerating the wrapper when no BD change is needed.

Final revised validation:

- Command: `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/apply_basys3_xdc.tcl`
- Result: PASS
- Final revised log warnings/errors: none

No synthesis, implementation, bitstream, XSA export, Vitis workspace, user MicroBlaze C application, UVM environment, board demo, RTL change, or reference RTL change was made.

Next recommended milestone:

1. Proceed to Prompt 23: Synthesis, implementation, bitstream generation, and hardware export preparation.

## Prompt 23 Bitstream/XSA Status Update

Prompt 23 completed the first integrated Basys3 bitstream and XSA export for the MicroBlaze AXI4-Lite SoC.

Created:

- `vivado/scripts/build_microblaze_basys3_bitstream.tcl`
- `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.bit`
- `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.xsa`
- `docs/report_assets/bitstream_build_report.md`
- `docs/integration/BITSTREAM_AND_XSA_SUMMARY.md`
- `docs/integration/POST_BITSTREAM_NEXT_STEPS.md`

Final build:

- Command: `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/build_microblaze_basys3_bitstream.tcl`
- Result: PASS
- Synthesis: PASS
- Implementation: PASS
- Timing: WNS `1.772 ns`, TNS `0.000 ns`, WHS `0.023 ns`
- DRC: 0 errors, 0 critical warnings, 11 warnings
- XSA includes bitstream: yes

Prompt 23 also revised the reset pin assignment from CPU_RESETN/C12 to external PMOD JA4/G2 active-low reset because Vivado rejected C12 for the selected part. No RTL, reference RTL, Vitis workspace, user MicroBlaze C software, UVM environment, board programming, or board demo was created.

The UVM policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass; after bitstream generation, the immediate next work should be Vitis/BSP/software preparation, not UVM.

Next recommended milestone:

1. Proceed to Prompt 24: Vitis/BSP and bare-metal software preparation using `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.xsa`.


## Prompt 24 Vitis Software Skeleton Status Update

Prompt 24 created the MicroBlaze standalone UART command software skeleton and repeatable Vitis/XSCT scripts.

Created:

- `sw/src/main.c`
- `sw/src/axi_soc_hw.h`
- `sw/src/axi_soc_regs.h`
- `sw/src/uart_console.c` and `sw/src/uart_console.h`
- `sw/src/command_parser.c` and `sw/src/command_parser.h`
- `sw/src/periph_gpio.c` and `sw/src/periph_gpio.h`
- `sw/src/periph_fnd.c` and `sw/src/periph_fnd.h`
- `sw/src/periph_timer.c` and `sw/src/periph_timer.h`
- `sw/src/periph_sensor.c` and `sw/src/periph_sensor.h`
- `sw/src/periph_spi.c` and `sw/src/periph_spi.h`
- `sw/src/periph_i2c.c` and `sw/src/periph_i2c.h`
- `sw/scripts/create_vitis_workspace.tcl`
- `sw/scripts/build_software.tcl`
- `sw/scripts/create_and_build_software.bat`

Build status:

- XSCT/Vitis 2020.2 was not found at the required candidate paths.
- Vitis platform/BSP/app generation was not run.
- No ELF was generated.
- Board programming and UART smoke testing remain future steps.

Policy remains unchanged: UVM is deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass, and it should not be started during this software bring-up step.

## Prompt 24.5 Software Build Gate Status Update

Prompt 24.5 searched likely Xilinx installation roots for `xsct.bat`. Only 2024.2 XSCT paths were found, so the MicroBlaze software build was intentionally not run.

Created:

- `docs/integration/VITIS_INSTALLATION_REQUIRED.md`
- `docs/report_assets/software_static_check_report.md`

Updated:

- `docs/report_assets/vitis_software_build_report.md`
- `docs/integration/VITIS_WORKSPACE_SUMMARY.md`
- `docs/integration/BOARD_BRINGUP_CHECKLIST.md`

Current gate:

- Install or provide Vitis/XSCT 2020.2 before building the standalone UART command app.
- Do not proceed to board programming or UART smoke testing until an ELF exists.

The UVM policy remains unchanged: UVM is deferred and was not created during this software build gate step.

Prompt 24.5 wrapper correction: `sw/scripts/create_and_build_software.bat` now checks both `D:` and `C:` XSCT/Vitis 2020.2 candidate paths. No 2024.2 path was added, and the wrapper was verified to stop before launching any XSCT when 2020.2 is absent.

## Vitis 2020.2 Software Build Completion Status Update

Vitis/XSCT 2020.2 is now installed at `D:\Xilinx\Vitis\2020.2\bin\xsct.bat` and the MicroBlaze standalone UART command app build passed.

Generated:

- `sw/vitis_workspace/microblaze_axi_soc_platform`
- `sw/vitis_workspace/axi_soc_uart_app`
- `sw/vitis_workspace/axi_soc_uart_app/Debug/axi_soc_uart_app.elf`

Next recommended milestone:

1. Proceed to Prompt 25: board programming and UART smoke test.
2. Use the Prompt 23 bitstream and the generated ELF.
3. Continue to avoid RTL, BD, bitstream, or XSA changes unless board testing proves a real issue.

UVM remains deferred and was not created during the software build step.

## Prompt 25A Offline Board Bring-up Package Status Update

Prompt 25A prepared the offline Basys3 board bring-up package only. The Basys3 board is not currently connected, so no hardware target detection, programming, ELF download, processor start, or UART smoke test was attempted.

Created:

- `hw/scripts/program_fpga_and_elf.tcl`
- `hw/scripts/program_fpga_and_elf.bat`
- `hw/scripts/list_hw_targets.tcl`
- `hw/scripts/list_hw_targets.bat`
- `hw/scripts/uart_smoke_test_sequence.txt`
- `hw/docs/BOARD_CONNECTION_GUIDE.md`
- `hw/docs/RESET_WIRING_GUIDE.md`
- `hw/docs/UART_TERMINAL_GUIDE.md`
- `hw/docs/BOARD_PROGRAMMING_MANUAL_STEPS.md`
- `hw/docs/UART_SMOKE_TEST_SEQUENCE.md`
- `hw/package/BOARD_READY_MANIFEST.md`
- `hw/package/checksums_sha256.txt`
- `docs/report_assets/offline_board_package_report.md`
- `docs/report_assets/board_programming_report.md`
- `docs/report_assets/uart_smoke_test_report.md`

Next recommended milestone:

1. When the board is available, run `hw/scripts/list_hw_targets.bat`.
2. Run `hw/scripts/program_fpga_and_elf.bat`.
3. Perform the UART smoke test using `hw/scripts/uart_smoke_test_sequence.txt`.

UVM remains deferred and was not created.
