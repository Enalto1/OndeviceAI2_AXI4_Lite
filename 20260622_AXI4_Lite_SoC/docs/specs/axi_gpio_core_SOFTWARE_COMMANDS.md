# `axi_gpio_core` Software Command Plan

This document defines the preliminary MicroBlaze UART command plan for GPIO. No C code is created in Prompt 1.

## Command Channel

| Item | Plan |
| --- | --- |
| Console IP | Xilinx AXI UART Lite |
| Command parser location | MicroBlaze software |
| GPIO base address | `0x44A0_0000` |
| Register access width | 32-bit AXI reads/writes |

## Register Constants

| Symbol | Address | Purpose |
| --- | --- | --- |
| `GPIO_OUT` | `0x44A0_0000` | LED output register. |
| `GPIO_IN` | `0x44A0_0004` | Switch/button input readback. |
| `GPIO_SET` | `0x44A0_0008` | Write-one-to-set LED bits. |
| `GPIO_CLR` | `0x44A0_000C` | Write-one-to-clear LED bits. |
| `GPIO_TOGGLE` | `0x44A0_0010` | Write-one-to-toggle LED bits. |
| `BTN_EDGE` | `0x44A0_0014` | Button rising-edge flags. |
| `BTN_EDGE_CLR` | `0x44A0_0018` | Write-one-to-clear edge flags. |
| `VERSION` | `0x44A0_001C` | Fixed IP version. |

## Commands

| Command | Purpose | AXI access | Expected UART output |
| --- | --- | --- | --- |
| `gpio led <hex16>` | Replace full LED output register. | Write `GPIO_OUT[15:0]` at `0x00`. | `OK led=0xHHHH` after optional readback. |
| `gpio set <hex16>` | Set selected LED bits. | Write mask to `GPIO_SET` at `0x08`. | `OK set=0xHHHH led=0xHHHH` after reading `GPIO_OUT`. |
| `gpio clr <hex16>` | Clear selected LED bits. | Write mask to `GPIO_CLR` at `0x0C`. | `OK clr=0xHHHH led=0xHHHH` after reading `GPIO_OUT`. |
| `gpio toggle <hex16>` | Toggle selected LED bits. | Write mask to `GPIO_TOGGLE` at `0x10`. | `OK toggle=0xHHHH led=0xHHHH` after reading `GPIO_OUT`. |
| `gpio read` | Read switches and buttons. | Read `GPIO_IN` at `0x04`. | `GPIO sw=0xHHHH btn_db=0xHH btn_raw=0xHH` |
| `gpio edge` | Read latched button edge flags. | Read `BTN_EDGE` at `0x14`. | `GPIO edge=0xHH` |
| `gpio edgeclr <hex5>` | Clear selected button edge flags. | Write mask to `BTN_EDGE_CLR` at `0x18`. | `OK edgeclr=0xHH edge=0xHH` after reading `BTN_EDGE`. |
| `gpio version` | Read fixed IP version. | Read `VERSION` at `0x1C`. | `GPIO version=0x00010000` |

## Argument Rules

- `<hex16>` accepts a 16-bit LED mask, with or without `0x` prefix.
- `<hex5>` accepts a 5-bit button mask, with or without `0x` prefix. Values above `0x1F` should be rejected or masked with a warning.
- Software should print normalized uppercase hex with fixed width.
- Software should avoid relying on readback from `GPIO_SET`, `GPIO_CLR`, `GPIO_TOGGLE`, or `BTN_EDGE_CLR`; these are write-only command registers.

## `gpio read` Decode

For `GPIO_IN`:

```text
sw       = GPIO_IN[15:0]
btn_db   = GPIO_IN[20:16]
btn_raw  = GPIO_IN[25:21]
reserved = GPIO_IN[31:26], expected 0
```

Suggested output:

```text
GPIO sw=0x1234 btn_db=0x05 btn_raw=0x04
```

## `gpio edge` Decode

For `BTN_EDGE`:

```text
edge = BTN_EDGE[4:0]
reserved = BTN_EDGE[31:5], expected 0
```

Suggested output:

```text
GPIO edge=0x03
```

## Error Handling Plan

| Error | Suggested output |
| --- | --- |
| Unknown subcommand | `ERR gpio: unknown command` |
| Missing argument | `ERR gpio: missing argument` |
| Invalid hex argument | `ERR gpio: invalid hex` |
| Out-of-range LED mask | `ERR gpio: led mask must be 16-bit` |
| Out-of-range edge mask | `ERR gpio: edge mask must be 5-bit` |

## Consistency Notes

- The command plan matches `docs/specs/axi_gpio_core_SPEC.md`.
- The command parser belongs in MicroBlaze software and should communicate through AXI UART Lite.
- No legacy `ASCII_decoder.v` or `ASCII_sender.v` logic is used for this initial software console plan.
