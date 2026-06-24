# Traceability Matrix

This matrix is a living planning document. Prompt 7.5 moved the current project into canonical root D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC; the parent directory remains the Git root and may contain other projects. Prompt 7 completes the `axi_timer_core` specification package and creates `docs/AXI4_LITE_SOC_FILE_INDEX.md` to separate AXI4-Lite SoC project files from unrelated root-folder contents. GPIO, FND, Timer, Sensor, SPI, and I2C all have passing basic Vivado 2020.2 simulation baselines. Prompt 20 packaged all six custom AXI4-Lite peripherals as local Vivado IP under `vivado/ip_repo`.

UVM is planned as a separate later verification process after all custom AXI4-Lite peripherals are implemented and each peripheral has basic Vivado simulation coverage.

## Status Legend

| Status | Meaning |
| --- | --- |
| `Planned` | Artifact or work item is expected but not created yet. |
| `Reference audited` | Existing source was inspected and left unchanged. |
| `Created` | Documentation or editable source asset exists. |
| `Spec complete` | Register/software/verification specification exists. |
| `RTL implemented` | RTL source exists. |
| `Simulation created` | Simulation files exist, but may not have been run. |
| `Simulation passed` | Simulation was run and passed. |
| `Simulation failed` | Simulation was run and failed. |
| `Packaged as local IP` | Vivado IP packager generated a local reusable IP with component metadata. |
| `Deferred` | Planned for a later project phase, not the next immediate step. |
| `Not started` | Implementation or verification work intentionally not begun. |

## Global AXI Address Map

| Base address | Range | IP/peripheral | Status | Documentation |
| --- | --- | --- | --- | --- |
| `0x4060_0000` | 64 KB | AXI UART Lite | Planned, confirm in Vivado Address Editor | `docs/specs/AXI_ADDRESS_MAP.md` |
| `0x44A0_0000` | 64 KB | `axi_gpio_core` | RTL implemented; Simulation passed in Vivado 2020.2; Packaged as local IP | `docs/specs/AXI_ADDRESS_MAP.md`, `docs/specs/axi_gpio_core_SPEC.md` |
| `0x44A1_0000` | 64 KB | `axi_fnd_core` | RTL implemented; Simulation passed in Vivado 2020.2; Packaged as local IP | `docs/specs/AXI_ADDRESS_MAP.md`, `docs/specs/axi_fnd_core_SPEC.md` |
| `0x44A2_0000` | 64 KB | `axi_timer_core` | RTL implemented; Simulation passed in Vivado 2020.2; Packaged as local IP | `docs/specs/AXI_ADDRESS_MAP.md`, `docs/specs/axi_timer_core_SPEC.md` |
| `0x44A3_0000` | 64 KB | `axi_sensor_core` | RTL implemented; Simulation passed in Vivado 2020.2; Packaged as local IP | `docs/specs/AXI_ADDRESS_MAP.md`, `docs/specs/axi_sensor_core_SPEC.md` |
| `0x44A4_0000` | 64 KB | `axi_spi_core` | RTL implemented; Simulation passed in Vivado 2020.2; Packaged as local IP | `docs/specs/AXI_ADDRESS_MAP.md`, `docs/specs/axi_spi_core_SPEC.md` |
| `0x44A5_0000` | 64 KB | `axi_i2c_core` | RTL implemented; Simulation passed in Vivado 2020.2; Packaged as local IP | `docs/specs/AXI_ADDRESS_MAP.md`, `docs/specs/axi_i2c_core_SPEC.md` |

## Peripheral Traceability

