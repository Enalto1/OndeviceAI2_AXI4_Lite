# Source Audit

Step 0 scope: analyze existing reference RTL only. No RTL files were modified, copied, wrapped, or regenerated during this audit.

## Audited Paths

| Item | Path | Step 0 handling |
| --- | --- | --- |
| Reference RTL root | `D:\OndeviceAI2_AXI4_Lite\axi_project_unique_sources` | Read-only audit source |
| Reference RTL files | `D:\OndeviceAI2_AXI4_Lite\axi_project_unique_sources\sources` | Leave unchanged |
| Source manifest | `D:\OndeviceAI2_AXI4_Lite\axi_project_unique_sources\MANIFEST.md` | Used to confirm source list and hashes |
| UVM reference | `D:\OndeviceAI2_AXI4_Lite\UVM_testbench_ref\ram_uvm_split` | Read-only structure reference |

## Audit Summary

- Analyzed 21 unique RTL/SystemVerilog source files from `axi_project_unique_sources/sources`.
- Identified 47 module declarations across those files.
- `MANIFEST.md` reports no duplicate-content source files in the archived source set.
- The existing `TOP.v` integration is a legacy UART/ASCII-controlled design and should not become the MicroBlaze top.
- The first MicroBlaze system should use Xilinx AXI UART Lite for the PC console, with command parsing and status printing in software.
- Existing reusable RTL should become leaf logic inside future AXI4-Lite slave wrappers.

## Source File Audit Table

| File | Identified module(s) | Observed purpose | Reusable as-is? | Top/reference wrapper? | Leave unchanged? | Future AXI reuse target |
| --- | --- | --- | --- | --- | --- | --- |
| `ASCII_decoder.v` | `ASCII_decoder` | Decodes legacy UART ASCII command bytes into virtual switch/button/status control pulses. | No for initial MicroBlaze console; yes as reference for optional custom UART command design. | Legacy command parser. | Yes | Reference-only initially; possible optional custom UART/control peripheral later. |
| `ASCII_sender.v` | `ASCII_sender` | Formats timer/sensor/status values as ASCII bytes for the legacy UART transmit FIFO. | No for initial MicroBlaze console; yes as reference for optional custom UART status path. | Legacy status formatter. | Yes | Reference-only initially; possible optional custom UART/status peripheral later. |
| `INPUT_Merger_sw4.v` | `INPUT_Merger_sw4` | Merges physical 4-bit switches with virtual switch values and mask. | Possibly, if software-driven virtual switch emulation is desired. | Small legacy glue module. | Yes | `axi_gpio_core` optional helper; otherwise reference-only. |
| `TOP.v` | `TOP` | Board-level legacy integration: UART, FIFOs, ASCII decoder/sender, button debounce, system control, stopwatch/watch, SR04, DHT11, FND, LEDs. | No as a new SoC top; useful as integration reference. | Yes, legacy top. | Yes | Reference for signal flow and board-level behavior only. |
| `button_debounce.v` | `button_debounce` | Debounces one pushbutton input into a cleaned button output. | Yes. | Leaf module. | Yes | `axi_gpio_core` button input conditioning and optional edge-detect logic. |
| `dht11.v` | `dht11`, `dht11_controller`, `tick_gen_us_dht11` | DHT11 single-wire sensor controller with humidity/temperature outputs and valid indication. | Mostly yes; wrapper may need extra status tracking around `valid`. | Contains reusable top plus leaf controller/tick generator. | Yes | `axi_sensor_core` DHT11 channel. |
| `fifo.v` | `fifo`, `register_file`, `control_unit` | Small byte FIFO used by the legacy UART paths. | Yes for optional custom UART or byte-stream buffering. | Leaf/storage helper. | Yes | Optional custom AXI UART peripheral; possible SPI/I2C buffering if later justified. |
| `fnd_controller.v` | `fnd_controller`, `mux_2x1`, `mux_3x1`, `mux_4x1`, `mux_8x1`, `digit_splitter`, `digit_splitter_100`, `bcd`, `clk_div_1khz`, `counter_8`, `decoder_2x4`, `dot_indicator` | Basys3 4-digit FND display scanning, digit splitting, BCD segment decode, dot control, and mode selection. | Yes. Must be reused, not recreated. | Reusable FND leaf subsystem. | Yes | `axi_fnd_core`; may also be driven by timer/sensor registers. |
| `i2c_master_core.sv` | `i2c_master_core` | Command-based I2C master with start/stop/write/read commands, ready/done/busy/nack/rx status, and open-drain drive-low outputs. | Yes, subject to Vivado 2020.2 SystemVerilog synthesis check. | Leaf serial controller. | Yes | `axi_i2c_core` master channel. |
| `i2c_slave_core.sv` | `i2c_slave_core` | I2C slave core with address detect, RX/TX byte handshaking, start/stop pulses, and open-drain SDA control. | Yes for optional slave mode or verification companion. | Leaf serial controller. | Yes | Optional `axi_i2c_core` slave mode or board-to-board test support. |
| `mux_2x1_nbit.v` | `mux_2x1_nbit` | Parameterized two-input mux. | Yes if needed. | Leaf utility. | Yes | `axi_timer_core` or shared display/control glue if needed. |
| `spi_master_byte.sv` | `spi_master_byte` | Byte-wide SPI master. A one-clock `start` launches one transfer and returns `rx_data`, `busy`, `done`, `sclk`, `mosi`, and `ss_n`. | Yes, subject to Vivado 2020.2 SystemVerilog synthesis check. | Leaf serial controller. | Yes | `axi_spi_core` master channel. |
| `spi_slave_byte.sv` | `spi_slave_byte` | Byte-wide SPI slave with CPOL/CPHA handling, TX load, RX valid, byte done, busy, MISO output enable. | Yes for optional slave mode or verification companion. | Leaf serial controller. | Yes | Optional `axi_spi_core` slave mode or loopback test support. |
| `sr04.v` | `sr04`, `sr04_controller`, `tick_gen_us` | HC-SR04 ultrasonic controller with trigger output, echo input, 1 us tick, and 9-bit distance result. | Mostly yes; wrapper may need explicit busy/done/status around measurement. | Contains reusable top plus leaf controller/tick generator. | Yes | `axi_sensor_core` SR04 channel. |
| `stopwatch_datapath.v` | `stopwatch_datapath`, `tick_counter_st`, `tick_gen_100hz_st` | Stopwatch datapath with 100 Hz tick and msec/sec/min/hour counters. | Yes. | Leaf timer datapath. | Yes | `axi_timer_core` stopwatch mode. |
| `system_control_unit.v` | `system_control_unit`, `main_mode_decoder_sys`, `timer_switch_router_sys`, `button_router_sys`, `fnd_sel_router_sys` | Legacy switch/button routing for timer, ultrasonic, DHT, display mode, and status request. | No for initial MicroBlaze control; useful as behavior reference. | Legacy control wrapper/glue. | Yes | Reference-only; MicroBlaze software plus AXI registers replace this path. |
| `top_control_unit.v` | `top_control_unit` | Legacy stopwatch/watch control state from switches and buttons; produces run/clear/set/edit/display controls and LEDs. | No as an AXI block; useful as timer behavior reference. | Legacy control block. | Yes | Reference for `axi_timer_core` register semantics. |
| `top_stopwatch_watch.v` | `top_stopwatch_watch` | Legacy integrated stopwatch/watch/FND top using debounced buttons, timer control, datapaths, muxing, and FND controller. | No as an AXI block; useful for hierarchy and behavior reference. | Yes, legacy top/reference wrapper. | Yes | Reference for `axi_timer_core` and `axi_fnd_core` integration. |
| `uart.v` | `uart`, `uart_rx`, `uart_tx`, `baud_tick_gen` | Legacy UART RX/TX with baud tick generator. | Not for main PC console; yes for optional custom UART later. | Leaf serial subsystem, but legacy for current goal. | Yes | Optional custom AXI4-Lite UART peripheral later; not part of initial MicroBlaze console. |
| `watch_datapath.v` | `watch_datapath`, `tick_counter_wt`, `tick_gen_100hz_wt` | Watch/clock datapath with run/set modes, digit/time selection, edit up/down commands, and 100 Hz tick. | Yes. | Leaf timer datapath. | Yes | `axi_timer_core` watch mode. |
| `watch_fnd_adapter.v` | `watch_fnd_adapter` | Converts watch digit fields into packed hour/min/sec/msec values for FND display interface. | Yes. | Leaf adapter. | Yes | `axi_timer_core` and/or `axi_fnd_core` display data adaptation. |

