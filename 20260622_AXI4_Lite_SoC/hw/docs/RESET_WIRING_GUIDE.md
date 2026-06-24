# Reset Wiring Guide

## Reset Signal

| Item | Value |
| --- | --- |
| FPGA top-level port | `reset_i` |
| Board mapping | PMOD JA4 / G2 |
| Polarity | active-low |
| Released state | logic 1 through pull-up |
| Active reset state | logic 0 |

## Recommended External Button Wiring

```text
PMOD JA4 signal ---- push button ---- GND
```

- Button released: reset is released.
- Button pressed: reset is active.
- Do not hold the button during normal UART smoke testing.

## Notes

- The onboard Basys3 buttons are still GPIO inputs `btn_i[4:0]`.
- The reset is not Basys3 CPU_RESETN/C12 in the current Prompt 23 bitstream.
- If no external reset button is attached, the XDC pull-up should keep reset released.
- If the system appears stuck, power-cycle the board before assuming a design issue.
