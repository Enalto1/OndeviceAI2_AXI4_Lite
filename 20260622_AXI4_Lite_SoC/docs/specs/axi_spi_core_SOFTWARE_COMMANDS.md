# axi_spi_core Software Command Plan

## Scope

This is a preliminary MicroBlaze UART command plan for `axi_spi_core`. Unattended Phase D does not create C code, BSP files, MicroBlaze software, or a Vivado block design.

The assumed console path remains:

```text
PC terminal -> AXI UART Lite -> MicroBlaze command parser -> AXI4-Lite register access
```

## Base Address

| Item | Value |
| --- | --- |
| Peripheral | `axi_spi_core` |
| Base address | `0x44A4_0000` |
| Register map source | `docs/specs/axi_spi_core_SPEC.md` |

## Register Summary For Software

| Offset | Register | Software use |
| --- | --- | --- |
| `0x00` | `CONTROL` | Enable and SPI mode bits. |
| `0x04` | `CLKDIV` | SPI bit-clock divider. |
| `0x08` | `TXDATA` | Byte to transmit. |
| `0x0C` | `COMMAND` | Write-one start pulse; reads return zero. |
| `0x10` | `RXDATA` | Last received byte. |
| `0x14` | `STATUS` | Busy, done, and control mirror state. |
| `0x1C` | `VERSION` | Fixed version readback. |

## Command Table

| UART command | Purpose | Register access | Expected UART output |
| --- | --- | --- | --- |
| `spi enable` | Enable SPI transfers. | Read-modify-write `CONTROL[0]=1`. | `OK spi enable` |
| `spi disable` | Disable new SPI transfers. | Read-modify-write `CONTROL[0]=0`. | `OK spi disable` |
| `spi mode 0` | Select CPOL=0, CPHA=0. | Read-modify-write `CONTROL[2:1]=2'b00`. | `OK spi mode 0` |
| `spi mode 1` | Select CPOL=0, CPHA=1. | Read-modify-write `CONTROL[2:1]=2'b10`. | `OK spi mode 1` |
| `spi mode 2` | Select CPOL=1, CPHA=0. | Read-modify-write `CONTROL[2:1]=2'b01`. | `OK spi mode 2` |
| `spi mode 3` | Select CPOL=1, CPHA=1. | Read-modify-write `CONTROL[2:1]=2'b11`. | `OK spi mode 3` |
| `spi clkdiv <n>` | Set SPI clock divider. | Write `CLKDIV[15:0]=n`. | `OK spi clkdiv <n>` |
| `spi tx <byte>` | Load transmit byte without starting. | Write `TXDATA[7:0]`. | `OK spi tx 0xNN` |
| `spi start` | Start one transfer using current `TXDATA`. | Write `COMMAND[0]=1`. | `OK spi start` or `ERR spi busy/disabled` |
| `spi xfer <byte>` | Load TX byte and start one transfer. | Write `TXDATA`, then write `COMMAND[0]=1`. | `SPI rx=0xNN` after completion or timeout. |
| `spi read` | Read last received byte. | Read `RXDATA`. | `SPI rx=0xNN` |
| `spi status` | Read status. | Read `STATUS`. | `SPI status busy=<0|1> done=<0|1> enable=<0|1> mode=<0..3>` |
| `spi version` | Read fixed version. | Read `VERSION`. | `SPI version=0x00010000` |

## Command Behavior Notes

- Software should preserve unrelated `CONTROL` bits through read-modify-write operations.
- Software should not depend on `COMMAND` readback because `COMMAND` reads as zero.
- `spi xfer <byte>` should either poll `STATUS.busy` until it clears or use a timeout.
- A disabled or busy peripheral should produce a clear software error instead of silently discarding a user command.
- `CLKDIV=0` should be avoided by software until the RTL phase finalizes whether hardware clamps zero to one.
- The first software command set is master-only.