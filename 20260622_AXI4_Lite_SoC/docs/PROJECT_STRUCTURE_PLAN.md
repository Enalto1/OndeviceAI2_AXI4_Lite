# Project Structure Plan

This plan keeps archived reference RTL separate from new work products. It also keeps Vivado simulation, UVM verification, documentation assets, and future board-demo materials easy to trace.

## Observed Project Root

| Existing path | Current role | Step 0 action |
| --- | --- | --- |
| `D:\OndeviceAI2_AXI4_Lite\axi_project_unique_sources` | Reference RTL archive | Audited, left unchanged |
| `D:\OndeviceAI2_AXI4_Lite\UVM_testbench_ref\ram_uvm_split` | RAM UVM split-file style reference | Audited, left unchanged |
| `D:\OndeviceAI2_AXI4_Lite\ip_repo` | Existing IP repository area | Left unchanged |
| `D:\OndeviceAI2_AXI4_Lite\reports` | Existing reports area | Left unchanged |
| `D:\OndeviceAI2_AXI4_Lite\simulation_results` | Existing simulation output area | Left unchanged |
| `D:\OndeviceAI2_AXI4_Lite\docs` | Documentation and planning assets | Created in Step 0 |

## Recommended Directory Layout

```text
D:\OndeviceAI2_AXI4_Lite\
  axi_project_unique_sources\
    MANIFEST.md
    sources\                         # Read-only reference RTL archive
  UVM_testbench_ref\
    ram_uvm_split\                    # Read-only UVM style reference
  docs\
    SOURCE_AUDIT.md
    REUSE_STRATEGY.md
    PROJECT_STRUCTURE_PLAN.md
    PROJECT_PLAN.md
    RISK_AND_DEBUG_PLAN.md
    UVM_REFERENCE_USAGE.md
    DIAGRAM_ASSET_PLAN.md
    TRACEABILITY_MATRIX.md
    REVERSE_ENGINEERING_NOTES.md
    diagrams\                         # Editable draw.io sources
    wavedrom\                         # WaveDrom timing JSON sources
    rtl_views\                         # RTL hierarchy notes/views
    report_assets\                     # Report and presentation support assets
  rtl_work\                            # Future new RTL, not created in Step 0
    axi_peripherals\
      axi_gpio_core\hdl\
      axi_fnd_core\hdl\
      axi_timer_core\hdl\
      axi_sensor_core\hdl\
      axi_spi_core\hdl\
      axi_i2c_core\hdl\
    common\
    legacy_adapted\                   # Only for documented copies of changed reference RTL
  sim\                                 # Future non-UVM simulation assets, not created in Step 0
    vivado\<peripheral>\
  uvm\                                 # Future standalone peripheral UVM envs, not created in Step 0
    <peripheral>_uvm\
  vivado\                              # Future project/block-design scripts, not created in Step 0
    basys3\
    zybo_z7_20\
  sw\                                  # Future MicroBlaze software, not created in Step 0
    microblaze_apps\
```

The directories marked as future work are recommended structure only. Step 0 created only `docs` and the requested documentation asset folders.

## Where New AXI Wrappers Should Go

Future AXI4-Lite wrapper RTL should be placed under:

```text
rtl_work\axi_peripherals\<peripheral_name>\hdl\
```

| Peripheral | Planned wrapper file | Notes |
| --- | --- | --- |
| `axi_gpio_core` | `rtl_work/axi_peripherals/axi_gpio_core/hdl/axi_gpio_core.v` | First implementation target. |
| `axi_fnd_core` | `rtl_work/axi_peripherals/axi_fnd_core/hdl/axi_fnd_core.v` | Must instantiate `fnd_controller`. |
| `axi_timer_core` | `rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v` | Must instantiate stopwatch/watch datapaths. |
| `axi_sensor_core` | `rtl_work/axi_peripherals/axi_sensor_core/hdl/axi_sensor_core.v` | Must instantiate DHT11/SR04 logic. |
| `axi_spi_core` | `rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v` | Should wrap SPI master first. |
| `axi_i2c_core` | `rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v` | Should wrap I2C master first. |

Wrapper source language should follow the Vivado 2020.2 AXI4-Lite template language. If the template is generated in Verilog, keep wrappers in Verilog.

## Where Vivado Testbenches Should Go

Future simple RTL simulations should be standalone per peripheral:

```text
sim\vivado\<peripheral_name>\
  tb_<peripheral_name>.v or .sv
  run_<peripheral_name>_sim.tcl
  README.md
```

Each simulation folder should state the DUT wrapper, reused reference files, clock/reset assumptions, stimulus sequence, pass/fail condition, and Vivado 2020.2 run command.

## Where UVM Environments Should Go

Future UVM environments should be standalone per peripheral first and mirror the RAM reference:

```text
uvm\<peripheral_name>_uvm\
  <peripheral>_if.sv
  <peripheral>_seq_item.sv
  <peripheral>_base_seq.sv
  <peripheral>_basic_seq.sv
  <peripheral>_driver.sv
  <peripheral>_monitor.sv
  <peripheral>_agent.sv
  <peripheral>_scoreboard.sv
  <peripheral>_coverage.sv
  <peripheral>_env.sv
  <peripheral>_base_test.sv
  <peripheral>_basic_test.sv
  <peripheral>_pkg.sv
  tb_top.sv
  README.md
```

The first UVM environment should be `uvm/axi_gpio_core_uvm` after the GPIO wrapper and simple Vivado simulation are stable.

## Documentation Asset Locations

| Asset type | Directory | Source format |
| --- | --- | --- |
| Block diagrams and hierarchy diagrams | `docs/diagrams` | `.drawio` |
| Timing diagrams | `docs/wavedrom` | WaveDrom-compatible `.json` |
| RTL hierarchy summaries | `docs/rtl_views` | Markdown or generated text/source lists |
| Report/presentation assets | `docs/report_assets` | Markdown, tables, exported images derived from editable sources |

## Reference Separation Rules

- Do not edit files in `axi_project_unique_sources` directly.
- Do not edit files in `UVM_testbench_ref/ram_uvm_split` directly.
- Do not point future Vivado generated output into the reference RTL archive.
- If a legacy RTL file needs changes, copy it to `rtl_work/legacy_adapted/<core_name>/`, rename it clearly, and document the reason.

## Naming Conventions

- AXI wrapper names: `axi_<function>_core`.
- AXI clock/reset names: `s00_axi_aclk`, `s00_axi_aresetn`.
- AXI data width: 32 bits.
- AXI address width: 6 bits per custom peripheral unless a later spec documents a reason to change it.
- One-clock pulse register bits should use names such as `start_pulse`, `clear_pulse`, and `cmd_valid_pulse`.
