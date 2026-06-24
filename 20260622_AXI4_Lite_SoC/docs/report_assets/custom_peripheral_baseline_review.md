# Custom Peripheral Baseline Review

## Current Status Summary

| Peripheral | Base address | Wrapper path | Reused reference RTL | External ports | Simulation result | Report path | UVM status | Board status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `axi_gpio_core` | `0x44A0_0000` | `rtl_work/axi_peripherals/axi_gpio_core/hdl/axi_gpio_core.v` | `rtl_work/legacy_adapted/button_debounce_level/button_debounce_level.v` | `led_o[15:0]`, `sw_i[15:0]`, `btn_i[4:0]` | `PASS tests_passed=12 errors=0` | `docs/report_assets/axi_gpio_core_vivado_sim_report.md` | Deferred | Not started |
| `axi_fnd_core` | `0x44A1_0000` | `rtl_work/axi_peripherals/axi_fnd_core/hdl/axi_fnd_core.v` | `axi_project_unique_sources/sources/fnd_controller.v` | `fnd_com_o[3:0]`, `fnd_data_o[7:0]` | `PASS tests_passed=16 errors=0` | `docs/report_assets/axi_fnd_core_vivado_sim_report.md` | Deferred | Not started |
| `axi_timer_core` | `0x44A2_0000` | `rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v` | `stopwatch_datapath.v`, `watch_datapath.v`, `watch_fnd_adapter.v` | None | `PASS tests_passed=19 errors=0` | `docs/report_assets/axi_timer_core_vivado_sim_report.md` | Deferred | Not started |
| `axi_sensor_core` | `0x44A3_0000` | `rtl_work/axi_peripherals/axi_sensor_core/hdl/axi_sensor_core.v` | `sr04.v`, `dht11.v` | `sr04_echo_i`, `sr04_trig_o`, `dht11_io` | `PASS tests_passed=17 errors=0` | `docs/report_assets/axi_sensor_core_vivado_sim_report.md` | Deferred | Not started |
| `axi_spi_core` | `0x44A4_0000` | `rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v` | `spi_master_byte.sv` | `spi_sclk_o`, `spi_mosi_o`, `spi_miso_i`, `spi_ss_n_o` | `PASS tests_passed=20 errors=0` | `docs/report_assets/axi_spi_core_vivado_sim_report.md` | Deferred | Not started |
| `axi_i2c_core` | `0x44A5_0000` | `rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v` | `i2c_master_core.sv` | `i2c_scl_io`, `i2c_sda_io` | `PASS tests_passed=23 errors=0` | `docs/report_assets/axi_i2c_core_vivado_sim_report.md` | Deferred | Not started |

## Pass Evidence

| Peripheral | Directed tests | Result |
| --- | ---: | --- |
| GPIO | 12 | `PASS tests_passed=12 errors=0` |
| FND | 16 | `PASS tests_passed=16 errors=0` |
| Timer | 19 | `PASS tests_passed=19 errors=0` |
| Sensor | 17 | `PASS tests_passed=17 errors=0` |
| SPI | 20 | `PASS tests_passed=20 errors=0` |
| I2C | 23 | `PASS tests_passed=23 errors=0` |

The full Prompt 19 regression reran all six focused simulations and preserved fresh logs under each `sim/vivado/<peripheral>/logs/` directory.

## Integration Readiness

The custom peripheral RTL wrappers are ready for Vivado IP packaging preparation. They are not yet packaged as local IP, no MicroBlaze block design has been created, no MicroBlaze software has been written, and XDC/board pin mapping remains pending.

Each custom peripheral is an AXI4-Lite slave. The intended system integration has MicroBlaze as the main AXI master and AXI UART Lite as the PC console. Software will parse UART commands and perform memory-mapped reads and writes.

## Known Limitations

- The Sensor DHT11 simulation covers command/start-line/status sanity; full DHT11 response-frame modeling remains future verification work.
- The I2C wrapper exposes a low-level command interface. It is not a high-level device transaction engine.
- The SPI wrapper is master-only. `spi_slave_byte.sv` remains optional/reference-only.
- The FND peripheral is software-updated and intentionally decoupled from Timer and Sensor; MicroBlaze software must bridge Timer/Sensor values into FND registers.
- UVM remains deferred until after custom peripheral RTL and basic Vivado simulation coverage are complete.
- Board-level timing, external pull-ups, PMOD wiring, and final XDC constraints remain future work.

## Final Recommendation

Proceed to custom IP packaging preparation, then package the six local Vivado IP blocks, then create the MicroBlaze block design and software command parser.
