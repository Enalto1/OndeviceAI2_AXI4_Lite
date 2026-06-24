# AXI4-Lite SoC File Index

## Purpose

This master index identifies the project-owned files for the current MicroBlaze AXI4-Lite SoC project after the Prompt 7.5 physical cleanup.

Canonical project root:

```text
D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC
```

Parent Git root:

```text
D:\OndeviceAI2_AXI4_Lite
```

The parent Git root may contain other projects and generated Vivado clutter. Paths in this document are project-root-relative unless explicitly marked as Git-root-relative.

## Project-Owned Top-Level Folders

| Folder | Purpose | Status |
| --- | --- | --- |
| `docs/` | Planning, specs, traceability, report assets, and editable diagram/timing sources. | Active |
| `docs/specs/` | Source-of-truth peripheral specifications and command plans. | Active |
| `docs/rtl_views/` | Reuse notes and RTL hierarchy notes. | Active |
| `docs/diagrams/` | Editable draw.io diagram sources. | Active |
| `docs/wavedrom/` | WaveDrom JSON timing sources. | Active |
| `docs/report_assets/` | Simulation reports and later presentation/report evidence. | Active |
| `rtl_work/` | Project-owned RTL implementation and adapted legacy copies. | Active |
| `rtl_work/axi_peripherals/` | Custom AXI4-Lite peripheral wrappers. | Active |
| `rtl_work/legacy_adapted/` | Clearly named adapted copies when reference RTL cannot be reused as-is. | Active |
| `sim/vivado/` | Focused Vivado 2020.2 behavioral simulations and evidence. | Active |
| `axi_project_unique_sources/` | Reference RTL archive. | Reference read-only |
| `UVM_testbench_ref/` | RAM UVM reference structure. | Deferred/reference-only |
| `_archive/root_vivado_logs/` | Archived Git-root Vivado logs from before Prompt 7.5 cleanup. | Archive |

## Git-Root Files

| Path | Purpose |
| --- | --- |
| `..\PROJECTS_INDEX.md` | Explains that the Git root contains multiple projects and identifies this canonical project root. |
| `..\.gitignore` | Ignores safe Vivado-generated clutter without hiding source/docs/simulation evidence. |

## Prompt History

| Prompt | Scope | Main outputs |
| --- | --- | --- |
| Prompt 0 | Planning/source audit | Source audit, reuse strategy, project plan, risk/debug notes, diagram asset plan. |
| Prompt 1 | Address map/GPIO spec | Global address map, register conventions, GPIO spec/software/verification docs, GPIO diagrams/WaveDrom. |
| Prompt 2 | GPIO RTL | `axi_gpio_core.v`, adapted debounce helper, GPIO hierarchy/reuse updates. |
| Prompt 3 | GPIO simulation bundle | GPIO Vivado testbench/Tcl/README/report created. |
| Prompt 3.5 | Flow policy | UVM deferred until all custom peripherals have RTL and basic Vivado simulation. |
| Prompt 3.6 | GPIO Vivado simulation | GPIO simulation passed in Vivado 2020.2 with `PASS tests_passed=12 errors=0`. |
| Prompt 4 | FND spec | FND spec/software/verification docs, reuse notes, diagram/WaveDrom assets. |
| Prompt 5 | FND RTL | `axi_fnd_core.v`, FND hierarchy/reuse updates. |
| Prompt 6 | FND simulation | FND simulation passed in Vivado 2020.2 with `PASS tests_passed=16 errors=0`. |
| Prompt 7 | Timer spec | Timer spec/software/verification docs, reuse notes, diagram/WaveDrom assets, master file index. |
| Prompt 7.5 | Physical cleanup/path migration | Moved project folders under `20260622_AXI4_Lite_SoC`, archived root Vivado logs, updated scripts/docs, reran GPIO/FND simulations. |
| Prompt 8 | Timer RTL | `axi_timer_core.v`, Timer RTL hierarchy, traceability updates. |
| Prompt 9 | Timer simulation | Timer Vivado simulation passed with `PASS tests_passed=19 errors=0`. |
| Unattended Phase A | Sensor specification | Sensor spec package created from `sr04.v` and `dht11.v` inspection. |
| Unattended Phase B | Sensor RTL | `axi_sensor_core.v` and Sensor hierarchy notes created. |
| Unattended Phase C | Sensor simulation | Sensor Vivado simulation passed with `PASS tests_passed=17 errors=0`. |
| Unattended Phase D | SPI specification | SPI spec/software/verification docs, reuse notes, diagram/WaveDrom assets created; SPI RTL intentionally not started. |
| Prompt 14 | SPI RTL | `axi_spi_core.v` and SPI hierarchy notes created; SPI simulation intentionally not started. |
| Prompt 15 | SPI simulation | SPI Vivado simulation passed with `PASS tests_passed=20 errors=0`. |
| Prompt 16 | I2C specification | I2C spec/software/verification docs, reuse notes, diagram/WaveDrom assets created; I2C RTL and simulation intentionally not started. |
| Prompt 17 | I2C RTL | `axi_i2c_core.v` and I2C hierarchy notes created; I2C simulation intentionally not started. |
| Prompt 18 | I2C simulation | I2C Vivado simulation passed with `PASS tests_passed=23 errors=0`. |