| Peripheral | Planned base | Wrapper file | Reused/adapted RTL files | Spec docs | Vivado simulation | UVM files | Board demo status | Diagram/WaveDrom assets | Current status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `axi_gpio_core` | `0x44A0_0000` | `rtl_work/axi_peripherals/axi_gpio_core/hdl/axi_gpio_core.v` | Original `button_debounce.v` inspected and unchanged; adapted `rtl_work/legacy_adapted/button_debounce_level/button_debounce_level.v` created for level+pulse outputs | `docs/specs/axi_gpio_core_SPEC.md`, `docs/specs/axi_gpio_core_VERIFICATION_PLAN.md`, `docs/specs/axi_gpio_core_SOFTWARE_COMMANDS.md` | `sim/vivado/axi_gpio_core/tb_axi_gpio_core.sv`, `sim/vivado/axi_gpio_core/run_axi_gpio_core_sim.tcl`, `docs/report_assets/axi_gpio_core_vivado_sim_report.md`; Simulation passed in Vivado 2020.2 with `PASS tests_passed=12 errors=0` | `uvm/axi_gpio_core_uvm/*` planned/deferred until all custom peripherals have basic Vivado simulation results | Planned for Basys3 LED/switch/button check | `docs/diagrams/axi_gpio_core_wrapper.drawio`, `docs/wavedrom/axi_gpio_write_read.json`, `docs/wavedrom/axi_gpio_button_edge.json`, `docs/rtl_views/axi_gpio_core_hierarchy.md` | RTL implemented; Vivado simulation passed; UVM/board not started |
| `axi_fnd_core` | `0x44A1_0000` | `rtl_work/axi_peripherals/axi_fnd_core/hdl/axi_fnd_core.v` | Reference `fnd_controller.v` inspected and reusable as-is; reference file unchanged; wrapper instantiates `u_fnd_controller` | `docs/specs/axi_fnd_core_SPEC.md`, `docs/specs/axi_fnd_core_VERIFICATION_PLAN.md`, `docs/specs/axi_fnd_core_SOFTWARE_COMMANDS.md` | `sim/vivado/axi_fnd_core/tb_axi_fnd_core.sv`, `sim/vivado/axi_fnd_core/run_axi_fnd_core_sim.tcl`, `docs/report_assets/axi_fnd_core_vivado_sim_report.md`; Simulation passed in Vivado 2020.2 with `PASS tests_passed=16 errors=0` | `uvm/axi_fnd_core_uvm/*` planned/deferred until all custom peripherals have basic Vivado simulation results | Planned for Basys3 FND check | `docs/diagrams/axi_fnd_core_wrapper.drawio`, `docs/wavedrom/axi_fnd_register_update.json`, `docs/wavedrom/axi_fnd_enable_disable.json`, `docs/rtl_views/axi_fnd_core_reuse_notes.md`, `docs/rtl_views/axi_fnd_core_hierarchy.md` | RTL implemented; Vivado simulation passed; UVM deferred; board not started |
| `axi_timer_core` | `0x44A2_0000` | `rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v` | Directly instantiates `stopwatch_datapath.v`, `watch_datapath.v`, and `watch_fnd_adapter.v`; reference-only: `top_control_unit.v`, `top_stopwatch_watch.v`; no adapted Timer copy | `docs/specs/axi_timer_core_SPEC.md`, `docs/specs/axi_timer_core_VERIFICATION_PLAN.md`, `docs/specs/axi_timer_core_SOFTWARE_COMMANDS.md`, `docs/rtl_views/axi_timer_core_reuse_notes.md` | `sim/vivado/axi_timer_core/tb_axi_timer_core.sv`, `sim/vivado/axi_timer_core/run_axi_timer_core_sim.tcl`, `sim/vivado/axi_timer_core/README.md`, `docs/report_assets/axi_timer_core_vivado_sim_report.md`; Simulation passed in Vivado 2020.2 with `PASS tests_passed=19 errors=0` | `uvm/axi_timer_core_uvm/*` planned/deferred until all custom peripherals have basic Vivado simulation results | Planned for stopwatch/watch UART command demo | `docs/diagrams/axi_timer_core_wrapper.drawio`, `docs/wavedrom/axi_timer_control_command.json`, `docs/wavedrom/axi_timer_watch_edit.json`, `docs/wavedrom/axi_timer_read_values.json`, `docs/rtl_views/axi_timer_core_hierarchy.md` | RTL implemented; Vivado simulation passed; UVM deferred; board not started |
| `axi_sensor_core` | `0x44A3_0000` | `rtl_work/axi_peripherals/axi_sensor_core/hdl/axi_sensor_core.v` | Directly instantiates `sr04.v` and `dht11.v`; no adapted Sensor copy | `docs/specs/axi_sensor_core_SPEC.md`, `docs/specs/axi_sensor_core_VERIFICATION_PLAN.md`, `docs/specs/axi_sensor_core_SOFTWARE_COMMANDS.md`, `docs/rtl_views/axi_sensor_core_reuse_notes.md` | `sim/vivado/axi_sensor_core/tb_axi_sensor_core.sv`, `sim/vivado/axi_sensor_core/run_axi_sensor_core_sim.tcl`, `sim/vivado/axi_sensor_core/README.md`, `docs/report_assets/axi_sensor_core_vivado_sim_report.md`; Simulation passed in Vivado 2020.2 with `PASS tests_passed=17 errors=0` | `uvm/axi_sensor_core_uvm/*` planned/deferred until all custom peripherals have basic Vivado simulation results | Planned for DHT11/SR04 Basys3 external sensor demo | `docs/diagrams/axi_sensor_core_wrapper.drawio`, `docs/wavedrom/axi_sensor_command_status.json`, `docs/wavedrom/axi_sensor_sr04_echo.json`, `docs/wavedrom/axi_sensor_dht11_start.json`, `docs/rtl_views/axi_sensor_core_hierarchy.md` | RTL implemented; Vivado simulation passed; UVM deferred; board not started |
| `axi_spi_core` | `0x44A4_0000` | `rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v` | Directly instantiates `spi_master_byte.sv` as `u_spi_master_byte`; `spi_slave_byte.sv` remains optional/reference-only and uncompiled; reference files unchanged | `docs/specs/axi_spi_core_SPEC.md`, `docs/specs/axi_spi_core_VERIFICATION_PLAN.md`, `docs/specs/axi_spi_core_SOFTWARE_COMMANDS.md`, `docs/rtl_views/axi_spi_core_reuse_notes.md`, `docs/rtl_views/axi_spi_core_hierarchy.md` | `sim/vivado/axi_spi_core/tb_axi_spi_core.sv`, `sim/vivado/axi_spi_core/run_axi_spi_core_sim.tcl`, `sim/vivado/axi_spi_core/README.md`, `docs/report_assets/axi_spi_core_vivado_sim_report.md`; Simulation passed in Vivado 2020.2 with `PASS tests_passed=20 errors=0` | `uvm/axi_spi_core_uvm/*` planned/deferred until all custom peripherals have basic Vivado simulation results | Planned for loopback or external SPI device check | `docs/diagrams/axi_spi_core_wrapper.drawio`, `docs/wavedrom/axi_spi_transaction.json`, `docs/wavedrom/axi_spi_control_status.json` | RTL implemented; Vivado simulation passed; UVM deferred; board not started |
| `axi_i2c_core` | `0x44A5_0000` | `rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v` | Directly instantiates `i2c_master_core.sv` as `u_i2c_master_core`; `i2c_slave_core.sv` remains optional/reference-only, uninstantiated, and uncompiled; reference files unchanged | `docs/specs/axi_i2c_core_SPEC.md`, `docs/specs/axi_i2c_core_VERIFICATION_PLAN.md`, `docs/specs/axi_i2c_core_SOFTWARE_COMMANDS.md`, `docs/rtl_views/axi_i2c_core_reuse_notes.md`, `docs/rtl_views/axi_i2c_core_hierarchy.md` | `sim/vivado/axi_i2c_core/tb_axi_i2c_core.sv`, `sim/vivado/axi_i2c_core/run_axi_i2c_core_sim.tcl`, `sim/vivado/axi_i2c_core/README.md`, `docs/report_assets/axi_i2c_core_vivado_sim_report.md`; Simulation passed in Vivado 2020.2 with `PASS tests_passed=23 errors=0` | `uvm/axi_i2c_core_uvm/*` planned/deferred until all custom peripherals have basic Vivado simulation results | Planned for I2C device or board-to-board check; board not started | `docs/diagrams/axi_i2c_core_wrapper.drawio`, `docs/wavedrom/axi_i2c_command_status.json`, `docs/wavedrom/axi_i2c_write_byte.json`, `docs/wavedrom/axi_i2c_read_byte.json` | RTL implemented; Vivado simulation passed; UVM deferred; board not started |
| Optional custom UART | TBD | Not planned for initial system | `uart.v`, `fifo.v`, optional `ASCII_decoder.v`, `ASCII_sender.v` | Future optional spec only if requested | Future optional simulation | Future optional UVM, deferred | Not part of initial MicroBlaze PC console | Legacy UART/reference diagram if needed | Reference audited; intentionally deferred |

