# Block Design Address Map Verification

Source of truth: `docs/specs/AXI_ADDRESS_MAP.md`.

Actual Vivado evidence: `vivado/basys3/microblaze_axi_soc/reports/bd_address_map_actual.tsv`.

| Peripheral/IP | Expected base | Actual Vivado base | Range | Expected high | Actual high | Result | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| AXI UART Lite | `0x4060_0000` | `0x4060_0000` | 64 KB | `0x4060_FFFF` | `0x4060_FFFF` | PASS | Xilinx console UART |
| `axi_gpio_core` | `0x44A0_0000` | `0x44A0_0000` | 64 KB | `0x44A0_FFFF` | `0x44A0_FFFF` | PASS | Local packaged IP |
| `axi_fnd_core` | `0x44A1_0000` | `0x44A1_0000` | 64 KB | `0x44A1_FFFF` | `0x44A1_FFFF` | PASS | Local packaged IP |
| `axi_timer_core` | `0x44A2_0000` | `0x44A2_0000` | 64 KB | `0x44A2_FFFF` | `0x44A2_FFFF` | PASS | Local packaged IP |
| `axi_sensor_core` | `0x44A3_0000` | `0x44A3_0000` | 64 KB | `0x44A3_FFFF` | `0x44A3_FFFF` | PASS | Local packaged IP |
| `axi_spi_core` | `0x44A4_0000` | `0x44A4_0000` | 64 KB | `0x44A4_FFFF` | `0x44A4_FFFF` | PASS | Local packaged IP |
| `axi_i2c_core` | `0x44A5_0000` | `0x44A5_0000` | 64 KB | `0x44A5_FFFF` | `0x44A5_FFFF` | PASS | Local packaged IP |

No address overlaps were detected by the Prompt 21 script. MicroBlaze local BRAM is mapped separately at `0x0000_0000` with a 128 KB range in instruction and data address spaces.