## Edit Policy Values

| Edit policy | Meaning |
| --- | --- |
| Reference read-only | Original archive source. Inspect only unless a later prompt explicitly approves a copied/adapted version. |
| Implemented RTL | Project-owned RTL implementation or planned implementation location. |
| Adapted RTL | Project-owned renamed/copy-adapted legacy RTL with documented reason. |
| Spec source of truth | Documentation that defines required behavior. |
| Simulation evidence | Testbench, Tcl, result, logs, or simulation report evidence. |
| Diagram source | Editable draw.io source file. |
| WaveDrom source | Editable WaveDrom JSON source file. |
| Report asset | Report-facing evidence or summary. |
| Deferred UVM reference | UVM reference material only; UVM remains deferred. |
| Archive | Preserved generated files moved out of the Git-root top level. |

## File Inventory

| Path | Category | Prompt | Status | Edit policy |
| --- | --- | --- | --- | --- |
| `axi_project_unique_sources/MANIFEST.md` | Reference manifest | Prompt 0 | Existing reference archive manifest | Reference read-only |
| `axi_project_unique_sources/sources/*.v`, `*.sv` | Reference RTL archive | Prompt 0-7.5 | Audited and left unchanged | Reference read-only |
| `docs/SOURCE_AUDIT.md` | Global docs | Prompt 0 | Created | Spec source of truth |
| `docs/REUSE_STRATEGY.md` | Global docs | Prompt 0/2 | Created and updated | Spec source of truth |
| `docs/PROJECT_PLAN.md` | Global docs | Prompt 0-7.5 | Living project plan | Spec source of truth |
| `docs/PROJECT_STRUCTURE_PLAN.md` | Global docs | Prompt 0 | Created | Spec source of truth |
| `docs/RISK_AND_DEBUG_PLAN.md` | Global docs | Prompt 0 | Created | Spec source of truth |
| `docs/REVERSE_ENGINEERING_NOTES.md` | Global docs | Prompt 0-7.5 | Living reverse-engineering guide | Spec source of truth |
| `docs/TRACEABILITY_MATRIX.md` | Global docs | Prompt 0-7.5 | Living traceability matrix | Spec source of truth |
| `docs/DIAGRAM_ASSET_PLAN.md` | Global docs | Prompt 0/1/4/7/7.5 | Living diagram/timing asset plan | Spec source of truth |
| `docs/UVM_REFERENCE_USAGE.md` | Global docs | Prompt 0 | UVM reference usage policy | Deferred UVM reference |
| `docs/AXI4_LITE_SOC_FILE_INDEX.md` | Global docs | Prompt 7/7.5 | Master file index updated for canonical root | Spec source of truth |
| `docs/specs/AXI_ADDRESS_MAP.md` | Global specs | Prompt 1 | Includes Timer base address | Spec source of truth |
| `docs/specs/AXI_REGISTER_CONVENTIONS.md` | Global specs | Prompt 1 | Shared AXI conventions | Spec source of truth |
| `docs/specs/axi_gpio_core_SPEC.md` | GPIO spec | Prompt 1 | Complete | Spec source of truth |
| `docs/specs/axi_gpio_core_VERIFICATION_PLAN.md` | GPIO spec | Prompt 1 | Complete | Spec source of truth |
| `docs/specs/axi_gpio_core_SOFTWARE_COMMANDS.md` | GPIO spec | Prompt 1 | Complete | Spec source of truth |
| `docs/rtl_views/axi_gpio_core_reuse_notes.md` | GPIO reuse notes | Prompt 1/2 | Updated for adapted debounce | Spec source of truth |
| `docs/rtl_views/axi_gpio_core_hierarchy.md` | GPIO RTL view | Prompt 2 | Created | Spec source of truth |
| `rtl_work/axi_peripherals/axi_gpio_core/hdl/axi_gpio_core.v` | GPIO RTL | Prompt 2 | Implemented and simulated passing | Implemented RTL |
| `rtl_work/legacy_adapted/button_debounce_level/button_debounce_level.v` | GPIO adapted RTL | Prompt 2 | Implemented and simulated passing | Adapted RTL |
| `sim/vivado/axi_gpio_core/tb_axi_gpio_core.sv` | GPIO simulation | Prompt 3/3.6/7.5 | Created and used in passing simulations | Simulation evidence |
| `sim/vivado/axi_gpio_core/run_axi_gpio_core_sim.tcl` | GPIO simulation | Prompt 3/3.6/7.5 | Path-migrated and passing | Simulation evidence |
| `sim/vivado/axi_gpio_core/README.md` | GPIO simulation | Prompt 3/7.5 | Updated for canonical root | Simulation evidence |
| `sim/vivado/axi_gpio_core/axi_gpio_core_sim_result.txt` | GPIO simulation result | Prompt 3.6/7.5 | `PASS tests_passed=12 errors=0` | Simulation evidence |
| `sim/vivado/axi_gpio_core/logs/*` | GPIO simulation logs | Prompt 3.6/7.5 | Preserved Vivado/xsim logs | Simulation evidence |
| `docs/report_assets/axi_gpio_core_vivado_sim_report.md` | GPIO report | Prompt 3/3.6/7.5 | Updated with post-migration result | Report asset |
| `docs/specs/axi_fnd_core_SPEC.md` | FND spec | Prompt 4 | Complete | Spec source of truth |
| `docs/specs/axi_fnd_core_VERIFICATION_PLAN.md` | FND spec | Prompt 4 | Complete | Spec source of truth |
| `docs/specs/axi_fnd_core_SOFTWARE_COMMANDS.md` | FND spec | Prompt 4 | Complete | Spec source of truth |
| `docs/rtl_views/axi_fnd_core_reuse_notes.md` | FND reuse notes | Prompt 4/5 | Updated with implementation decision | Spec source of truth |
| `docs/rtl_views/axi_fnd_core_hierarchy.md` | FND RTL view | Prompt 5 | Created | Spec source of truth |
| `rtl_work/axi_peripherals/axi_fnd_core/hdl/axi_fnd_core.v` | FND RTL | Prompt 5 | Implemented and simulated passing | Implemented RTL |
| `sim/vivado/axi_fnd_core/tb_axi_fnd_core.sv` | FND simulation | Prompt 6/7.5 | Created and used in passing simulations | Simulation evidence |
| `sim/vivado/axi_fnd_core/run_axi_fnd_core_sim.tcl` | FND simulation | Prompt 6/7.5 | Path-migrated and passing | Simulation evidence |
| `sim/vivado/axi_fnd_core/README.md` | FND simulation | Prompt 6/7.5 | Updated for canonical root | Simulation evidence |
| `sim/vivado/axi_fnd_core/axi_fnd_core_sim_result.txt` | FND simulation result | Prompt 6/7.5 | `PASS tests_passed=16 errors=0` | Simulation evidence |
| `sim/vivado/axi_fnd_core/logs/*` | FND simulation logs | Prompt 6/7.5 | Preserved Vivado/xsim logs | Simulation evidence |
| `docs/report_assets/axi_fnd_core_vivado_sim_report.md` | FND report | Prompt 6/7.5 | Updated with post-migration result | Report asset |
| `docs/specs/axi_timer_core_SPEC.md` | Timer spec | Prompt 7 | Complete | Spec source of truth |
| `docs/specs/axi_timer_core_VERIFICATION_PLAN.md` | Timer spec | Prompt 7 | Complete, no testbench created | Spec source of truth |
| `docs/specs/axi_timer_core_SOFTWARE_COMMANDS.md` | Timer spec | Prompt 7 | Complete, no C code created | Spec source of truth |
| `docs/rtl_views/axi_timer_core_reuse_notes.md` | Timer reuse notes | Prompt 7/8 | Complete, updated with RTL decision | Spec source of truth |
| `docs/rtl_views/axi_timer_core_hierarchy.md` | Timer RTL hierarchy | Prompt 8 | Created | RTL documentation |
| `rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v` | Timer RTL | Prompt 8 | Created | Implemented RTL |
| `sim/vivado/axi_timer_core/tb_axi_timer_core.sv` | Timer simulation | Prompt 9 | Created and used in passing simulation | Simulation evidence |
| `sim/vivado/axi_timer_core/run_axi_timer_core_sim.tcl` | Timer simulation | Prompt 9 | Created and passing | Simulation evidence |
| `sim/vivado/axi_timer_core/README.md` | Timer simulation | Prompt 9 | Created | Simulation evidence |
| `sim/vivado/axi_timer_core/axi_timer_core_sim_result.txt` | Timer simulation result | Prompt 9 | `PASS tests_passed=19 errors=0` | Simulation evidence |
| `sim/vivado/axi_timer_core/logs/*` | Timer simulation logs | Prompt 9 | Preserved Vivado/xsim logs | Simulation evidence |
| `docs/report_assets/axi_timer_core_vivado_sim_report.md` | Timer report | Prompt 9 | Created with passing result | Report asset |
| `docs/specs/axi_sensor_core_SPEC.md` | Sensor spec | Unattended Phase A | Complete | Spec source of truth |
| `docs/specs/axi_sensor_core_VERIFICATION_PLAN.md` | Sensor spec | Unattended Phase A | Complete | Spec source of truth |
| `docs/specs/axi_sensor_core_SOFTWARE_COMMANDS.md` | Sensor command plan | Unattended Phase A | Complete, no C code created | Spec source of truth |
| `docs/rtl_views/axi_sensor_core_reuse_notes.md` | Sensor reuse notes | Unattended Phase A/B | Complete, updated with RTL decision | Spec source of truth |
| `docs/rtl_views/axi_sensor_core_hierarchy.md` | Sensor RTL hierarchy | Unattended Phase B | Created | RTL documentation |
| `rtl_work/axi_peripherals/axi_sensor_core/hdl/axi_sensor_core.v` | Sensor RTL | Unattended Phase B | Created | Implemented RTL |
| `docs/diagrams/axi_sensor_core_wrapper.drawio` | Sensor wrapper editable block diagram | Unattended Phase A | Created | Diagram source |
| `docs/wavedrom/axi_sensor_command_status.json` | Sensor command/status timing intent | Unattended Phase A | Created | WaveDrom source |
| `docs/wavedrom/axi_sensor_sr04_echo.json` | Sensor SR04 echo timing intent | Unattended Phase A | Created | WaveDrom source |
| `docs/wavedrom/axi_sensor_dht11_start.json` | Sensor DHT11 start timing intent | Unattended Phase A | Created | WaveDrom source |
| `sim/vivado/axi_sensor_core/tb_axi_sensor_core.sv` | Sensor simulation | Unattended Phase C | Created and used in passing simulation | Simulation evidence |
| `sim/vivado/axi_sensor_core/run_axi_sensor_core_sim.tcl` | Sensor simulation | Unattended Phase C | Created and passing | Simulation evidence |
| `sim/vivado/axi_sensor_core/README.md` | Sensor simulation | Unattended Phase C | Created | Simulation evidence |
| `sim/vivado/axi_sensor_core/axi_sensor_core_sim_result.txt` | Sensor simulation result | Unattended Phase C | `PASS tests_passed=17 errors=0` | Simulation evidence |
| `sim/vivado/axi_sensor_core/logs/*` | Sensor simulation logs | Unattended Phase C | Preserved Vivado/xsim logs | Simulation evidence |
| `docs/report_assets/axi_sensor_core_vivado_sim_report.md` | Sensor report | Unattended Phase C | Created with passing result | Report asset |
| `docs/specs/axi_spi_core_SPEC.md` | SPI spec | Unattended Phase D | Complete | Spec source of truth |
| `docs/specs/axi_spi_core_VERIFICATION_PLAN.md` | SPI spec | Unattended Phase D | Complete, no testbench created | Spec source of truth |
| `docs/specs/axi_spi_core_SOFTWARE_COMMANDS.md` | SPI command plan | Unattended Phase D | Complete, no C code created | Spec source of truth |
| `docs/rtl_views/axi_spi_core_reuse_notes.md` | SPI reuse notes | Unattended Phase D/Prompt 14 | Complete, updated with RTL decision | Spec source of truth |
| `docs/rtl_views/axi_spi_core_hierarchy.md` | SPI RTL hierarchy | Prompt 14 | Created | RTL documentation |
| `rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v` | SPI RTL | Prompt 14/15 | Created and simulated passing | Implemented RTL |
| `docs/diagrams/axi_spi_core_wrapper.drawio` | SPI wrapper editable block diagram | Unattended Phase D | Created | Diagram source |
| `docs/wavedrom/axi_spi_transaction.json` | SPI transaction timing intent | Unattended Phase D | Created | WaveDrom source |
| `docs/wavedrom/axi_spi_control_status.json` | SPI control/status timing intent | Unattended Phase D | Created | WaveDrom source |
| `sim/vivado/axi_spi_core/tb_axi_spi_core.sv` | SPI simulation | Prompt 15 | Created and used in passing simulation | Simulation evidence |
| `sim/vivado/axi_spi_core/run_axi_spi_core_sim.tcl` | SPI simulation | Prompt 15 | Created and passing | Simulation evidence |
| `sim/vivado/axi_spi_core/README.md` | SPI simulation | Prompt 15 | Created | Simulation evidence |
| `sim/vivado/axi_spi_core/axi_spi_core_sim_result.txt` | SPI simulation result | Prompt 15 | `PASS tests_passed=20 errors=0` | Simulation evidence |
| `sim/vivado/axi_spi_core/logs/*` | SPI simulation logs | Prompt 15 | Preserved Vivado/xsim logs | Simulation evidence |
| `docs/report_assets/axi_spi_core_vivado_sim_report.md` | SPI report | Prompt 15 | Created with passing result | Report asset |
| `docs/specs/axi_i2c_core_SPEC.md` | I2C spec | Prompt 16 | Complete | Spec source of truth |
| `docs/specs/axi_i2c_core_VERIFICATION_PLAN.md` | I2C spec | Prompt 16 | Complete, no testbench created | Spec source of truth |
| `docs/specs/axi_i2c_core_SOFTWARE_COMMANDS.md` | I2C command plan | Prompt 16 | Complete, no C code created | Spec source of truth |
| `docs/rtl_views/axi_i2c_core_reuse_notes.md` | I2C reuse notes | Prompt 16/17 | Complete; updated with RTL implementation decision | Spec source of truth |
| `docs/diagrams/axi_i2c_core_wrapper.drawio` | I2C wrapper editable block diagram | Prompt 16 | Created | Diagram source |
| `docs/wavedrom/axi_i2c_command_status.json` | I2C command/status timing intent | Prompt 16 | Created | WaveDrom source |
| `docs/wavedrom/axi_i2c_write_byte.json` | I2C write-byte timing intent | Prompt 16 | Created | WaveDrom source |
| `docs/wavedrom/axi_i2c_read_byte.json` | I2C read-byte timing intent | Prompt 16 | Created | WaveDrom source |
| `docs/rtl_views/axi_i2c_core_hierarchy.md` | I2C RTL hierarchy | Prompt 17 | Created | RTL documentation |
| `rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v` | I2C RTL | Prompt 17/18 | Created and simulated passing | Implemented RTL |
| `sim/vivado/axi_i2c_core/tb_axi_i2c_core.sv` | I2C simulation | Prompt 18 | Created and used in passing simulation | Simulation evidence |
| `sim/vivado/axi_i2c_core/run_axi_i2c_core_sim.tcl` | I2C simulation | Prompt 18 | Created and passing | Simulation evidence |
| `sim/vivado/axi_i2c_core/README.md` | I2C simulation | Prompt 18 | Created | Simulation evidence |
| `sim/vivado/axi_i2c_core/axi_i2c_core_sim_result.txt` | I2C simulation result | Prompt 18 | `PASS tests_passed=23 errors=0` | Simulation evidence |
| `sim/vivado/axi_i2c_core/logs/*` | I2C simulation logs | Prompt 18 | Preserved Vivado/xsim logs | Simulation evidence |
| `docs/report_assets/axi_i2c_core_vivado_sim_report.md` | I2C report | Prompt 18 | Created with passing result | Report asset |
| `docs/report_assets/unattended_sensor_spi_run.md` | Unattended batch run log | Unattended run | Updated through Phase D | Report asset |
| `docs/diagrams/*.drawio` | Editable diagrams | Prompt 1/4/7 | Created and moved under canonical root | Diagram source |
| `docs/wavedrom/*.json` | Editable timing sources | Prompt 1/4/7 | Created and moved under canonical root | WaveDrom source |
| `UVM_testbench_ref/ram_uvm_split/*` | UVM reference | Prompt 0/7.5 | Reference-only and moved under canonical root | Deferred UVM reference |
| `_archive/root_vivado_logs/*` | Root Vivado logs | Prompt 7.5 | Archived from Git-root top level | Archive |

