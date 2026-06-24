# axi_i2c_core Software Command Plan

## Scope

This is a preliminary MicroBlaze UART command plan for `axi_i2c_core`. Prompt 16 does not create C code, BSP files, MicroBlaze software, or a Vivado block design.

The assumed console path remains:

```text
PC terminal -> AXI UART Lite -> MicroBlaze command parser -> AXI4-Lite register access
```

## Base Address

| Item | Value |
| --- | --- |
| Peripheral | `axi_i2c_core` |
| Base address | `0x44A5_0000` |
| Register map source | `docs/specs/axi_i2c_core_SPEC.md` |

## Register Summary For Software

| Offset | Register | Software use |
| --- | --- | --- |
| `0x00` | `CONTROL` | Enable low-level commands and select read ACK/NACK behavior. |
| `0x04` | `TXDATA` | Byte used by the next `WRITE_BYTE` command. |
| `0x08` | `COMMAND` | Write-one command bits; reads return zero. |
| `0x0C` | `RXDATA` | Last received byte. |
| `0x10` | `STATUS` | Busy, ready, done, NACK, and control mirrors. |
| `0x14` | `BUS_STATUS` | SCL/SDA sampled and drive-low status. |
| `0x1C` | `VERSION` | Fixed version readback. |

## Command Table

| UART command | Purpose | Register access | Expected UART output |
| --- | --- | --- | --- |
| `i2c enable` | Enable low-level I2C commands. | Read-modify-write `CONTROL[0]=1`. | `OK i2c enable` |
| `i2c disable` | Disable new I2C commands. | Read-modify-write `CONTROL[0]=0`. | `OK i2c disable` |
| `i2c ack` | Select ACK after the next `READ_BYTE`. | Read-modify-write `CONTROL[1]=1`. | `OK i2c ack` |
| `i2c nack` | Select NACK after the next `READ_BYTE`. | Read-modify-write `CONTROL[1]=0`. | `OK i2c nack` |
| `i2c tx <byte>` | Load transmit byte without starting a command. | Write `TXDATA[7:0]=byte`. | `OK i2c tx 0xNN` |
| `i2c start` | Issue a START condition. | Write `COMMAND[0]=1`, wait for done or timeout. | `OK i2c start` or `ERR i2c busy/disabled/timeout` |
| `i2c stop` | Issue a STOP condition. | Write `COMMAND[1]=1`, wait for done or timeout. | `OK i2c stop` or `ERR i2c busy/disabled/timeout` |
| `i2c write <byte>` | Transmit one byte. | Write `TXDATA`, write `COMMAND[2]=1`, wait for done or timeout, read `STATUS`. | `OK i2c write 0xNN ack=<0|1>` |
| `i2c read ack` | Read one byte and ACK it. | Set `CONTROL[1]=1`, write `COMMAND[3]=1`, wait for done, read `RXDATA` and `STATUS`. | `I2C rx=0xNN nack=<0|1>` |
| `i2c read nack` | Read one byte and NACK it. | Set `CONTROL[1]=0`, write `COMMAND[3]=1`, wait for done, read `RXDATA` and `STATUS`. | `I2C rx=0xNN nack=<0|1>` |
| `i2c rx` | Read the last received byte. | Read `RXDATA`. | `I2C rx=0xNN` |
| `i2c status` | Read core status. | Read `STATUS`. | `I2C status busy=<0|1> ready=<0|1> done=<0|1> nack=<0|1> enable=<0|1> read_ack=<0|1>` |
| `i2c bus` | Read physical/open-drain bus status. | Read `BUS_STATUS`. | `I2C bus scl=<0|1> sda=<0|1> scl_drive_low=<0|1> sda_drive_low=<0|1>` |
| `i2c version` | Read fixed version. | Read `VERSION`. | `I2C version=0x00010000` |

## Command Behavior Notes

- Software should preserve unrelated `CONTROL` bits through read-modify-write operations.
- Software should not depend on `COMMAND` readback because `COMMAND` reads as zero.
- Software should poll `STATUS[1] cmd_ready` before issuing a command, then poll `STATUS[2] done_sticky` or use a timeout after an accepted command.
- A disabled or busy peripheral should produce a clear software error instead of silently discarding a user command.
- `i2c write <byte>` should report `ack=1` when no NACK was observed and `ack=0` when `nack_sticky` or `nack_live` indicates NACK.
- `i2c read ack` is for intermediate bytes in a multi-byte read.
- `i2c read nack` is for the final byte of a read transaction.
- The first software command set is master-only and low-level; it does not include hard-coded device addresses or sensor register sequences.

## Example Low-Level Sequences

Write one byte to a device:

```text
i2c enable
i2c start
i2c write A0
i2c write 55
i2c stop
```

Read one byte from a device with final NACK:

```text
i2c enable
i2c start
i2c write A1
i2c read nack
i2c stop
```

Repeated-start register read:

```text
i2c enable
i2c start
i2c write A0
i2c write 00
i2c start
i2c write A1
i2c read nack
i2c stop
```
