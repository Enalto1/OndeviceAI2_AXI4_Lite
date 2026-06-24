# AXI Address Map

Prompt 1 defines the planned global AXI address map for the Basys3-first MicroBlaze system. The addresses below should be entered and later confirmed in Vivado 2020.2 Address Editor.

## Address Map Summary

| Base address | High address | Range | IP/peripheral | Type | Purpose |
| --- | --- | --- | --- | --- | --- |
| `0x4060_0000` | `0x4060_FFFF` | 64 KB | AXI UART Lite | Xilinx IP | PC console/debug UART |
| `0x44A0_0000` | `0x44A0_FFFF` | 64 KB | `axi_gpio_core` | Custom AXI4-Lite slave | LED, switch, button GPIO |
| `0x44A1_0000` | `0x44A1_FFFF` | 64 KB | `axi_fnd_core` | Custom AXI4-Lite slave | FND display |
| `0x44A2_0000` | `0x44A2_FFFF` | 64 KB | `axi_timer_core` | Custom AXI4-Lite slave | Stopwatch/watch |
| `0x44A3_0000` | `0x44A3_FFFF` | 64 KB | `axi_sensor_core` | Custom AXI4-Lite slave | DHT11/SR04 |
| `0x44A4_0000` | `0x44A4_FFFF` | 64 KB | `axi_spi_core` | Custom AXI4-Lite slave | SPI master |
| `0x44A5_0000` | `0x44A5_FFFF` | 64 KB | `axi_i2c_core` | Custom AXI4-Lite slave | I2C master |

## Address Map Policy

- AXI UART Lite is a Xilinx IP block and is not a custom RTL peripheral.
- Custom AXI peripherals start at `0x44A0_0000`.
- Each custom peripheral is assigned a 64 KB address range for Vivado block design integration.
- Inside each custom wrapper, the local AXI address width is planned as 6 bits, covering offsets `0x00` through `0x3F`.
- Prompt 1 fully specified the `axi_gpio_core` register map. Prompt 4 fully specifies the `axi_fnd_core` register map.
- The address map is the project planning baseline and must be confirmed later in Vivado 2020.2 Address Editor.

## `axi_gpio_core` Local Register Window

| Local offset | Absolute address | Register |
| --- | --- | --- |
| `0x00` | `0x44A0_0000` | `GPIO_OUT` |
| `0x04` | `0x44A0_0004` | `GPIO_IN` |
| `0x08` | `0x44A0_0008` | `GPIO_SET` |
| `0x0C` | `0x44A0_000C` | `GPIO_CLR` |
| `0x10` | `0x44A0_0010` | `GPIO_TOGGLE` |
| `0x14` | `0x44A0_0014` | `BTN_EDGE` |
| `0x18` | `0x44A0_0018` | `BTN_EDGE_CLR` |
| `0x1C` | `0x44A0_001C` | `VERSION` |
| `0x20` to `0x3C` | `0x44A0_0020` to `0x44A0_003C` | Reserved |


## `axi_fnd_core` Local Register Window

| Local offset | Absolute address | Register |
| --- | --- | --- |
| `0x00` | `0x44A1_0000` | `CONTROL` |
| `0x04` | `0x44A1_0004` | `TIMER_VALUE` |
| `0x08` | `0x44A1_0008` | `SENSOR_VALUE` |
| `0x0C` | `0x44A1_000C` | `FND_OUTPUT` |
| `0x10` | `0x44A1_0010` | Reserved |
| `0x14` | `0x44A1_0014` | Reserved |
| `0x18` | `0x44A1_0018` | Reserved |
| `0x1C` | `0x44A1_001C` | `VERSION` |
| `0x20` to `0x3C` | `0x44A1_0020` to `0x44A1_003C` | Reserved |
## Future Confirmation Checklist

- Confirm each base address in Vivado Address Editor.
- Confirm the AXI UART Lite base address matches the MicroBlaze BSP.
- Confirm MicroBlaze software constants match this document.
- Update `docs/TRACEABILITY_MATRIX.md` if Vivado assigns any different address.