## Placement Rules

- New project files should be created inside `D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC`.
- New documentation belongs under `docs/`.
- New custom wrapper RTL belongs under `rtl_work/axi_peripherals/<peripheral>/hdl/`.
- Adapted legacy copies belong under `rtl_work/legacy_adapted/<clear_name>/`.
- Focused Vivado simulations belong under `sim/vivado/<peripheral>/`.
- Reference RTL in `axi_project_unique_sources/` remains read-only.
- UVM remains deferred and should not be created for a peripheral until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.
- Do not move unknown Git-root folders unless a future prompt classifies them.
## Prompt 19 File Index Addendum

| Path | Category | Prompt | Status | Edit policy |
| --- | --- | --- | --- | --- |
| `sim/vivado/run_all_peripheral_sims.ps1` | Full regression script | Prompt 19 | Created and run passing | Simulation evidence |
| `docs/report_assets/full_peripheral_regression_report.md` | Regression report | Prompt 19 | Created with passing run evidence | Report asset |
| `docs/report_assets/custom_peripheral_baseline_review.md` | Baseline review | Prompt 19 | Created | Report asset |
| `docs/integration/MICROBLAZE_INTEGRATION_PLAN.md` | Integration planning | Prompt 19 | Created | Spec source of truth |
| `docs/integration/AXI_ADDRESS_ASSIGNMENT_FINAL_CHECK.md` | Integration planning | Prompt 19 | Created | Spec source of truth |
| `docs/integration/CUSTOM_IP_PACKAGING_PLAN.md` | IP packaging planning | Prompt 19 | Created | Spec source of truth |
| `docs/integration/PERIPHERAL_EXTERNAL_PORT_SUMMARY.md` | Integration planning | Prompt 19 | Created | Spec source of truth |
| `docs/integration/BASYS3_EXTERNAL_IO_PLANNING.md` | Board IO planning | Prompt 19 | Created, no exact pins assigned | Spec source of truth |
| `docs/integration/MICROBLAZE_SOFTWARE_COMMAND_MATRIX.md` | Software command planning | Prompt 19 | Created, no C code created | Spec source of truth |
| `docs/integration/INTEGRATION_RISK_CHECKLIST.md` | Integration risk planning | Prompt 19 | Created | Spec source of truth |
| `docs/diagrams/microblaze_axi_soc_integration_ready.drawio` | Integration diagram | Prompt 19 | Created | Diagram source |
| `docs/wavedrom/microblaze_uart_to_axi_command_flow.json` | UART-to-AXI timing source | Prompt 19 | Created | WaveDrom source |