## Documentation Traceability

| Document or asset | Purpose | Status |
| --- | --- | --- |
| `docs/AXI4_LITE_SOC_FILE_INDEX.md` | Master project-owned file index | Created in Prompt 7 |
| `docs/specs/AXI_ADDRESS_MAP.md` | Global planned AXI address map | Created in Prompt 1 |
| `docs/specs/AXI_REGISTER_CONVENTIONS.md` | Shared AXI register behavior policy | Created in Prompt 1 |
| `docs/specs/axi_gpio_core_SPEC.md` | Complete GPIO peripheral spec | Created in Prompt 1 |
| `docs/specs/axi_gpio_core_VERIFICATION_PLAN.md` | GPIO simulation/UVM/board verification plan | Created in Prompt 1 |
| `docs/specs/axi_gpio_core_SOFTWARE_COMMANDS.md` | GPIO UART command plan | Created in Prompt 1 |
| `docs/rtl_views/axi_gpio_core_reuse_notes.md` | GPIO source reuse and debounce notes | Updated in Prompt 2 |
| `docs/rtl_views/axi_gpio_core_hierarchy.md` | GPIO RTL hierarchy and signal mapping | Created in Prompt 2 |
| `sim/vivado/axi_gpio_core/tb_axi_gpio_core.sv` | Directed Vivado/xsim behavioral testbench | Created in Prompt 3 |
| `sim/vivado/axi_gpio_core/run_axi_gpio_core_sim.tcl` | Vivado 2020.2 batch simulation script | Created in Prompt 3 |
| `sim/vivado/axi_gpio_core/README.md` | GPIO simulation run instructions | Created in Prompt 3 |
| `docs/report_assets/axi_gpio_core_vivado_sim_report.md` | GPIO Vivado simulation report | Created in Prompt 3; updated in Prompt 3.6 with passing result |
| `docs/specs/axi_fnd_core_SPEC.md` | Complete FND peripheral spec | Created in Prompt 4 |
| `docs/specs/axi_fnd_core_VERIFICATION_PLAN.md` | FND future Vivado simulation plan | Created in Prompt 4 |
| `docs/specs/axi_fnd_core_SOFTWARE_COMMANDS.md` | FND UART command plan | Created in Prompt 4 |
| `docs/rtl_views/axi_fnd_core_reuse_notes.md` | FND source reuse and controller inspection notes | Created in Prompt 4; updated in Prompt 5 |
| `docs/rtl_views/axi_fnd_core_hierarchy.md` | FND RTL hierarchy and register-to-port mapping | Created in Prompt 5 |
| `docs/diagrams/axi_fnd_core_wrapper.drawio` | FND wrapper editable block diagram | Created in Prompt 4 |
| `docs/wavedrom/axi_fnd_register_update.json` | FND register update timing intent | Created in Prompt 4 |
| `docs/wavedrom/axi_fnd_enable_disable.json` | FND enable/disable timing intent | Created in Prompt 4 |
| `sim/vivado/axi_fnd_core/tb_axi_fnd_core.sv` | Directed Vivado/xsim FND behavioral testbench | Created in Prompt 6 |
| `sim/vivado/axi_fnd_core/run_axi_fnd_core_sim.tcl` | Vivado 2020.2 FND batch simulation script | Created in Prompt 6 |
| `sim/vivado/axi_fnd_core/README.md` | FND simulation run instructions | Created in Prompt 6 |
| `docs/report_assets/axi_fnd_core_vivado_sim_report.md` | FND Vivado simulation report | Created in Prompt 6 with passing result |
| `docs/specs/axi_timer_core_SPEC.md` | Complete Timer peripheral spec | Created in Prompt 7 |
| `docs/specs/axi_timer_core_VERIFICATION_PLAN.md` | Timer future Vivado simulation plan | Created in Prompt 7 |
| `docs/specs/axi_timer_core_SOFTWARE_COMMANDS.md` | Timer UART command plan | Created in Prompt 7 |
| `docs/rtl_views/axi_timer_core_reuse_notes.md` | Timer source reuse inspection notes | Created in Prompt 7; updated in Prompt 8 |
| `docs/rtl_views/axi_timer_core_hierarchy.md` | Timer RTL hierarchy and register-to-port mapping | Created in Prompt 8 |
| `rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v` | Timer AXI4-Lite RTL wrapper | Created in Prompt 8 |
| `sim/vivado/axi_timer_core/tb_axi_timer_core.sv` | Directed Vivado/xsim Timer behavioral testbench | Created in Prompt 9 |
| `sim/vivado/axi_timer_core/run_axi_timer_core_sim.tcl` | Vivado 2020.2 Timer batch simulation script | Created in Prompt 9 |
| `sim/vivado/axi_timer_core/README.md` | Timer simulation run instructions | Created in Prompt 9 |
| `sim/vivado/axi_timer_core/axi_timer_core_sim_result.txt` | Timer simulation result | `PASS tests_passed=19 errors=0` |
| `sim/vivado/axi_timer_core/logs/*` | Timer Vivado/xsim logs | Preserved from Prompt 9 runs |
| `docs/report_assets/axi_timer_core_vivado_sim_report.md` | Timer Vivado simulation report | Created in Prompt 9 with passing result |

