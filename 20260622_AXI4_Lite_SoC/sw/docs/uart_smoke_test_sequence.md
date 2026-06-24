# UART Smoke Test Sequence

This sequence is for the future board test after the Vitis/XSCT build produces an ELF. Prompt 24 did not run this on hardware.

## Startup

Expected banner:

```text
MicroBlaze AXI4-Lite SoC UART console
Software: prompt24-0.1
Reset input: external active-low PMOD JA4/G2 with pullup
Type 'help' for commands.
>
```

## Basic Console

```text
help
version
periph list
status
```

Expected direction:

- `help` prints command groups.
- `version` prints `prompt24-0.1`.
- `periph list` prints base addresses.
- `status` reads custom peripheral version registers.

## GPIO LED And Input Check

```text
gpio out 0x0000
gpio out 0x0001
gpio set 0x0002
gpio clr 0x0001
gpio toggle 0x0003
gpio in
gpio edge
gpio edgeclr 0x1f
```

## FND Check

```text
fnd off
fnd on
fnd mode 0 0
fnd timer 0 12 34 5
fnd output
fnd mode 2 0
fnd sensor 123 45 26
fnd output
```

## Timer Check

```text
timer clear
timer run
timer sw
timer stop
timer editmode 1
timer target min ones
timer up
timer watch
timer editmode 0
```

## Sensor/SPI/I2C Register-Level Checks

```text
sensor status
sensor enable all 1
sensor sr04 start
sensor sr04 read
sensor dht start
sensor dht read
spi status
spi enable 1
spi mode 0
spi clkdiv 100
i2c status
i2c enable 1
i2c bus
```

Do not interpret external sensor, SPI, or I2C command success as board success without connected devices and a captured UART transcript.
