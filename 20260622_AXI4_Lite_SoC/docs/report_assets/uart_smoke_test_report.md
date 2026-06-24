# UART Smoke Test Report

## Status

Not run - board unavailable / COM port unavailable.

## Date/Time

2026-06-23 13:09:42 +09:00

## Terminal Settings For Future Test

| Setting | Value |
| --- | --- |
| Baud | 9600 |
| Data bits | 8 |
| Parity | none |
| Stop bits | 1 |
| Flow control | none |

## COM Port

No COM port was selected or tested because the Basys3 board is not connected during Prompt 25A.

## Command Sequence Prepared

Command file:

```text
hw/scripts/uart_smoke_test_sequence.txt
```

The sequence covers:

- Console help/version/peripheral list.
- Peripheral version checks.
- GPIO LED/read checks.
- FND time/mode/select/enable/output checks.
- Timer clear/run/read/stop/read checks.
- Sensor/SPI/I2C status/version and I2C bus checks.

## Observed Responses

None. UART was not opened and no commands were sent.

## Board Observations

None. LED/FND behavior was not observed.

## External Device Limitations

Sensor, SPI, and I2C external transactions require wiring and are not mandatory for the first smoke test. No external device success is claimed.

## Result

Manual pending. Do not mark board demo complete until UART responses are observed and recorded.