## Prompt 9 Timer Simulation Status

- `axi_timer_core` Vivado 2020.2 simulation passed.
- Result: `PASS tests_passed=19 errors=0`.
- Simulation files: `sim/vivado/axi_timer_core/tb_axi_timer_core.sv`, `sim/vivado/axi_timer_core/run_axi_timer_core_sim.tcl`, and `sim/vivado/axi_timer_core/README.md`.
- Report: `docs/report_assets/axi_timer_core_vivado_sim_report.md`.
- Fast tick strategy: testbench-only `defparam` overrides set both reused 100 Hz generators to `F_COUNT = 8`.
- Reference Timer RTL remained unchanged and no adapted Timer copy was created.
- `axi_timer_core.v` was not modified during Prompt 9 simulation debugging.
- UVM remains deferred and board demo remains not started.

## Unattended Phase A Sensor Specification Status

- `axi_sensor_core` specification package created from direct inspection of `sr04.v` and `dht11.v`.
- Sensor base address remains `0x44A3_0000`.
- First wrapper external pins: `sr04_echo_i`, `sr04_trig_o`, and `dht11_io`.
- `dht11.led` is documented as `dht_valid_live`.
- No reference Sensor RTL was modified.
- UVM, MicroBlaze software, and Vivado block design remain uncreated.

