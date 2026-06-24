# Peripheral External Port Summary

## Actual Wrapper Port Review

| Peripheral | External non-AXI port | Direction | Width | Board usage | Expected Basys3 connection category |
| --- | --- | --- | --- | --- | --- |
| `axi_gpio_core` | `led_o` | output | 16 | Drive Basys3 LEDs | LEDs |
| `axi_gpio_core` | `sw_i` | input | 16 | Read Basys3 switches | Switches |
| `axi_gpio_core` | `btn_i` | input | 5 | Read Basys3 buttons | Buttons |
| `axi_fnd_core` | `fnd_com_o` | output | 4 | Drive four-digit enable/common lines | Seven-segment display anode/common control |
| `axi_fnd_core` | `fnd_data_o` | output | 8 | Drive segment and dot data | Seven-segment segment bus |
| `axi_timer_core` | None | N/A | N/A | Software-read internal timer/watch values | No direct board IO |
| `axi_sensor_core` | `sr04_echo_i` | input | 1 | SR04 echo input | PMOD/external sensor input |
| `axi_sensor_core` | `sr04_trig_o` | output | 1 | SR04 trigger output | PMOD/external sensor output |
| `axi_sensor_core` | `dht11_io` | inout | 1 | DHT11 single-wire data | PMOD/external sensor bidirectional |
| `axi_spi_core` | `spi_sclk_o` | output | 1 | SPI clock | PMOD SPI |
| `axi_spi_core` | `spi_mosi_o` | output | 1 | SPI MOSI | PMOD SPI |
| `axi_spi_core` | `spi_miso_i` | input | 1 | SPI MISO | PMOD SPI |
| `axi_spi_core` | `spi_ss_n_o` | output | 1 | SPI active-low slave select | PMOD SPI |
| `axi_i2c_core` | `i2c_scl_io` | inout | 1 | I2C SCL open-drain bus | PMOD I2C with pull-up |
| `axi_i2c_core` | `i2c_sda_io` | inout | 1 | I2C SDA open-drain bus | PMOD I2C with pull-up |

## Notes

- `axi_timer_core` intentionally has no external non-AXI ports. It is controlled and observed through AXI registers.
- `dht11_io`, `i2c_scl_io`, and `i2c_sda_io` require careful top-level inout handling and XDC planning.
- Exact Basys3 pins are intentionally not assigned here because no verified XDC file is present in the canonical project root.
