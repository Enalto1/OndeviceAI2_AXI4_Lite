# Basys3 External IO Planning

## Scope

Prompt 22 v1 assigned exact Basys3 package pins for the Prompt 21 MicroBlaze AXI4-Lite SoC top-level wrapper.

Source XDC:

- `constraints/basys3/basys3_axi_soc.xdc`

Detailed pin and reset docs:

- `docs/integration/BASYS3_XDC_PIN_MAP.md`
- `docs/integration/BASYS3_RESET_POLICY.md`
- `docs/integration/BASYS3_RESET_REVISION_GUIDE.md`

## Connection Categories

| Function | Top-level signal(s) | Basys3 resource | Status |
| --- | --- | --- | --- |
| Clock | `clk_100mhz_i` | 100 MHz oscillator W5 | Constrained |
| Reset | `reset_i` | PMOD JA4/G2 | Current active-low fallback, PULLUP true, revisable; CPU_RESETN/C12 rejected for `xc7a35tcpg236-1` |
| UART | `uart_rxd_i`, `uart_txd_o` | USB-UART B18/A18 | Constrained |
| LEDs | `led_o[15:0]` | Basys3 user LEDs | Constrained |
| Switches | `sw_i[15:0]` | Basys3 slide switches | Constrained |
| Buttons | `btn_i[4:0]` | Basys3 push buttons | Constrained and preserved for GPIO |
| FND | `fnd_com_o[3:0]`, `fnd_data_o[7:0]` | Basys3 seven-segment display | Constrained |
| SR04 | `sr04_trig_o`, `sr04_echo_i` | PMOD JA1/JA2 | Provisionally constrained |
| DHT11 | `dht11_io` | PMOD JA3 | Provisionally constrained, inout with pull-up |
| SPI | `spi_sclk_o`, `spi_mosi_o`, `spi_miso_i`, `spi_ss_n_o` | PMOD JB1..JB4 | Provisionally constrained |
| I2C | `i2c_scl_io`, `i2c_sda_io` | PMOD JC1/JC2 | Provisionally constrained, inout with pull-ups |

## Reset Revision Planning

The default reset uses CPU_RESETN C12 and keeps all five normal buttons available for GPIO. Reset can later move to an external PMOD button by replacing only the reset section of `constraints/basys3/basys3_axi_soc.xdc` with a reviewed assignment based on `constraints/basys3/reset_options/reset_external_pmod_template.xdc`.

Do not apply multiple reset snippets at the same time.

## Pull-Up And Inout Notes

- `dht11_io`, `i2c_scl_io`, and `i2c_sda_io` are top-level inout ports.
- XDC weak pull-ups are enabled for those inout ports.
- External pull-ups remain recommended for DHT11 and required/recommended for I2C hardware reliability.
- PMOD sensor/SPI/I2C mappings are provisional and should be reviewed against the actual modules before bitstream generation.

## Verified Master XDC Comparison

No verified Basys3 master XDC file was found in the canonical project root. The Prompt 22 v1 XDC was therefore created directly from the requested pin map and checked against the actual generated wrapper ports.

