# Basys3 XDC Pin Map

Source XDC: `constraints/basys3/basys3_axi_soc.xdc`

The logical signal names below are the actual top-level wrapper ports from `microblaze_axi_soc_bd_wrapper.v`.

| Logical signal | Board signal | PACKAGE_PIN | IOSTANDARD | Direction | Notes |
| --- | --- | --- | --- | --- | --- |
| `clk_100mhz_i` | 100 MHz oscillator | W5 | LVCMOS33 | input | `create_clock -period 10.000` |
| `reset_i` | PMOD JA4 external reset | G2 | LVCMOS33 | input | Current active-low reset fallback, PULLUP true, inverted in BD by `rstn_inv_0`; CPU_RESETN/C12 was rejected by Vivado for `xc7a35tcpg236-1` |
| `uart_rxd_i` | USB-UART RX | B18 | LVCMOS33 | input | AXI UART Lite RX |
| `uart_txd_o` | USB-UART TX | A18 | LVCMOS33 | output | AXI UART Lite TX |
| `sw_i[0]` | SW0 | V17 | LVCMOS33 | input | GPIO switch |
| `sw_i[1]` | SW1 | V16 | LVCMOS33 | input | GPIO switch |
| `sw_i[2]` | SW2 | W16 | LVCMOS33 | input | GPIO switch |
| `sw_i[3]` | SW3 | W17 | LVCMOS33 | input | GPIO switch |
| `sw_i[4]` | SW4 | W15 | LVCMOS33 | input | GPIO switch |
| `sw_i[5]` | SW5 | V15 | LVCMOS33 | input | GPIO switch |
| `sw_i[6]` | SW6 | W14 | LVCMOS33 | input | GPIO switch |
| `sw_i[7]` | SW7 | W13 | LVCMOS33 | input | GPIO switch |
| `sw_i[8]` | SW8 | V2 | LVCMOS33 | input | GPIO switch |
| `sw_i[9]` | SW9 | T3 | LVCMOS33 | input | GPIO switch |
| `sw_i[10]` | SW10 | T2 | LVCMOS33 | input | GPIO switch |
| `sw_i[11]` | SW11 | R3 | LVCMOS33 | input | GPIO switch |
| `sw_i[12]` | SW12 | W2 | LVCMOS33 | input | GPIO switch |
| `sw_i[13]` | SW13 | U1 | LVCMOS33 | input | GPIO switch |
| `sw_i[14]` | SW14 | T1 | LVCMOS33 | input | GPIO switch |
| `sw_i[15]` | SW15 | R2 | LVCMOS33 | input | GPIO switch |
| `led_o[0]` | LD0 | U16 | LVCMOS33 | output | GPIO LED |
| `led_o[1]` | LD1 | E19 | LVCMOS33 | output | GPIO LED |
| `led_o[2]` | LD2 | U19 | LVCMOS33 | output | GPIO LED |
| `led_o[3]` | LD3 | V19 | LVCMOS33 | output | GPIO LED |
| `led_o[4]` | LD4 | W18 | LVCMOS33 | output | GPIO LED |
| `led_o[5]` | LD5 | U15 | LVCMOS33 | output | GPIO LED |
| `led_o[6]` | LD6 | U14 | LVCMOS33 | output | GPIO LED |
| `led_o[7]` | LD7 | V14 | LVCMOS33 | output | GPIO LED |
| `led_o[8]` | LD8 | V13 | LVCMOS33 | output | GPIO LED |
| `led_o[9]` | LD9 | V3 | LVCMOS33 | output | GPIO LED |
| `led_o[10]` | LD10 | W3 | LVCMOS33 | output | GPIO LED |
| `led_o[11]` | LD11 | U3 | LVCMOS33 | output | GPIO LED |
| `led_o[12]` | LD12 | P3 | LVCMOS33 | output | GPIO LED |
| `led_o[13]` | LD13 | N3 | LVCMOS33 | output | GPIO LED |
| `led_o[14]` | LD14 | P1 | LVCMOS33 | output | GPIO LED |
| `led_o[15]` | LD15 | L1 | LVCMOS33 | output | GPIO LED |
| `btn_i[0]` | btnC | U18 | LVCMOS33 | input | GPIO button, not system reset |
| `btn_i[1]` | btnU | T18 | LVCMOS33 | input | GPIO button |
| `btn_i[2]` | btnL | W19 | LVCMOS33 | input | GPIO button |
| `btn_i[3]` | btnR | T17 | LVCMOS33 | input | GPIO button |
| `btn_i[4]` | btnD | U17 | LVCMOS33 | input | GPIO button |
| `fnd_data_o[0]` | CA | W7 | LVCMOS33 | output | Seven-segment segment A |
| `fnd_data_o[1]` | CB | W6 | LVCMOS33 | output | Seven-segment segment B |
| `fnd_data_o[2]` | CC | U8 | LVCMOS33 | output | Seven-segment segment C |
| `fnd_data_o[3]` | CD | V8 | LVCMOS33 | output | Seven-segment segment D |
| `fnd_data_o[4]` | CE | U5 | LVCMOS33 | output | Seven-segment segment E |
| `fnd_data_o[5]` | CF | V5 | LVCMOS33 | output | Seven-segment segment F |
| `fnd_data_o[6]` | CG | U7 | LVCMOS33 | output | Seven-segment segment G |
| `fnd_data_o[7]` | DP | V7 | LVCMOS33 | output | Decimal point |
| `fnd_com_o[0]` | AN0 | U2 | LVCMOS33 | output | Digit enable/common |
| `fnd_com_o[1]` | AN1 | U4 | LVCMOS33 | output | Digit enable/common |
| `fnd_com_o[2]` | AN2 | V4 | LVCMOS33 | output | Digit enable/common |
| `fnd_com_o[3]` | AN3 | W4 | LVCMOS33 | output | Digit enable/common |
| `sr04_trig_o` | JA1 | J1 | LVCMOS33 | output | Provisional SR04 trigger |
| `sr04_echo_i` | JA2 | L2 | LVCMOS33 | input | Provisional SR04 echo, verify sensor voltage |
| `dht11_io` | JA3 | J2 | LVCMOS33 | inout | PULLUP true; external pull-up still recommended |
| `spi_sclk_o` | JB1 | A14 | LVCMOS33 | output | Provisional SPI SCLK |
| `spi_mosi_o` | JB2 | A16 | LVCMOS33 | output | Provisional SPI MOSI |
| `spi_miso_i` | JB3 | B15 | LVCMOS33 | input | Provisional SPI MISO |
| `spi_ss_n_o` | JB4 | B16 | LVCMOS33 | output | Provisional active-low SPI SS |
| `i2c_scl_io` | JC1 | K17 | LVCMOS33 | inout | PULLUP true; external I2C pull-up required/recommended |
| `i2c_sda_io` | JC2 | M18 | LVCMOS33 | inout | PULLUP true; external I2C pull-up required/recommended |

Only the PMOD pins needed by Sensor, SPI, and I2C were constrained. Unused PMOD pins remain unconstrained.


