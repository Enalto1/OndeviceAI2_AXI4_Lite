# Reuse Strategy

Step 0 strategy: preserve the existing RTL as stable reference source and wrap it with AXI4-Lite interfaces later. Do not rewrite equivalent logic that already exists in the reference source tree.

## Reuse Principles

1. Keep `axi_project_unique_sources/sources` read-only.
2. Instantiate existing leaf modules inside new AXI4-Lite slave wrappers instead of recreating the same behavior.
3. Use Xilinx AXI4-Lite slave template structure for wrappers and preserve the template handshake logic as much as possible.
4. Change only the wrapper register map, write logic, read mux, pulse generation, and leaf-core connections.
5. If a reference RTL file cannot be reused as-is, copy it into a working RTL directory, rename it clearly, and document the reason before editing.
6. Use Xilinx AXI UART Lite for the main PC terminal. Legacy `uart.v`, `fifo.v`, `ASCII_decoder.v`, and `ASCII_sender.v` are not the initial console path.

## Peripheral Reuse Plan

| Peripheral | Wrapper role | Existing RTL to reuse | Expected wrapper responsibilities |
| --- | --- | --- | --- |
| `axi_gpio_core` | AXI GPIO for LEDs, switches, buttons, optional debounce/edge detection | `button_debounce.v`; optional `INPUT_Merger_sw4.v` | Drive LED output registers, expose switch/button input registers, debounce button inputs, optionally generate edge/status bits. |
| `axi_fnd_core` | AXI-controlled 4-digit FND display | `fnd_controller.v`; optional `watch_fnd_adapter.v` | Provide display mode/value registers, connect FND outputs to Basys3 `an` and `seg`, keep FND scan logic in the reused controller. |
| `axi_timer_core` | Stopwatch and watch control/status peripheral | `stopwatch_datapath.v`, `watch_datapath.v`, `watch_fnd_adapter.v`; behavior reference from `top_control_unit.v` | Generate one-clock control pulses for clear/up/down/edit, hold run/mode levels, expose counter readbacks, optionally feed FND-formatted values. |
| `axi_sensor_core` | DHT11 and SR04 sensor control/status peripheral | `dht11.v`, `sr04.v` | Generate one-clock start pulses, expose humidity/temperature/distance, add wrapper-level valid/done/busy/error tracking where needed. |
| `axi_spi_core` | Byte SPI master, optional slave/test mode | `spi_master_byte.sv`; optional `spi_slave_byte.sv` | Hold CPOL/CPHA/clock divider/TX data, generate start pulse, expose RX data, busy, done, and optional slave RX status. |
| `axi_i2c_core` | Command-level I2C master, optional slave mode | `i2c_master_core.sv`; optional `i2c_slave_core.sv` | Hold command/TX/read-ACK data, generate `cmd_valid`, expose `cmd_ready`, `done`, `busy`, `nack`, RX byte, and open-drain pad controls. |

## Modules To Wrap Instead Of Rewrite

- `fnd_controller` must be reused for FND display scanning and segment decode.
- `stopwatch_datapath` and `watch_datapath` should remain the timer datapaths.
- `dht11_controller` and `sr04_controller` should remain the sensor protocol engines.
- `spi_master_byte` should remain the SPI transfer engine.
- `i2c_master_core` should remain the I2C command engine.
- `button_debounce` should be reused for physical button conditioning.

## Explicit FND Reuse Rule

Do not recreate the FND controller from scratch. The future `axi_fnd_core` should instantiate the existing `fnd_controller.v` and adapt AXI registers to its existing inputs:

- `i_main_mode`
- `i_display_sel`
- `msec`, `sec`, `min`, `hour`
- `distance`
- `humidity`, `temperature`
- `fnd_com`, `fnd_data`

Any change to FND behavior should first be attempted through wrapper-side register values. Editing or replacing `fnd_controller.v` requires a documented reason.

## Legacy Reference-Only Control Path

| Legacy file | Step 0 classification | Replacement in MicroBlaze SoC |
| --- | --- | --- |
| `uart.v` | Optional future custom UART, not main console | Xilinx AXI UART Lite IP |
| `fifo.v` | Optional byte-stream helper | AXI UART Lite FIFOs and MicroBlaze software initially |
| `ASCII_decoder.v` | Reference-only command parser | MicroBlaze C command parser |
| `ASCII_sender.v` | Reference-only status formatter | MicroBlaze C status printing |
| `system_control_unit.v` | Reference-only board control router | AXI register writes and software control flow |
| `top_control_unit.v` | Reference-only timer control behavior | `axi_timer_core` register semantics |
| `TOP.v` | Reference top, not new SoC top | Vivado block design with MicroBlaze, AXI interconnect, AXI UART Lite, and custom AXI slaves |

## Possible Adaptation Candidates

These are not Step 0 implementation tasks. They are flagged for later design review.

| Source | Possible issue | Preferred later action |
| --- | --- | --- |
| `dht11.v` | Top-level exposes `valid` only through `led`; no explicit busy/error ports. | Keep reference file unchanged and add wrapper-level status tracking when possible. If core internals must be exposed, copy/rename before editing. |
| `sr04.v` | No explicit busy/done output at top-level; measurement completion is inferred from distance update/control state. | Prefer wrapper-level start tracking and sampled distance status first. Modify only with documented need. |
| `top_stopwatch_watch.v` | Integrated top has board-button control and a port named `btuD`, reflecting legacy top-level style. | Do not wrap this top directly. Reuse datapaths and FND controller instead. |
| `*.sv` SPI/I2C cores | Vivado 2020.2 SystemVerilog support must be verified during synthesis/IP packaging. | Keep SV files as SV. Use mixed-language flow and avoid converting unless explicitly requested. |

## Register Policy For Future Wrappers

- One-clock pulses: `start`, `clear`, `up`, `down`, `cmd_valid`, write-one command bits.
- Level fields: `enable`, `run`, `mode`, `cpol`, `cpha`, `clk_div`, persistent configuration values.
- Read-only status/data: `busy`, `done`, `error`, `rx_data`, sensor results, timer counts.
- Status/data registers should not be writable unless the spec explicitly requires it.

## Step 0 Boundary

No AXI wrapper RTL, register implementation, Vivado project, simulation testbench, or UVM environment was created in Step 0. This document is a planning asset for the next design/spec phase.

## Prompt 2 GPIO Debounce Adaptation

Prompt 2 created one documented adapted legacy helper:

```text
rtl_work/legacy_adapted/button_debounce_level/button_debounce_level.v
```

Reason:

- The original `button_debounce.v` exposes only a one-clock rising pulse.
- `axi_gpio_core` needs both stable debounced level readback and rising-edge flag generation.
- The adapted copy preserves the sampled debounce concept while exposing `o_btn_level` and `o_btn_pulse`.

The original reference file remains unchanged:

```text
axi_project_unique_sources/sources/button_debounce.v
```

`axi_gpio_core.v` instantiates five explicit adapted debounce helpers and does not use generate loops.