## Unattended Phase B Sensor RTL Status

- `axi_sensor_core` RTL wrapper created at `rtl_work/axi_peripherals/axi_sensor_core/hdl/axi_sensor_core.v`.
- Wrapper directly instantiates `u_sr04` and `u_dht11`.
- No adapted Sensor copy was created.
- Reference Sensor RTL remained unchanged.
- Sensor remains decoupled from FND.
- Sensor Vivado simulation is not started.

## Unattended Sensor/SPI Batch Status

- Sensor specification, RTL, and Vivado 2020.2 simulation are complete.
- Sensor simulation result: `PASS tests_passed=17 errors=0`.
- SPI specification package is complete.
- SPI RTL, SPI simulation, UVM, MicroBlaze software, and Vivado block design remain intentionally not started.

## Prompt 14 SPI RTL Status

- `axi_spi_core` RTL wrapper created at `rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v`.
- Wrapper directly instantiates `spi_master_byte` as `u_spi_master_byte`.
- `spi_slave_byte` remains optional/reference-only and is not instantiated.
- `CLKDIV` readback preserves the stored value, while `clk_div_to_master` clamps `16'h0000` to `16'h0001`.
- SPI simulation, UVM, MicroBlaze software, Vivado block design, and board demo remain not started.

## Prompt 15 SPI Simulation Status

