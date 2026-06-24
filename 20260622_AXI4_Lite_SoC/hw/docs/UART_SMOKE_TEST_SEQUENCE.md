# UART Smoke Test Sequence

## Status

This is an offline manual test sequence. It was not run during Prompt 25A because the Basys3 board is not connected.

## Terminal Settings

```text
9600 baud, 8 data bits, no parity, 1 stop bit, flow control none
```

## Commands

```text
help
version
periph list

gpio version
fnd version
timer version
sensor version
spi version
i2c version

gpio led 00FF
gpio read
gpio led 0000
gpio read

fnd time 12 34 5 1
fnd mode timer
fnd sel low
fnd enable
fnd output

timer sw clear
timer sw run
timer sw read
timer sw stop
timer sw read

sensor status
sensor version

spi status
spi version

i2c status
i2c bus
i2c version
```

## Expected Basic Results

- All peripheral version commands should return `0x00010000`.
- `gpio led 00FF` should light lower LEDs.
- `fnd enable` should drive the seven-segment display.
- Timer read should return packed values.
- Sensor, SPI, and I2C external transactions require wiring and are not mandatory for the first smoke test.

## Evidence To Capture Later

- UART transcript.
- LED observations for GPIO commands.
- FND observations after enable/mode/time commands.
- Any warnings, timeouts, or unexpected responses.
