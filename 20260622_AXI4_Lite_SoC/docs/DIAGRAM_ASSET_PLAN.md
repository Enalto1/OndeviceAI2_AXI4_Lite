# Diagram Asset Plan

This plan defines editable documentation assets for design review, reverse engineering, and final presentation/report work. Step 0 creates the asset directories only. Final diagrams are planned for later phases.

## Created Asset Directories

| Directory | Purpose |
| --- | --- |
| `docs/diagrams/` | Editable draw.io block diagrams and hierarchy diagrams. |
| `docs/wavedrom/` | WaveDrom-compatible JSON timing diagrams. |
| `docs/rtl_views/` | RTL hierarchy summaries and source reuse views. |
| `docs/report_assets/` | Presentation/report tables, exported images derived from editable sources, demo notes. |

## Draw.io Diagram Plan

| Planned file | Diagram | When to create | Required content |
| --- | --- | --- | --- |
| `docs/diagrams/overall_microblaze_axi_soc.drawio` | Overall MicroBlaze AXI4-Lite SoC block diagram | Before first Vivado block design | PC terminal, AXI UART Lite, MicroBlaze, AXI interconnect, custom AXI slaves, reused RTL cores, Basys3 pins. |
| `docs/diagrams/axi_address_map.drawio` | AXI address map diagram | During address map/spec phase | MicroBlaze memory map, AXI interconnect slots, base addresses, range per peripheral. |
| `docs/diagrams/axi_gpio_core_wrapper.drawio` | GPIO wrapper block diagram | During GPIO spec phase | AXI template shell, registers, LED output, switch/button inputs, debounce reuse. |
| `docs/diagrams/axi_fnd_core_wrapper.drawio` | FND wrapper block diagram | During FND spec phase | AXI registers, `fnd_controller`, Basys3 `an`/`seg`, display-value paths. |
| `docs/diagrams/axi_timer_core_wrapper.drawio` | Timer wrapper block diagram | During Timer spec phase | AXI registers, stopwatch/watch datapaths, control pulses, counter readbacks, FND adapter. |
| `docs/diagrams/axi_sensor_core_wrapper.drawio` | Sensor wrapper block diagram | During Sensor spec phase | AXI control/status, DHT11 path, SR04 path, start/valid/done/data flow. |
| `docs/diagrams/axi_spi_core_wrapper.drawio` | SPI wrapper block diagram | During SPI spec phase | AXI registers, SPI master core, optional slave/test path, external pins. |
| `docs/diagrams/axi_i2c_core_wrapper.drawio` | I2C wrapper block diagram | During I2C spec phase | AXI registers, I2C master core, optional slave path, open-drain pad handling. |
| `docs/diagrams/source_reuse_hierarchy.drawio` | Reused RTL hierarchy diagram | After first wrappers exist | Reference files, instantiated leaf modules, wrapper ownership, modified-copy exceptions if any. |

## WaveDrom Timing Diagram Plan

| Planned file | Timing diagram | Required signals |
| --- | --- | --- |
| `docs/wavedrom/axi_lite_write.json` | AXI4-Lite write timing | `AWVALID`, `AWREADY`, `WVALID`, `WREADY`, `BVALID`, `BREADY`, address, data, write strobe. |
| `docs/wavedrom/axi_lite_read.json` | AXI4-Lite read timing | `ARVALID`, `ARREADY`, `RVALID`, `RREADY`, address, read data, response. |
| `docs/wavedrom/write_one_pulse.json` | Register write to one-clock pulse | AXI write completion, internal control register bit, generated pulse. |
| `docs/wavedrom/axi_timer_control_command.json` | Timer CONTROL/COMMAND timing | AXI write to `CONTROL`, AXI write to `COMMAND`, WSTRB, one-clock clear/edit pulses. |
| `docs/wavedrom/axi_timer_watch_edit.json` | Timer watch edit timing | set mode, target select, edit up/down command pulse, raw digit update, `WATCH_VALUE` update. |
| `docs/wavedrom/axi_timer_read_values.json` | Timer value read timing | AXI reads of `STOPWATCH_VALUE`, `WATCH_VALUE`, and `STATUS`, with reserved bits zero. |
| `docs/wavedrom/sensor_start_done_timing.json` | Sensor start/result timing | start pulse, busy, valid/done, result register update. |
| `docs/wavedrom/spi_transaction_timing.json` | SPI byte transaction | start, busy, done, `ss_n`, `sclk`, `mosi`, `miso`, CPOL/CPHA note. |
| `docs/wavedrom/axi_i2c_command_status.json` | I2C command/status timing | AXI write to `COMMAND`, `cmd_valid`, `cmd_ready`, busy, done, nack, and status readback. |
| `docs/wavedrom/axi_i2c_write_byte.json` | I2C write-byte sequence | START, WRITE_BYTE, STOP, drive-low behavior, done, and NACK capture. |
| `docs/wavedrom/axi_i2c_read_byte.json` | I2C read-byte sequence | READ_BYTE, target SDA bits, RXDATA update, and ACK/NACK behavior. |

