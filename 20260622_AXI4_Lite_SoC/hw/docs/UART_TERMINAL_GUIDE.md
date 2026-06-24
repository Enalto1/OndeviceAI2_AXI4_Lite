# UART Terminal Guide

## COM Port Discovery

The COM port is not assumed in the offline package. When the board is connected later:

1. Open Windows Device Manager.
2. Expand Ports (COM & LPT).
3. Locate the Digilent/Basys3 USB Serial Converter COM port.
4. Use that COM port in the terminal program.

## Terminal Settings

| Setting | Value |
| --- | --- |
| Baud | 9600 |
| Data bits | 8 |
| Parity | none |
| Stop bits | 1 |
| Flow control | none |

## Recommended Terminal Tools

- Tera Term
- PuTTY
- RealTerm
- VS Code Serial Monitor

## Smoke Test Commands

Use commands from:

```text
hw/scripts/uart_smoke_test_sequence.txt
```

Expected basic result:

- Version commands should return valid software/peripheral version data.
- Peripheral `VERSION` registers should return `0x00010000`.
- `gpio led 00FF` should light the lower LEDs if board programming and firmware command handling are correct.
- `fnd enable` should drive the seven-segment display if display wiring and constraints are correct.
- Timer read commands should return packed timer values.
- Sensor, SPI, and I2C external transactions require wiring and are not mandatory for the first smoke test.

Do not claim UART smoke success unless responses are actually observed and captured.