## Prompt 20 Local IP Packaging File Addendum

Prompt 20 added repeatable Vivado 2020.2 packaging automation and generated local IP repository outputs.

Created packaging scripts:

- `vivado/scripts/package_common_custom_ip.tcl`
- `vivado/scripts/package_all_custom_ip.tcl`
- `vivado/scripts/package_axi_gpio_core.tcl`
- `vivado/scripts/package_axi_fnd_core.tcl`
- `vivado/scripts/package_axi_timer_core.tcl`
- `vivado/scripts/package_axi_sensor_core.tcl`
- `vivado/scripts/package_axi_spi_core.tcl`
- `vivado/scripts/package_axi_i2c_core.tcl`

Created packaged IP folders:

- `vivado/ip_repo/axi_gpio_core`
- `vivado/ip_repo/axi_fnd_core`
- `vivado/ip_repo/axi_timer_core`
- `vivado/ip_repo/axi_sensor_core`
- `vivado/ip_repo/axi_spi_core`
- `vivado/ip_repo/axi_i2c_core`

Created packaging report and evidence:

- `docs/report_assets/custom_ip_packaging_report.md`
- `vivado/ip_repo/package_all_custom_ip_20260622_225119_vivado.log`

Vivado also generated or updated the root-level `vivado.log` and `vivado.jou` during batch execution. The stable copied packaging log is stored under `vivado/ip_repo`.