## RTL View Plan

| Planned file | Purpose |
| --- | --- |
| `docs/rtl_views/reference_rtl_hierarchy.md` | Human-readable hierarchy of all audited reference modules. |
| `docs/rtl_views/peripheral_reuse_tree.md` | Mapping from each AXI peripheral wrapper to reused reference RTL modules. |
| `docs/rtl_views/legacy_top_signal_flow.md` | Explanation of old `TOP.v` UART/ASCII/control/dataflow for comparison with the MicroBlaze architecture. |
| `docs/rtl_views/generated_vivado_hierarchy_notes.md` | Later notes from Vivado elaboration or schematic views, with tool/version stated. |

## Report Asset Plan

| Planned file | Purpose |
| --- | --- |
| `docs/report_assets/project_overview.md` | Report-friendly summary of project objective and architecture. |
| `docs/report_assets/source_reuse_table.md` | Compact table showing reused RTL per peripheral. |
| `docs/report_assets/demo_command_log.md` | UART terminal command/response transcript for board demonstrations. |
| `docs/report_assets/verification_summary.md` | Simulation/UVM/board pass summary per peripheral. |

## Step 0 Boundary

No final diagrams were created in Step 0. Only the asset directories and this plan were created.

## Prompt 1 Asset Status

Prompt 1 created the first editable diagram and timing sources:

| Asset | Status | Notes |
| --- | --- | --- |
| `docs/diagrams/overall_microblaze_axi_soc.drawio` | Created | Shows PC terminal, AXI UART Lite, MicroBlaze, AXI interconnect, planned custom peripherals, and Basys3 devices. |
| `docs/diagrams/axi_address_map.drawio` | Created | Shows planned global 64 KB address ranges. |
| `docs/diagrams/axi_gpio_core_wrapper.drawio` | Created | Shows AXI shell, register bank, LED path, switch/button sync, debounce, and edge flags. |
| `docs/wavedrom/axi_lite_write.json` | Created | Basic AXI4-Lite write handshake intent. |
| `docs/wavedrom/axi_lite_read.json` | Created | Basic AXI4-Lite read handshake intent. |
| `docs/wavedrom/axi_gpio_write_read.json` | Created | GPIO write/read register behavior intent. |
| `docs/wavedrom/axi_gpio_button_edge.json` | Created | Button synchronization/debounce/edge flag timing intent. |

The created draw.io files are intentionally simple source diagrams, not screenshots. The WaveDrom files are intended behavior diagrams and are not implementation testbenches.


## Prompt 4 Asset Status

Prompt 4 created the editable FND specification assets:

| Asset | Status | Notes |
| --- | --- | --- |
| `docs/diagrams/axi_fnd_core_wrapper.drawio` | Created | Shows MicroBlaze AXI writes, AXI4-Lite wrapper, register bank, reused `fnd_controller.v`, display-enable output gating, and Basys3 FND outputs. |
| `docs/wavedrom/axi_fnd_register_update.json` | Created | Shows AXI writes updating `TIMER_VALUE` and `SENSOR_VALUE` and driving reused-controller inputs. |
| `docs/wavedrom/axi_fnd_enable_disable.json` | Created | Shows `display_enable` gating final FND outputs between blank and controller-driven states. |

These files are editable source assets, not screenshots.
## Prompt 7 Asset Status

Prompt 7 created the editable Timer specification assets:

