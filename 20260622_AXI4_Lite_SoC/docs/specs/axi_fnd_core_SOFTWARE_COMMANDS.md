# axi_fnd_core Software Command Plan

## Scope

This is a preliminary MicroBlaze UART command plan for `axi_fnd_core`. It does not include C code. The future software will use AXI UART Lite for the PC console and memory-mapped AXI reads/writes to `axi_fnd_core`.

Base address:

```text
AXI_FND_BASE = 0x44A1_0000
```

## Register Constants

| Name | Offset | Access |
| --- | --- | --- |
| `FND_CONTROL` | `0x00` | RW |
| `FND_TIMER_VALUE` | `0x04` | RW |
| `FND_SENSOR_VALUE` | `0x08` | RW |
| `FND_OUTPUT` | `0x0C` | RO |
| `FND_VERSION` | `0x1C` | RO |

## Command Summary

| Command | Register access | Purpose | Expected UART response |
| --- | --- | --- | --- |
| `fnd enable` | Read-modify-write `CONTROL[0]=1` | Enable FND output gating. | `OK fnd enable` |
| `fnd disable` | Read-modify-write `CONTROL[0]=0` | Blank FND outputs. | `OK fnd disable` |
| `fnd mode timer` | Read-modify-write `CONTROL[2:1]=00` | Select stopwatch/timer display path. | `OK fnd mode timer` |
| `fnd mode watch` | Read-modify-write `CONTROL[2:1]=01` | Select watch/timer display path. | `OK fnd mode watch` |
| `fnd mode distance` | Read-modify-write `CONTROL[2:1]=10` | Select ultrasonic distance display path. | `OK fnd mode distance` |
| `fnd mode dht` | Read-modify-write `CONTROL[2:1]=11` | Select DHT display path. | `OK fnd mode dht` |
| `fnd sel low` | Read-modify-write `CONTROL[3]=0` | Select msec/sec in timer mode or humidity in DHT mode. | `OK fnd sel low` |
| `fnd sel high` | Read-modify-write `CONTROL[3]=1` | Select min/hour in timer mode or temperature in DHT mode. | `OK fnd sel high` |
| `fnd time <msec> <sec> <min> <hour>` | Write `TIMER_VALUE` | Update timer display fields. | `OK time msec=<msec> sec=<sec> min=<min> hour=<hour>` |
| `fnd distance <value>` | Read-modify-write `SENSOR_VALUE[8:0]` | Update distance field while preserving DHT fields. | `OK distance value=<value>` |
| `fnd dht <humidity> <temperature>` | Read-modify-write `SENSOR_VALUE[24:9]` | Update humidity and temperature fields while preserving distance. | `OK dht humidity=<humidity> temperature=<temperature>` |
| `fnd output` | Read `FND_OUTPUT` | Print final gated FND output monitor values. | `FND output com=0x<C> data=0x<DD>` |
| `fnd version` | Read `FND_VERSION` | Print peripheral version. | `FND version=0x00010000` |

## Packing Rules

`CONTROL`:

```text
display_enable = bit 0
main_mode      = bits 2:1
display_sel    = bit 3
```

`TIMER_VALUE`:

```text
value = ((hour & 0x1F) << 19)
      | ((min  & 0x3F) << 13)
      | ((sec  & 0x3F) << 7)
      |  (msec & 0x7F)
```

`SENSOR_VALUE`:

```text
value = ((temperature & 0xFF) << 17)
      | ((humidity    & 0xFF) << 9)
      |  (distance    & 0x1FF)
```

## Recommended Software Validation

The first software command parser should reject or warn on values outside the recommended ranges, even though the RTL is not expected to enforce ranges:

| Field | Recommended range |
| --- | --- |
| `msec` | 0 to 99 |
| `sec` | 0 to 59 |
| `min` | 0 to 59 |
| `hour` | 0 to 23 |
| `distance` | 0 to 511 by register width |
| `humidity` | 0 to 99 |
| `temperature` | 0 to 99 |

## Example Commands

```text
fnd disable
-> OK fnd disable

fnd time 12 34 5 1
-> OK time msec=12 sec=34 min=5 hour=1

fnd mode timer
-> OK fnd mode timer

fnd sel low
-> OK fnd sel low

fnd enable
-> OK fnd enable

fnd output
-> FND output com=0xE data=0xA4

fnd version
-> FND version=0x00010000
```

The `fnd output` values are dynamic because the reused controller scans one digit at a time.