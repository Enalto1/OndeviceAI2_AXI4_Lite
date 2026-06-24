# axi_timer_core Software Command Plan

## Scope

This is a preliminary MicroBlaze UART command plan for `axi_timer_core`. Prompt 7 does not create C code, BSP files, MicroBlaze software, or a Vivado block design.

The assumed console path remains:

```text
PC terminal -> AXI UART Lite -> MicroBlaze command parser -> AXI4-Lite register access
```

## Base Address

| Item | Value |
| --- | --- |
| Peripheral | `axi_timer_core` |
| Base address | `0x44A2_0000` |
| Register map source | `docs/specs/axi_timer_core_SPEC.md` |

## Register Summary For Software

| Offset | Register | Software use |
| --- | --- | --- |
| `0x00` | `CONTROL` | Persistent stopwatch and watch control state. |
| `0x04` | `COMMAND` | Write-one pulses; reads return zero. |
| `0x08` | `STOPWATCH_VALUE` | Packed stopwatch readback. |
| `0x0C` | `WATCH_VALUE` | Packed watch readback from adapter. |
| `0x10` | `WATCH_RAW_DIGITS` | Raw split watch digit readback. |
| `0x14` | `STATUS` | Control-state readback. |
| `0x1C` | `VERSION` | Fixed version readback. |

## Command Table

| UART command | Purpose | Register access | Expected UART output |
| --- | --- | --- | --- |
| `timer sw run` | Start stopwatch ticking. | Read-modify-write `CONTROL[0]=1`. | `OK timer sw run` |
| `timer sw stop` | Stop stopwatch ticking. | Read-modify-write `CONTROL[0]=0`. | `OK timer sw stop` |
| `timer sw clear` | Clear stopwatch counters. | Write `COMMAND[0]=1`. | `OK timer sw clear` |
| `timer sw up` | Select stopwatch up-count mode. | Read-modify-write `CONTROL[1]=0`. | `OK timer sw up` |
| `timer sw down` | Select stopwatch down-count mode. | Read-modify-write `CONTROL[1]=1`. | `OK timer sw down` |
| `timer sw read` | Read stopwatch value. | Read `STOPWATCH_VALUE`. | `SW hour=<h> min=<m> sec=<s> msec=<ms>` |
| `timer wt run` | Put watch in run mode. | Read-modify-write `CONTROL[8]=0`. | `OK timer wt run` |
| `timer wt set` | Put watch in set/edit mode. | Read-modify-write `CONTROL[8]=1`. | `OK timer wt set` |
| `timer wt target hour` | Select watch hour edit target. | Read-modify-write `CONTROL[10:9]=2'b00`; `CONTROL[11]` ignored. | `OK timer wt target hour` |
| `timer wt target min ones` | Select minute ones digit. | Read-modify-write `CONTROL[10:9]=2'b01`, `CONTROL[11]=1`. | `OK timer wt target min ones` |
| `timer wt target min tens` | Select minute tens digit. | Read-modify-write `CONTROL[10:9]=2'b01`, `CONTROL[11]=0`. | `OK timer wt target min tens` |
| `timer wt target sec ones` | Select second ones digit. | Read-modify-write `CONTROL[10:9]=2'b10`, `CONTROL[11]=1`. | `OK timer wt target sec ones` |
| `timer wt target sec tens` | Select second tens digit. | Read-modify-write `CONTROL[10:9]=2'b10`, `CONTROL[11]=0`. | `OK timer wt target sec tens` |
| `timer wt up` | Increment selected watch target. | Write `COMMAND[8]=1`; effective only when `CONTROL[8]=1`. | `OK timer wt up` |
| `timer wt down` | Decrement selected watch target. | Write `COMMAND[9]=1`; effective only when `CONTROL[8]=1`. | `OK timer wt down` |
| `timer wt read` | Read packed watch value. | Read `WATCH_VALUE`. | `WT hour=<h> min=<m> sec=<s> msec=<ms>` |
| `timer status` | Read timer control state. | Read `STATUS`. | `TIMER status sw_run=<0|1> sw_down=<0|1> wt_set=<0|1> wt_target=<hour|min_tens|min_ones|sec_tens|sec_ones|reserved>` |
| `timer version` | Read fixed version. | Read `VERSION`. | `TIMER version=0x00010000` |

## Field Decode For Read Commands

`STOPWATCH_VALUE` and `WATCH_VALUE` use the same packed format:

| Bits | Field |
| --- | --- |
| `[6:0]` | `msec` |
| `[12:7]` | `sec` |
| `[18:13]` | `min` |
| `[23:19]` | `hour` |

`WATCH_RAW_DIGITS` may be used for debug commands later, but it is not required for the first UART command set.

## Command Behavior Notes

- Software should preserve unrelated `CONTROL` bits through read-modify-write operations.
- Software should not depend on `COMMAND` readback because `COMMAND` reads as zero.
- `timer wt up` and `timer wt down` should either require watch set mode first or print a warning if `CONTROL[8]=0`.
- If both watch edit bits are ever written together, hardware gives edit-up priority. Software should avoid writing both in normal operation.
- Timer-to-FND display updates are a later software integration task: read `STOPWATCH_VALUE` or `WATCH_VALUE`, then write packed fields to `axi_fnd_core.TIMER_VALUE`.