- `axi_spi_core` Vivado 2020.2 simulation passed.
- Result: `PASS tests_passed=20 errors=0`.
- Simulation files: `sim/vivado/axi_spi_core/tb_axi_spi_core.sv`, `sim/vivado/axi_spi_core/run_axi_spi_core_sim.tcl`, and `sim/vivado/axi_spi_core/README.md`.
- Report: `docs/report_assets/axi_spi_core_vivado_sim_report.md`.
- The simulation compiled `spi_master_byte.sv`, `axi_spi_core.v`, and `tb_axi_spi_core.sv` only.
- `spi_slave_byte.sv` remained optional/reference-only and uncompiled.
- Reference SPI RTL remained unchanged.
- No SPI RTL fixes were required.
- UVM remains deferred and board demo remains not started.
## Prompt 16 I2C Specification Status

- `axi_i2c_core` specification package is complete.
- Base address: `0x44A5_0000`; high address: `0x44A5_FFFF`; range: 64 KB.
- Planned wrapper path: `rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v`.
- Direct reuse candidate: `axi_project_unique_sources/sources/i2c_master_core.sv`.
- Optional/reference-only file: `axi_project_unique_sources/sources/i2c_slave_core.sv`.
- Planned Vivado simulation path: `sim/vivado/axi_i2c_core/tb_axi_i2c_core.sv` and `sim/vivado/axi_i2c_core/run_axi_i2c_core_sim.tcl`.
- Diagram and WaveDrom assets created for wrapper structure, command/status timing, write-byte timing, and read-byte timing.
- Status after Prompt 17: RTL implemented; simulation not started; UVM deferred; board not started.
## Prompt 17 I2C RTL Status

- `axi_i2c_core` RTL wrapper created at `rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v`.
- Wrapper directly instantiates `i2c_master_core` as `u_i2c_master_core`.
- `i2c_slave_core.sv` remains optional/reference-only and is not instantiated.
- Open-drain `i2c_scl_io` and `i2c_sda_io` are implemented with drive-low-or-high-Z assignments.
- `COMMAND` writes generate one-clock `i2c_cmd_valid_pulse` only when enabled, ready, strobed, and nonzero.
- Command priority is START, STOP, WRITE_BYTE, READ_BYTE.
- `done_sticky` and `nack_sticky` are implemented and clear on a new accepted command.
- Reference I2C RTL remained unchanged.
- I2C simulation, UVM, MicroBlaze software, Vivado block design, and board demo remain not started.
## Prompt 18 I2C Simulation Status

- `axi_i2c_core` Vivado 2020.2 simulation passed.
- Result: `PASS tests_passed=23 errors=0`.
- Simulation files: `sim/vivado/axi_i2c_core/tb_axi_i2c_core.sv`, `sim/vivado/axi_i2c_core/run_axi_i2c_core_sim.tcl`, and `sim/vivado/axi_i2c_core/README.md`.
- Report: `docs/report_assets/axi_i2c_core_vivado_sim_report.md`.
- The simulation compiled `i2c_master_core.sv`, `axi_i2c_core.v`, and `tb_axi_i2c_core.sv` only.
- `i2c_slave_core.sv` remained optional/reference-only and uncompiled.
- Reference I2C RTL remained unchanged.
- No I2C RTL, testbench, or Tcl fixes were required.
- UVM remains deferred and board demo remains not started.
## Prompt 19 Baseline Review And Integration Preparation Status

- Full custom peripheral regression script created: `sim/vivado/run_all_peripheral_sims.ps1`.
- Full regression was run with Vivado 2020.2 and passed for all six custom AXI4-Lite peripherals.
- Fresh regression report: `docs/report_assets/full_peripheral_regression_report.md`.
- Baseline review report: `docs/report_assets/custom_peripheral_baseline_review.md`.
- Integration preparation docs created under `docs/integration/`.
- Optional integration diagram and WaveDrom command-flow source created.
- All six custom peripherals have RTL implemented and Vivado simulation passed.
- Local Vivado IP packaging is not started.
- MicroBlaze block design is not started.
- MicroBlaze software is not started.
- UVM remains deferred.
- Board demo and final XDC mapping are not started.