| Asset | Status | Notes |
| --- | --- | --- |
| `docs/diagrams/axi_timer_core_wrapper.drawio` | Created | Shows MicroBlaze AXI access, AXI4-Lite wrapper, Timer register bank, reused `stopwatch_datapath`, reused `watch_datapath`, reused `watch_fnd_adapter`, reference-only legacy control/top files, and later software Timer-to-FND bridge. |
| `docs/wavedrom/axi_timer_control_command.json` | Created | Shows `CONTROL` writes and one-clock `COMMAND` pulse behavior. |
| `docs/wavedrom/axi_timer_watch_edit.json` | Created | Shows watch set mode, target selection, gated edit pulse, raw digit update, and packed `WATCH_VALUE` update. |
| `docs/wavedrom/axi_timer_read_values.json` | Created | Shows AXI reads of `STOPWATCH_VALUE`, `WATCH_VALUE`, and `STATUS`. |

These files are editable source assets, not screenshots. No Timer RTL, testbench, or simulation output was created in Prompt 7.
## Prompt 7.5 Path Migration Asset Note

Editable diagram and WaveDrom sources now live under the canonical project root:

```text
D:\OndeviceAI2_AXI4_Lite\20260622_AXI4_Lite_SoC
```

Paths in this document are project-root-relative unless explicitly marked otherwise.
## Unattended Phase A Sensor Asset Status

| Asset | Status | Notes |
| --- | --- | --- |
| `docs/diagrams/axi_sensor_core_wrapper.drawio` | Created | Shows AXI shell, Sensor register bank, reused `sr04.v`, reused `dht11.v`, external sensor pins, and no direct FND coupling. |
| `docs/wavedrom/axi_sensor_command_status.json` | Created | Shows CONTROL/COMMAND start pulse and status timing intent. |
| `docs/wavedrom/axi_sensor_sr04_echo.json` | Created | Shows SR04 trigger/echo/distance readback timing intent. |
| `docs/wavedrom/axi_sensor_dht11_start.json` | Created | Shows DHT11 start-line and DHT value timing intent. |

These files are editable source assets, not screenshots.

## Unattended Phase D SPI Asset Status

| Asset | Status | Notes |
| --- | --- | --- |
| `docs/diagrams/axi_spi_core_wrapper.drawio` | Created | Shows AXI shell, SPI register bank, reused `spi_master_byte.sv`, external SPI pins, and optional future `spi_slave_byte.sv` support. |
| `docs/wavedrom/axi_spi_transaction.json` | Created | Shows SPI byte-transfer timing intent. |
| `docs/wavedrom/axi_spi_control_status.json` | Created | Shows AXI control/start/status timing intent. |

These files are editable source assets, not screenshots. No SPI RTL or simulation was created in this phase.
## Prompt 16 I2C Asset Status

| Asset | Status | Notes |
| --- | --- | --- |
| `docs/diagrams/axi_i2c_core_wrapper.drawio` | Created | Shows AXI shell, I2C register bank, reused `i2c_master_core.sv`, optional/reference-only `i2c_slave_core.sv`, open-drain SCL/SDA inout pins, and low-level MicroBlaze command sequencing. |
| `docs/wavedrom/axi_i2c_command_status.json` | Created | Shows AXI write to `COMMAND`, one-clock `cmd_valid`, busy/done/sticky status, and status readback. |
| `docs/wavedrom/axi_i2c_write_byte.json` | Created | Shows conceptual START, WRITE_BYTE, and STOP command sequence timing. |
| `docs/wavedrom/axi_i2c_read_byte.json` | Created | Shows conceptual READ_BYTE, RXDATA update, and ACK/NACK behavior. |

These files are editable source assets, not screenshots. No I2C RTL, testbench, simulation output, UVM, software, or block-design assets were created in Prompt 16.
## Prompt 19 Integration Asset Status

| Asset | Status | Notes |
| --- | --- | --- |
| `docs/diagrams/microblaze_axi_soc_integration_ready.drawio` | Created | Shows PC terminal, AXI UART Lite, MicroBlaze, AXI interconnect, six custom AXI4-Lite peripherals, external board pins, software Timer/Sensor-to-FND data flow, SPI/I2C buses, and UVM deferred outside the datapath. |
| `docs/wavedrom/microblaze_uart_to_axi_command_flow.json` | Created | Shows conceptual UART command receive, MicroBlaze software decode, AXI write/read, peripheral status/data readback, and UART response. |

These files are editable source assets, not screenshots. No Vivado block design or packaged IP was created in Prompt 19.