No files under `rtl_work/` or `axi_project_unique_sources/` were intentionally modified during Prompt 20.

## Prompt 21 MicroBlaze Block Design File Addendum

Prompt 21 added the reproducible Basys3 MicroBlaze block-design generation flow.

Created script:

- `vivado/scripts/create_microblaze_basys3_bd.tcl`

Created Vivado project outputs:

- `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.xpr`
- `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.srcs/sources_1/bd/microblaze_axi_soc_bd/microblaze_axi_soc_bd.bd`
- `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.gen/sources_1/bd/microblaze_axi_soc_bd/hdl/microblaze_axi_soc_bd_wrapper.v`
- `vivado/basys3/microblaze_axi_soc/reports/bd_address_map_actual.tsv`
- `vivado/basys3/microblaze_axi_soc/reports/bd_address_report.txt`
- `vivado/basys3/microblaze_axi_soc/reports/bd_cells.txt`
- `vivado/basys3/microblaze_axi_soc/reports/bd_external_ports.tsv`
- `vivado/basys3/microblaze_axi_soc/reports/bd_validation_summary.txt`
- `vivado/basys3/microblaze_axi_soc/reports/microblaze_bd_creation_20260622_231359_vivado.log`

Created documentation:

- `docs/report_assets/microblaze_bd_creation_report.md`
- `docs/integration/MICROBLAZE_BD_SUMMARY.md`
- `docs/integration/BD_EXTERNAL_PORT_SUMMARY.md`
- `docs/integration/BD_ADDRESS_MAP_VERIFICATION.md`
- `docs/integration/BD_NEXT_STEPS.md`