## Prompt 20 Custom IP Packaging Status

- All six custom AXI4-Lite peripherals are packaged as local Vivado IP under `vivado/ip_repo`.
- Packaging command: `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/package_all_custom_ip.tcl`
- Packaging result: PASS.
- Local IP catalog refresh result: PASS.
- Component metadata exists for `axi_gpio_core`, `axi_fnd_core`, `axi_timer_core`, `axi_sensor_core`, `axi_spi_core`, and `axi_i2c_core`.
- MicroBlaze block design is not started.
- MicroBlaze software is not started.
- UVM remains deferred.
- Reference RTL remained unchanged.

## Prompt 21 MicroBlaze Block Design Status

- MicroBlaze Basys3 Vivado project created at `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.xpr`.
- Block design `microblaze_axi_soc_bd` created.
- `validate_bd_design` passed in Vivado 2020.2.
- SmartConnect connects MicroBlaze to AXI UART Lite and all six custom packaged local IPs.
- Address map exactly matches `docs/specs/AXI_ADDRESS_MAP.md`.
- HDL wrapper was generated.
- Bitstream, synthesis, implementation, XDC exact pin mapping, hardware export, Vitis/software, UVM, and board demo remain not started.
- Prompt 21 normalized generated packaged IP `component.xml` clock-association metadata; RTL and packaged HDL source files remained unchanged.


## Prompt 22 Basys3 XDC Constraint Status

- Basys3 XDC created at `constraints/basys3/basys3_axi_soc.xdc`.
- XDC applied to Vivado project `constrs_1` with Vivado 2020.2.
- Exact pin mapping prepared for clock, CPU_RESETN reset, UART, GPIO switches/LEDs/buttons, FND, Sensor PMOD JA, SPI PMOD JB, and I2C PMOD JC.
- `validate_bd_design` passed after applying constraints.
- Reset policy updated: `reset_i` maps to CPU_RESETN C12 active-low and passes through BD inverter `rstn_inv_0` before `proc_sys_reset_0/ext_reset_in`.
- HDL wrapper was regenerated; top-level port names remained unchanged.
- Synthesis, implementation, bitstream, XSA export, Vitis/user software, UVM, and board demo remain not started.
- RTL and reference RTL remained unchanged.

## Prompt 22 v1 Revisable Basys3 XDC Addendum

- Reset option snippets created under `constraints/basys3/reset_options/`.
- Reset revision guide created at `docs/integration/BASYS3_RESET_REVISION_GUIDE.md`.
- First-pass reset remains CPU_RESETN C12 active-low through BD inverter `rstn_inv_0`.
- External PMOD reset option is documented as a commented template only and is not applied by default.
- Final revised apply script is idempotent: if the reset BD topology is already correct, it validates and reports without regenerating the wrapper.
- Final revised Vivado 2020.2 run passed with no final `ERROR:`, `CRITICAL WARNING:`, or `WARNING:` log lines.
- Bitstream, synthesis, implementation, XSA export, Vitis/user software, UVM, and board demo remain not started.

## Prompt 23 Bitstream And XSA Status

- Basys3 MicroBlaze AXI4-Lite SoC synthesis, implementation, bitstream generation, and XSA export passed in Vivado 2020.2.
- Command: `D:\Xilinx\Vivado\2020.2\bin\vivado.bat -mode batch -source vivado/scripts/build_microblaze_basys3_bitstream.tcl`
- Build script: `vivado/scripts/build_microblaze_basys3_bitstream.tcl`.
- Bitstream: `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.bit`.
- XSA: `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.xsa`; includes `microblaze_axi_soc.bit`.
- Timing passed: WNS `1.772 ns`, TNS `0.000 ns`, WHS `0.023 ns`.
- DRC gate passed: 0 DRC errors, 0 DRC critical warnings, 11 DRC warnings.
- Reset pin assignment revised: `reset_i` now maps to external PMOD JA4/G2 active-low reset with `PULLUP true` because Vivado rejected CPU_RESETN/C12 for `xc7a35tcpg236-1`.
- RTL/reference RTL status: unchanged.
- Vitis workspace, user MicroBlaze software, UVM, board programming, and board demo: not created/not started.

