# MicroBlaze UART Command Reference

## Console

The Prompt 24 software skeleton exposes a simple blocking UART console over AXI UART Lite. The BSP must route stdin/stdout to `axi_uartlite_0`.

Prompt:

```text
>
```

Line endings: CR, LF, or CRLF are accepted. Backspace is handled locally.

## Global Commands

| Command | Purpose |
| --- | --- |
| `help` | Print the top-level command list. |
| `version` | Print the software skeleton version. |
| `status` | Read version registers from all six custom peripherals. |
| `periph list` | Print UART/custom peripheral base addresses. |
| `reg read <addr>` | Read an absolute 32-bit address. |
| `reg write <addr> <value>` | Write an absolute 32-bit address. |
| `reg read <periph> <offset>` | Read a peripheral-relative register. |
| `reg write <periph> <offset> <value>` | Write a peripheral-relative register. |

Valid peripheral names for relative register access:

```text
uart gpio fnd timer sensor spi i2c
```

## GPIO Commands

| Command | Purpose |
| --- | --- |
| `gpio out [value]` | Read or write LED output register. |
| `gpio set <mask>` | Set selected LED bits. |
| `gpio clr <mask>` | Clear selected LED bits. |
| `gpio toggle <mask>` | Toggle selected LED bits. |
| `gpio in` | Read switches, debounced buttons, and raw synchronized buttons. |
| `gpio edge` | Read latched debounced button edge flags. |
| `gpio edgeclr <mask>` | Clear selected edge flags. |
| `gpio status` | Print GPIO output/input/edge/version registers. |

## FND Commands

| Command | Purpose |
| --- | --- |
| `fnd on` | Enable FND output. |
| `fnd off` | Blank FND output. |
| `fnd control <value>` | Write low control bits directly. |
| `fnd mode <0..3> [sel]` | Select display mode and optional display select bit. |
| `fnd timer <msec> <sec> <min> <hour>` | Pack and write timer display fields. |
| `fnd sensor <distance> <humidity> <temperature>` | Pack and write sensor display fields. |
| `fnd output` | Read current FND output monitor. |
| `fnd status` | Print FND control/value/output/version registers. |

FND modes: `0` stopwatch, `1` watch, `2` SR04 distance, `3` DHT11.

## Timer Commands

| Command | Purpose |
| --- | --- |
| `timer run` | Start stopwatch counting. |
| `timer stop` | Stop stopwatch counting. |
| `timer down <0|1>` | Select stopwatch count direction. |
| `timer clear` | Pulse stopwatch clear. |
| `timer sw` | Read packed stopwatch value. |
| `timer watch` | Read packed watch value. |
| `timer raw` | Read raw watch digit fields. |
| `timer editmode <0|1>` | Enter or leave watch edit mode. |
| `timer target hour|min|sec [tens|ones]` | Select watch edit target. |
| `timer up` | Pulse watch edit-up. |
| `timer downedit` | Pulse watch edit-down. |
| `timer status` | Print timer control/status/version registers. |

## Sensor Commands

| Command | Purpose |
| --- | --- |
| `sensor enable sr04|dht|all <0|1>` | Enable or disable sensor start commands. |
| `sensor sr04 start` | Pulse SR04 start command. |
| `sensor sr04 read` | Read SR04 distance field. |
| `sensor dht start` | Pulse DHT11 start command. |
| `sensor dht read` | Read DHT humidity/temperature bytes. |
| `sensor status` | Print sensor control/status/value/version registers. |

The software does not claim real sensor success by command issue alone. Use status/value changes during board bring-up.

## SPI Commands

| Command | Purpose |
| --- | --- |
| `spi enable <0|1>` | Enable or disable SPI transfer acceptance. |
| `spi mode <0..3>` | Set CPOL/CPHA mode. |
| `spi clkdiv <value>` | Set 16-bit SPI clock divider. |
| `spi tx <byte>` | Write transmit byte only. |
| `spi xfer <byte>` | Write transmit byte, pulse start, poll completion, print RX byte. |
| `spi rx` | Read last received byte. |
| `spi status` | Print SPI control/clkdiv/status/version registers. |

## I2C Commands

| Command | Purpose |
| --- | --- |
| `i2c enable <0|1>` | Enable or disable I2C command acceptance. |
| `i2c readack <0|1>` | Configure ACK/NACK after read-byte. |
| `i2c start` | Issue START command and poll completion. |
| `i2c stop` | Issue STOP command and poll completion. |
| `i2c write <byte>` | Write byte and poll completion/NACK. |
| `i2c read [ack|nack]` | Read byte and print RX data. |
| `i2c rx` | Read last received byte. |
| `i2c status` | Print I2C control/status/version registers. |
| `i2c bus` | Read SCL/SDA input and drive-low state. |

The first I2C software layer is low-level. It does not hard-code any external device protocol.
