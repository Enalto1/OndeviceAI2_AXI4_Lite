# Block Design External Port Summary

This summary reflects the Prompt 22 XDC and reset-policy update.

| Port | Direction | Width | Connected IP/block | Basys3 mapping |
| --- | --- | --- | --- | --- |
| `clk_100mhz_i` | input | 1 | System clock tree | 100 MHz oscillator, W5 |
| `reset_i` | input | 1 | `rstn_inv_0/Op1`; inverter output drives `proc_sys_reset_0/ext_reset_in` | External PMOD JA4/G2 active-low reset with PULLUP true; CPU_RESETN/C12 was rejected during Prompt 23 bitstream build |
| `uart_rxd_i` | input | 1 | `axi_uartlite_0/rx` | USB-UART RX, B18 |
| `uart_txd_o` | output | 1 | `axi_uartlite_0/tx` | USB-UART TX, A18 |
| `led_o` | output | 16 | `axi_gpio_core_0/led_o` | Basys3 LD15..LD0 |
| `sw_i` | input | 16 | `axi_gpio_core_0/sw_i` | Basys3 SW15..SW0 |
| `btn_i` | input | 5 | `axi_gpio_core_0/btn_i` | Basys3 btnC/btnU/btnL/btnR/btnD |
| `fnd_com_o` | output | 4 | `axi_fnd_core_0/fnd_com_o` | AN0..AN3 |
| `fnd_data_o` | output | 8 | `axi_fnd_core_0/fnd_data_o` | CA..CG/DP |
| `sr04_echo_i` | input | 1 | `axi_sensor_core_0/sr04_echo_i` | PMOD JA2, L2 |
| `sr04_trig_o` | output | 1 | `axi_sensor_core_0/sr04_trig_o` | PMOD JA1, J1 |
| `dht11_io` | inout | 1 | `axi_sensor_core_0/dht11_io` | PMOD JA3, J2, pull-up enabled |
| `spi_sclk_o` | output | 1 | `axi_spi_core_0/spi_sclk_o` | PMOD JB1, A14 |
| `spi_mosi_o` | output | 1 | `axi_spi_core_0/spi_mosi_o` | PMOD JB2, A16 |
| `spi_miso_i` | input | 1 | `axi_spi_core_0/spi_miso_i` | PMOD JB3, B15 |
| `spi_ss_n_o` | output | 1 | `axi_spi_core_0/spi_ss_n_o` | PMOD JB4, B16 |
| `i2c_scl_io` | inout | 1 | `axi_i2c_core_0/i2c_scl_io` | PMOD JC1, K17, pull-up enabled |
| `i2c_sda_io` | inout | 1 | `axi_i2c_core_0/i2c_sda_io` | PMOD JC2, M18, pull-up enabled |

Prompt 22 did not rename any top-level wrapper ports. `rstn_inv_0` is a BD-only reset adapter used to map the active-low external reset safely into the active-high Processor System Reset external input. Prompt 23 moved the physical reset assignment to PMOD JA4/G2 after Vivado rejected CPU_RESETN/C12 for the selected part.