Modified generated packaged IP metadata:

- `vivado/ip_repo/*/component.xml` normalized `ASSOCIATED_BUSIF` from `s00_axi:S00_AXI` to `S00_AXI` for clean block-design validation.

No files under `rtl_work/` or `axi_project_unique_sources/` were intentionally modified during Prompt 21.


## Prompt 22 Basys3 XDC File Addendum

Prompt 22 added Basys3 constraints and XDC application/validation assets.

Created constraints and scripts:

- `constraints/basys3/basys3_axi_soc.xdc`
- `vivado/scripts/apply_basys3_xdc.tcl`

Created documentation:

- `docs/integration/BASYS3_XDC_PIN_MAP.md`
- `docs/integration/BASYS3_RESET_POLICY.md`
- `docs/report_assets/basys3_xdc_constraints_report.md`

Created Vivado report artifacts:

- `vivado/basys3/microblaze_axi_soc/reports/basys3_xdc_apply_summary.txt`
- `vivado/basys3/microblaze_axi_soc/reports/basys3_reset_policy_actual.txt`
- `vivado/basys3/microblaze_axi_soc/reports/basys3_xdc_port_check.tsv`
- `vivado/basys3/microblaze_axi_soc/reports/basys3_xdc_pin_check.tsv`
- `vivado/basys3/microblaze_axi_soc/reports/basys3_xdc_apply_20260623_001605_vivado.log`