## Prompt 24 Vitis Software Skeleton Status

- MicroBlaze standalone UART command software source tree created under `sw/src`.
- Vitis/XSCT automation created under `sw/scripts`.
- Vitis workspace directory `sw/vitis_workspace` exists as a placeholder only; platform/BSP/app objects were not generated because XSCT/Vitis 2020.2 was not found.
- Checked XSCT paths: `D:\Xilinx\Vitis\2020.2\bin\xsct.bat`, `D:\Xilinx\SDK\2020.2\bin\xsct.bat`, and `D:\Xilinx\Vivado\2020.2\bin\xsct.bat`; all missing.
- Software build status: blocked by missing XSCT/Vitis 2020.2; no ELF generated.
- Board demo status: not started; no FPGA programming or UART smoke test performed.
- RTL/reference RTL status: unchanged.
- UVM remains deferred until the software/board bring-up path is stable and until explicitly requested.

## Prompt 24.5 XSCT Discovery And Software Build Status

- Bounded XSCT search found only non-2020.2 tools:
  - `C:\Xilinx\Vitis\2024.2\bin\scripts\xsct.bat`
  - `C:\Xilinx\Vitis\2024.2\bin\xsct.bat`
  - `C:\Xilinx\Vivado\2024.2\xsct-trim\bin\xsct.bat`
- Selected XSCT path: none.
- Vitis/XSCT 2020.2 found: no.
- Software build status: not run; blocked by missing XSCT/Vitis 2020.2.
- ELF status: not generated.
- Static software source check: PASS; see `docs/report_assets/software_static_check_report.md`.
- Board programming and UART smoke testing remain blocked until an ELF exists.
- RTL, reference RTL, Vivado BD, bitstream, XSA, and UVM were not modified.

Prompt 24.5 wrapper correction: `sw/scripts/create_and_build_software.bat` now checks both `D:` and `C:` XSCT/Vitis 2020.2 candidate paths. No 2024.2 path was added, and the wrapper was verified to stop before launching any XSCT when 2020.2 is absent.

## Vitis 2020.2 Software Build Completion Status

- XSCT/Vitis 2020.2 found: `D:\Xilinx\Vitis\2020.2\bin\xsct.bat`.
- Build wrapper command passed: `cmd /c "D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC\sw\scripts\create_and_build_software.bat"`.
- Vitis workspace generated under `sw/vitis_workspace`.
- Platform generated from Prompt 23 XSA.
- Standalone BSP built for `microblaze_0`.
- Application `axi_soc_uart_app` built successfully.
- ELF generated: `sw/vitis_workspace/axi_soc_uart_app/Debug/axi_soc_uart_app.elf`.
- ELF size: 222,032 bytes; section summary `text=32152`, `data=1308`, `bss=3172`.
- Board programming and UART smoke testing remain not started.
- RTL, reference RTL, Vivado BD, bitstream, XSA, and UVM were not modified.

## Prompt 25A Offline Board Bring-up Package Status

- Offline board bring-up package prepared under `hw/`.
- Bitstream exists: `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.bit`.
- XSA exists: `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.xsa`.
- ELF exists: `sw/vitis_workspace/axi_soc_uart_app/Debug/axi_soc_uart_app.elf`.
- Programming scripts and manual UART smoke-test files created.
- Package manifest and SHA256 checksums created under `hw/package/`.
- Board programming status: not run - board unavailable.
- UART smoke test status: not run - board unavailable / COM port unavailable.
- Board demo status: not started; no board success claimed.
- RTL, reference RTL, Vivado BD, bitstream, XSA, ELF, and UVM were not modified.
- UVM remains deferred.