## Reusable Leaf Cores By Peripheral

| Planned AXI peripheral | Reused reference RTL files | Reuse note |
| --- | --- | --- |
| `axi_gpio_core` | `button_debounce.v`, optionally `INPUT_Merger_sw4.v` | Debounce physical buttons; optionally preserve virtual switch merge behavior if needed. |
| `axi_fnd_core` | `fnd_controller.v`, optionally `watch_fnd_adapter.v` | Reuse `fnd_controller` directly. Do not recreate the FND controller from scratch. |
| `axi_timer_core` | `stopwatch_datapath.v`, `watch_datapath.v`, `watch_fnd_adapter.v`; reference `top_control_unit.v` | Wrap datapaths with AXI registers for run/clear/mode/edit controls and readback counters. |
| `axi_sensor_core` | `dht11.v`, `sr04.v` | Wrap start pulses, sensor result readback, valid/done tracking, and any needed busy/error status. |
| `axi_spi_core` | `spi_master_byte.sv`, optionally `spi_slave_byte.sv` | Wrap byte command, CPOL/CPHA, clock divisor, TX/RX data, busy/done status. |
| `axi_i2c_core` | `i2c_master_core.sv`, optionally `i2c_slave_core.sv` | Wrap command interface, TX/RX bytes, ready/done/busy/nack status, and board-level open-drain pads. |
| Optional custom UART | `uart.v`, `fifo.v`, optionally `ASCII_decoder.v`, `ASCII_sender.v` | Not part of the initial MicroBlaze console. Preserve for later optional AXI UART reuse. |

## Reference-Only Integration And Control Files

These files should remain unchanged and should not be used as the first MicroBlaze SoC top:

- `TOP.v`
- `top_stopwatch_watch.v`
- `top_control_unit.v`
- `system_control_unit.v`
- `ASCII_decoder.v`
- `ASCII_sender.v`
- `INPUT_Merger_sw4.v` unless a GPIO virtual-switch feature is explicitly retained
- `uart.v` and `fifo.v` for the main console path, because Xilinx AXI UART Lite is the required PC console for the first system

## Notes And Assumptions

- The clock-dependent leaf cores use 100 MHz timing assumptions in several tick generators. Basys3 uses a 100 MHz system clock, which matches the current code style.
- Several useful sensor status concepts, such as `busy`, `done`, and `error`, are not explicit top-level outputs in `dht11.v` and `sr04.v`. Future AXI wrappers should add wrapper-level status without modifying the reference source unless a clear need is documented.
- SystemVerilog files (`*.sv`) are present for SPI and I2C cores. Vivado 2020.2 compatibility must be checked during the relevant peripheral phase.
- No register map has been finalized in Step 0. Future spec documents must define offsets and bit fields before RTL wrapper work begins.