Modified Vivado project/BD outputs:

- `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.xpr` added the XDC to `constrs_1`.
- `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.srcs/sources_1/bd/microblaze_axi_soc_bd/microblaze_axi_soc_bd.bd` added `rstn_inv_0` for active-low CPU_RESETN handling.
- `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.gen/sources_1/bd/microblaze_axi_soc_bd/hdl/microblaze_axi_soc_bd_wrapper.v` was regenerated with the same top-level ports.

## Prompt 22 v1 Reset Revision File Addendum

Prompt 22 v1 added reset revision support on top of the Basys3 XDC application flow.

Created reset option snippets:

- `constraints/basys3/reset_options/README.md`
- `constraints/basys3/reset_options/reset_cpu_resetn_c12.xdc`
- `constraints/basys3/reset_options/reset_external_pmod_template.xdc`

Created reset revision documentation:

- `docs/integration/BASYS3_RESET_REVISION_GUIDE.md`

Updated existing Prompt 22 files:

- `constraints/basys3/basys3_axi_soc.xdc`
- `vivado/scripts/apply_basys3_xdc.tcl`
- `docs/integration/BASYS3_XDC_PIN_MAP.md`
- `docs/integration/BASYS3_RESET_POLICY.md`
- `docs/report_assets/basys3_xdc_constraints_report.md`
- `docs/integration/BASYS3_EXTERNAL_IO_PLANNING.md`
- `docs/integration/BD_EXTERNAL_PORT_SUMMARY.md`

Final revised log:

- `vivado/basys3/microblaze_axi_soc/reports/basys3_xdc_apply_v1_20260623_002733_vivado.log`

## Prompt 23 Bitstream Build File Addendum

Prompt 23 added the reproducible Vivado 2020.2 bitstream/XSA build flow and generated the first passing hardware handoff artifacts.

Created build script and reset snippet:

- `vivado/scripts/build_microblaze_basys3_bitstream.tcl`
- `constraints/basys3/reset_options/reset_external_pmod_ja4_g2.xdc`

Created build reports and integration docs:

- `docs/report_assets/bitstream_build_report.md`
- `docs/integration/BITSTREAM_AND_XSA_SUMMARY.md`
- `docs/integration/POST_BITSTREAM_NEXT_STEPS.md`
- `vivado/basys3/microblaze_axi_soc/reports/bitstream_build_summary.txt`
- `vivado/basys3/microblaze_axi_soc/reports/synth_utilization.rpt`
- `vivado/basys3/microblaze_axi_soc/reports/synth_timing_summary.rpt`
- `vivado/basys3/microblaze_axi_soc/reports/impl_timing_summary.rpt`
- `vivado/basys3/microblaze_axi_soc/reports/impl_utilization.rpt`
- `vivado/basys3/microblaze_axi_soc/reports/impl_drc.rpt`
- `vivado/basys3/microblaze_axi_soc/reports/power_estimate.rpt`
- `vivado/basys3/microblaze_axi_soc/reports/bitstream_build_20260623_011529_vivado.log`
- `vivado/basys3/microblaze_axi_soc/reports/bitstream_build_20260623_011529_vivado.jou`

Created exported hardware artifacts:

- `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.bit`
- `vivado/basys3/microblaze_axi_soc/exports/microblaze_axi_soc.xsa`

Updated existing constraints/docs:

- `constraints/basys3/basys3_axi_soc.xdc`: reset moved from invalid CPU_RESETN/C12 to external PMOD JA4/G2 active-low reset.
- `vivado/scripts/apply_basys3_xdc.tcl`: future reset summary strings now match JA4/G2.
- `docs/integration/BASYS3_RESET_POLICY.md`
- `docs/integration/BASYS3_RESET_REVISION_GUIDE.md`
- `docs/integration/BASYS3_XDC_PIN_MAP.md`
- `docs/integration/BD_EXTERNAL_PORT_SUMMARY.md`
- `docs/report_assets/basys3_xdc_constraints_report.md`

