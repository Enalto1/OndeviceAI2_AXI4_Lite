# Software Register Map

## Base Addresses

These values match `vivado/basys3/microblaze_axi_soc/reports/bd_address_map_actual.tsv` and are used as software fallbacks if `xparameters.h` does not expose matching custom-IP macros.

| Peripheral | Base | Range |
| --- | --- | --- |
| AXI UART Lite | `0x40600000` | 64 KB |
| GPIO | `0x44A00000` | 64 KB |
| FND | `0x44A10000` | 64 KB |
| Timer | `0x44A20000` | 64 KB |
| Sensor | `0x44A30000` | 64 KB |
| SPI | `0x44A40000` | 64 KB |
| I2C | `0x44A50000` | 64 KB |

## Common

| Offset | Name | Notes |
| --- | --- | --- |
| `0x1C` | `VERSION` | Custom peripherals read `0x00010000`. |

## GPIO

| Offset | Register | Access | Software use |
| --- | --- | --- | --- |
| `0x00` | `GPIO_OUT` | RW | LED output bits `[15:0]`. |
| `0x04` | `GPIO_IN` | RO | switches `[15:0]`, debounced buttons `[20:16]`, raw buttons `[25:21]`. |
| `0x08` | `GPIO_SET` | WO | write-one LED set mask. |
| `0x0C` | `GPIO_CLR` | WO | write-one LED clear mask. |
| `0x10` | `GPIO_TOGGLE` | WO | write-one LED toggle mask. |
| `0x14` | `BTN_EDGE` | RO | debounced rising-edge flags `[4:0]`. |
| `0x18` | `BTN_EDGE_CLR` | WO | write-one clear mask `[4:0]`. |

## FND

| Offset | Register | Access | Software use |
| --- | --- | --- | --- |
| `0x00` | `CONTROL` | RW | enable `[0]`, mode `[2:1]`, select `[3]`. |
| `0x04` | `TIMER_VALUE` | RW | msec `[6:0]`, sec `[12:7]`, min `[18:13]`, hour `[23:19]`. |
| `0x08` | `SENSOR_VALUE` | RW | distance `[8:0]`, humidity `[16:9]`, temperature `[24:17]`. |
| `0x0C` | `FND_OUTPUT` | RO | current common `[3:0]` and segment data `[15:8]`. |

## Timer

| Offset | Register | Access | Software use |
| --- | --- | --- | --- |
| `0x00` | `CONTROL` | RW | stopwatch run/down and watch edit target. |
| `0x04` | `COMMAND` | WO | stopwatch clear `[0]`, watch edit up `[8]`, watch edit down `[9]`. |
| `0x08` | `STOPWATCH_VALUE` | RO | packed msec/sec/min/hour. |
| `0x0C` | `WATCH_VALUE` | RO | packed watch msec/sec/min/hour. |
| `0x10` | `WATCH_RAW_DIGITS` | RO | raw split watch digits. |
| `0x14` | `STATUS` | RO | mirrors meaningful control state. |

## Sensor

| Offset | Register | Access | Software use |
| --- | --- | --- | --- |
| `0x00` | `CONTROL` | RW | SR04 enable `[0]`, DHT enable `[8]`. |
| `0x04` | `COMMAND` | WO | SR04 start `[0]`, DHT start `[8]`. |
| `0x08` | `SR04_VALUE` | RO | distance `[8:0]`. |
| `0x0C` | `DHT_VALUE` | RO | humidity `[7:0]`, temperature `[15:8]`. |
| `0x10` | `STATUS` | RO | SR04 trig `[0]`, DHT valid `[8]`, enable mirrors `[16]` and `[24]`. |

## SPI

| Offset | Register | Access | Software use |
| --- | --- | --- | --- |
| `0x00` | `CONTROL` | RW | enable `[0]`, CPOL `[1]`, CPHA `[2]`. |
| `0x04` | `CLKDIV` | RW | divider `[15:0]`. |
| `0x08` | `TXDATA` | RW | transmit byte `[7:0]`. |
| `0x0C` | `COMMAND` | WO | start `[0]`. |
| `0x10` | `RXDATA` | RO | received byte `[7:0]`. |
| `0x14` | `STATUS` | RO | busy `[0]`, done sticky `[1]`, control mirrors `[10:8]`. |

## I2C

| Offset | Register | Access | Software use |
| --- | --- | --- | --- |
| `0x00` | `CONTROL` | RW | enable `[0]`, read ACK policy `[1]`. |
| `0x04` | `TXDATA` | RW | transmit byte `[7:0]`. |
| `0x08` | `COMMAND` | WO | start `[0]`, stop `[1]`, write `[2]`, read `[3]`. |
| `0x0C` | `RXDATA` | RO | received byte `[7:0]`. |
| `0x10` | `STATUS` | RO | busy, ready, done, NACK, control mirrors. |
| `0x14` | `BUS_STATUS` | RO | SCL/SDA sampled state and drive-low state. |
