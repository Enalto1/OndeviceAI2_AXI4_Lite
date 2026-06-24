# AXI Address Assignment Final Check

## Final Planned Address Map

| Base address | High address | Range | Peripheral/IP | Type |
| --- | --- | --- | --- | --- |
| `0x4060_0000` | `0x4060_FFFF` | 64 KB | AXI UART Lite | Xilinx IP |
| `0x44A0_0000` | `0x44A0_FFFF` | 64 KB | `axi_gpio_core` | Custom AXI4-Lite slave |
| `0x44A1_0000` | `0x44A1_FFFF` | 64 KB | `axi_fnd_core` | Custom AXI4-Lite slave |
| `0x44A2_0000` | `0x44A2_FFFF` | 64 KB | `axi_timer_core` | Custom AXI4-Lite slave |
| `0x44A3_0000` | `0x44A3_FFFF` | 64 KB | `axi_sensor_core` | Custom AXI4-Lite slave |
| `0x44A4_0000` | `0x44A4_FFFF` | 64 KB | `axi_spi_core` | Custom AXI4-Lite slave |
| `0x44A5_0000` | `0x44A5_FFFF` | 64 KB | `axi_i2c_core` | Custom AXI4-Lite slave |

## Required Vivado Address Editor Checks

- Confirm AXI UART Lite is assigned to `0x4060_0000`.
- Confirm all six custom peripherals use 64 KB ranges.
- Confirm no overlapping assigned ranges.
- Confirm generated `xparameters.h` base/high addresses match this table after software export.
- If Vivado proposes a different base address, update Vivado to match `docs/specs/AXI_ADDRESS_MAP.md` rather than silently drifting the documentation.

## Source Of Truth

The source-of-truth address map remains `docs/specs/AXI_ADDRESS_MAP.md`. This file is a final-check companion for the future block design and BSP export.

## Prompt 21 Actual Vivado Address Verification

Prompt 21 created the block design and assigned the exact planned address map.

| Peripheral/IP | Expected base | Actual base | Range | Result |
| --- | --- | --- | --- | --- |
| AXI UART Lite | `0x4060_0000` | `0x4060_0000` | 64 KB | PASS |
| `axi_gpio_core` | `0x44A0_0000` | `0x44A0_0000` | 64 KB | PASS |
| `axi_fnd_core` | `0x44A1_0000` | `0x44A1_0000` | 64 KB | PASS |
| `axi_timer_core` | `0x44A2_0000` | `0x44A2_0000` | 64 KB | PASS |
| `axi_sensor_core` | `0x44A3_0000` | `0x44A3_0000` | 64 KB | PASS |
| `axi_spi_core` | `0x44A4_0000` | `0x44A4_0000` | 64 KB | PASS |
| `axi_i2c_core` | `0x44A5_0000` | `0x44A5_0000` | 64 KB | PASS |

Evidence: `vivado/basys3/microblaze_axi_soc/reports/bd_address_map_actual.tsv`.