No files under `rtl_work/`, `axi_project_unique_sources/`, or `UVM_testbench_ref/` were intentionally modified. No Vitis workspace or user software was created.

## Prompt 24 Vitis Software File Addendum

Prompt 24 added the MicroBlaze standalone UART command software source tree, Vitis/XSCT scripts, and software bring-up documentation.

Created source files:

- `sw/src/main.c`
- `sw/src/axi_soc_hw.h`
- `sw/src/axi_soc_regs.h`
- `sw/src/uart_console.c`
- `sw/src/uart_console.h`
- `sw/src/command_parser.c`
- `sw/src/command_parser.h`
- `sw/src/periph_gpio.c`
- `sw/src/periph_gpio.h`
- `sw/src/periph_fnd.c`
- `sw/src/periph_fnd.h`
- `sw/src/periph_timer.c`
- `sw/src/periph_timer.h`
- `sw/src/periph_sensor.c`
- `sw/src/periph_sensor.h`
- `sw/src/periph_spi.c`
- `sw/src/periph_spi.h`
- `sw/src/periph_i2c.c`
- `sw/src/periph_i2c.h`

Created scripts:

- `sw/scripts/create_vitis_workspace.tcl`
- `sw/scripts/build_software.tcl`
- `sw/scripts/create_and_build_software.bat`

Created documentation:

- `docs/report_assets/vitis_software_build_report.md`
- `docs/integration/VITIS_WORKSPACE_SUMMARY.md`
- `docs/integration/MICROBLAZE_UART_COMMAND_REFERENCE.md`
- `docs/integration/SOFTWARE_REGISTER_MAP.md`
- `docs/integration/BOARD_BRINGUP_CHECKLIST.md`
- `sw/docs/uart_smoke_test_sequence.md`

Status:

- Software source/scripts/docs are created.
- XSCT/Vitis 2020.2 was not found, so Vitis platform/BSP/app objects were not generated.
- No ELF was generated.
- `sw/vitis_workspace/` exists only as a placeholder directory.
- RTL, reference RTL, Vivado block design, bitstream, and XSA were intentionally left unchanged.

## Prompt 24.5 Software Build Gate File Addendum

Prompt 24.5 added software build gate documentation after locating only non-2020.2 XSCT tools.

Created:

- `docs/integration/VITIS_INSTALLATION_REQUIRED.md`
- `docs/report_assets/software_static_check_report.md`

Updated:

- `docs/report_assets/vitis_software_build_report.md`
- `docs/integration/VITIS_WORKSPACE_SUMMARY.md`
- `docs/integration/BOARD_BRINGUP_CHECKLIST.md`
- `docs/TRACEABILITY_MATRIX.md`
- `docs/PROJECT_PLAN.md`
- `docs/REVERSE_ENGINEERING_NOTES.md`
- `docs/AXI4_LITE_SOC_FILE_INDEX.md`

Status:

- XSCT 2020.2 was not found.
- XSCT 2024.2 paths were found but not used.
- Software static check passed.
- No ELF was generated.
- RTL, reference RTL, Vivado BD, bitstream, XSA, and UVM remained unchanged.

Prompt 24.5 wrapper correction: `sw/scripts/create_and_build_software.bat` now checks both `D:` and `C:` XSCT/Vitis 2020.2 candidate paths. No 2024.2 path was added, and the wrapper was verified to stop before launching any XSCT when 2020.2 is absent.

## Vitis 2020.2 Software Build File Addendum

After Vitis 2020.2 installation, the software build generated Vitis workspace outputs under `sw/vitis_workspace`.

Generated key outputs:

- `sw/vitis_workspace/microblaze_axi_soc_platform/`
- `sw/vitis_workspace/axi_soc_uart_app/`
- `sw/vitis_workspace/axi_soc_uart_app/Debug/axi_soc_uart_app.elf`
- `sw/vitis_workspace/axi_soc_uart_app/Debug/axi_soc_uart_app.elf.size`
- `sw/vitis_workspace/IDE.log`
- `sw/vitis_workspace/microblaze_axi_soc_platform/logs/platform.log`

Status:

- Software build passed with XSCT/Vitis 2020.2.
- Board programming is still not started.
- RTL, reference RTL, Vivado BD, bitstream, XSA, and UVM remained unchanged.

## Prompt 25A Offline Board Package File Addendum

Prompt 25A added offline board bring-up scripts, manual guides, package manifest/checksums, and board-test reports.

Created hardware package files:

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

Created reports:

- `docs/report_assets/offline_board_package_report.md`
- `docs/report_assets/board_programming_report.md`
- `docs/report_assets/uart_smoke_test_report.md`

Status:

- Offline package prepared.
- Board programming not run.
- UART smoke test not run.
- RTL, reference RTL, Vivado BD, bitstream, XSA, ELF, and UVM were intentionally left unchanged.
