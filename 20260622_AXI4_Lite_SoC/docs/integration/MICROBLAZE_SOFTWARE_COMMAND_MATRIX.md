# MicroBlaze Software Command Matrix

## Scope

This matrix aggregates planned UART commands from the six peripheral software command plans. Prompt 19 does not write C code, create a BSP, or create a Vitis workspace.

| Command | Peripheral | Registers accessed | Expected UART response | Dependency or warning |
| --- | --- | --- | --- | --- |
| `gpio led <hex16>` | GPIO | `GPIO_OUT` | `OK led=0xHHHH` | Validate 16-bit mask. |
| `gpio set <hex16>` | GPIO | `GPIO_SET`, `GPIO_OUT` | `OK set=0xHHHH led=0xHHHH` | Write-only command register; read back `GPIO_OUT`. |
| `gpio clr <hex16>` | GPIO | `GPIO_CLR`, `GPIO_OUT` | `OK clr=0xHHHH led=0xHHHH` | Write-only command register; read back `GPIO_OUT`. |
| `gpio toggle <hex16>` | GPIO | `GPIO_TOGGLE`, `GPIO_OUT` | `OK toggle=0xHHHH led=0xHHHH` | Write-only command register; read back `GPIO_OUT`. |
| `gpio read` | GPIO | `GPIO_IN` | `GPIO sw=0xHHHH btn_db=0xHH btn_raw=0xHH` | Decode synchronized/debounced button fields. |
| `gpio edge` | GPIO | `BTN_EDGE` | `GPIO edge=0xHH` | Latched until cleared. |
| `gpio edgeclr <hex5>` | GPIO | `BTN_EDGE_CLR`, `BTN_EDGE` | `OK edgeclr=0xHH edge=0xHH` | Validate 5-bit mask. |
| `gpio version` | GPIO | `VERSION` | `GPIO version=0x00010000` | Read-only. |
| `fnd enable` | FND | `CONTROL` | `OK fnd enable` | Preserve unrelated control bits. |
| `fnd disable` | FND | `CONTROL` | `OK fnd disable` | Blanks outputs through gate. |
| `fnd mode timer` | FND | `CONTROL` | `OK fnd mode timer` | Select timer/stopwatch display path. |
| `fnd mode watch` | FND | `CONTROL` | `OK fnd mode watch` | Select watch display path. |
| `fnd mode distance` | FND | `CONTROL` | `OK fnd mode distance` | Requires software to update `SENSOR_VALUE`. |
| `fnd mode dht` | FND | `CONTROL` | `OK fnd mode dht` | Requires software to update DHT fields. |
| `fnd sel low` | FND | `CONTROL` | `OK fnd sel low` | Select low display half. |
| `fnd sel high` | FND | `CONTROL` | `OK fnd sel high` | Select high display half. |
| `fnd time <msec> <sec> <min> <hour>` | FND | `TIMER_VALUE` | `OK time msec=<msec> sec=<sec> min=<min> hour=<hour>` | Validate field ranges in software. |
| `fnd distance <value>` | FND | `SENSOR_VALUE` | `OK distance value=<value>` | Preserve DHT fields. |
| `fnd dht <humidity> <temperature>` | FND | `SENSOR_VALUE` | `OK dht humidity=<humidity> temperature=<temperature>` | Preserve distance field. |
| `fnd output` | FND | `FND_OUTPUT` | `FND output com=0x<C> data=0x<DD>` | Values are dynamic due to scan mux. |
| `fnd version` | FND | `VERSION` | `FND version=0x00010000` | Read-only. |
| `timer sw run` | Timer | `CONTROL` | `OK timer sw run` | Preserve watch bits. |
| `timer sw stop` | Timer | `CONTROL` | `OK timer sw stop` | Preserve watch bits. |
| `timer sw clear` | Timer | `COMMAND` | `OK timer sw clear` | `COMMAND` reads zero. |
| `timer sw up` | Timer | `CONTROL` | `OK timer sw up` | Select up-count mode. |
| `timer sw down` | Timer | `CONTROL` | `OK timer sw down` | Select down-count mode. |
| `timer sw read` | Timer | `STOPWATCH_VALUE` | `SW hour=<h> min=<m> sec=<s> msec=<ms>` | Decode packed fields. |
| `timer wt run` | Timer | `CONTROL` | `OK timer wt run` | Leaves set/edit mode. |
| `timer wt set` | Timer | `CONTROL` | `OK timer wt set` | Enables edit commands. |
| `timer wt target hour` | Timer | `CONTROL` | `OK timer wt target hour` | Select hour edit target. |
| `timer wt target min ones` | Timer | `CONTROL` | `OK timer wt target min ones` | Select minute ones. |
| `timer wt target min tens` | Timer | `CONTROL` | `OK timer wt target min tens` | Select minute tens. |
| `timer wt target sec ones` | Timer | `CONTROL` | `OK timer wt target sec ones` | Select second ones. |
| `timer wt target sec tens` | Timer | `CONTROL` | `OK timer wt target sec tens` | Select second tens. |
| `timer wt up` | Timer | `COMMAND` | `OK timer wt up` | Warn or reject if not in watch set mode. |
| `timer wt down` | Timer | `COMMAND` | `OK timer wt down` | Warn or reject if not in watch set mode. |
| `timer wt read` | Timer | `WATCH_VALUE` | `WT hour=<h> min=<m> sec=<s> msec=<ms>` | Decode packed fields. |
| `timer status` | Timer | `STATUS` | `TIMER status sw_run=<0|1> sw_down=<0|1> wt_set=<0|1> wt_target=<...>` | Useful before edit commands. |
| `timer version` | Timer | `VERSION` | `TIMER version=0x00010000` | Read-only. |
| `sensor sr04 enable` | Sensor | `CONTROL` | `OK sensor sr04 enable` | Preserve DHT enable bit. |
| `sensor sr04 disable` | Sensor | `CONTROL` | `OK sensor sr04 disable` | Preserve DHT enable bit. |
| `sensor sr04 start` | Sensor | `COMMAND` | `OK sensor sr04 start` | Poll status or delay before read. |
| `sensor sr04 read` | Sensor | `SR04_VALUE` | `SR04 distance=<value>` | Timing depends on echo pulse. |
| `sensor dht enable` | Sensor | `CONTROL` | `OK sensor dht enable` | Preserve SR04 enable bit. |
| `sensor dht disable` | Sensor | `CONTROL` | `OK sensor dht disable` | Preserve SR04 enable bit. |
| `sensor dht start` | Sensor | `COMMAND` | `OK sensor dht start` | DHT11 timing is slow; use timeout. |
| `sensor dht read` | Sensor | `DHT_VALUE` | `DHT humidity=<h> temperature=<t>` | Full protocol robustness remains board/future verification. |
| `sensor status` | Sensor | `STATUS` | `SENSOR status ...` | Decode live and enable bits. |
| `sensor version` | Sensor | `VERSION` | `SENSOR version=0x00010000` | Read-only. |
| `spi enable` | SPI | `CONTROL` | `OK spi enable` | Preserve mode bits. |
| `spi disable` | SPI | `CONTROL` | `OK spi disable` | New starts ignored when disabled. |
| `spi mode 0` | SPI | `CONTROL` | `OK spi mode 0` | CPOL=0, CPHA=0. |
| `spi mode 1` | SPI | `CONTROL` | `OK spi mode 1` | CPOL=0, CPHA=1. |
| `spi mode 2` | SPI | `CONTROL` | `OK spi mode 2` | CPOL=1, CPHA=0. |
| `spi mode 3` | SPI | `CONTROL` | `OK spi mode 3` | CPOL=1, CPHA=1. |
| `spi clkdiv <n>` | SPI | `CLKDIV` | `OK spi clkdiv <n>` | Wrapper clamps zero before master. |
| `spi tx <byte>` | SPI | `TXDATA` | `OK spi tx 0xNN` | Does not start transfer. |
| `spi start` | SPI | `COMMAND` | `OK spi start` or `ERR spi busy/disabled` | Poll busy/done. |
| `spi xfer <byte>` | SPI | `TXDATA`, `COMMAND`, `RXDATA`, `STATUS` | `SPI rx=0xNN` | Requires timeout. |
| `spi read` | SPI | `RXDATA` | `SPI rx=0xNN` | Last received byte. |
| `spi status` | SPI | `STATUS` | `SPI status busy=<0|1> done=<0|1> enable=<0|1> mode=<0..3>` | Poll before new transfer. |
| `spi version` | SPI | `VERSION` | `SPI version=0x00010000` | Read-only. |
| `i2c enable` | I2C | `CONTROL` | `OK i2c enable` | Preserve read ACK bit. |
| `i2c disable` | I2C | `CONTROL` | `OK i2c disable` | New commands ignored when disabled. |
| `i2c ack` | I2C | `CONTROL` | `OK i2c ack` | Select ACK after read byte. |
| `i2c nack` | I2C | `CONTROL` | `OK i2c nack` | Select NACK after read byte. |
| `i2c tx <byte>` | I2C | `TXDATA` | `OK i2c tx 0xNN` | Does not issue command. |
| `i2c start` | I2C | `COMMAND`, `STATUS` | `OK i2c start` or `ERR i2c busy/disabled/timeout` | Poll ready/done. |
| `i2c stop` | I2C | `COMMAND`, `STATUS` | `OK i2c stop` or `ERR i2c busy/disabled/timeout` | Poll ready/done. |
| `i2c write <byte>` | I2C | `TXDATA`, `COMMAND`, `STATUS` | `OK i2c write 0xNN ack=<0|1>` | Report NACK clearly. |
| `i2c read ack` | I2C | `CONTROL`, `COMMAND`, `RXDATA`, `STATUS` | `I2C rx=0xNN nack=<0|1>` | For intermediate bytes. |
| `i2c read nack` | I2C | `CONTROL`, `COMMAND`, `RXDATA`, `STATUS` | `I2C rx=0xNN nack=<0|1>` | For final byte. |
| `i2c rx` | I2C | `RXDATA` | `I2C rx=0xNN` | Last received byte. |
| `i2c status` | I2C | `STATUS` | `I2C status busy=<0|1> ready=<0|1> done=<0|1> nack=<0|1> enable=<0|1> read_ack=<0|1>` | Poll before commands. |
| `i2c bus` | I2C | `BUS_STATUS` | `I2C bus scl=<0|1> sda=<0|1> scl_drive_low=<0|1> sda_drive_low=<0|1>` | Useful for open-drain debug. |
| `i2c version` | I2C | `VERSION` | `I2C version=0x00010000` | Read-only. |

## Implementation Notes

- The command parser should share common helpers for 32-bit memory-mapped reads/writes, numeric parsing, timeout polling, and read-modify-write register updates.
- Commands that target write-one command registers should not depend on command-register readback.
- Polling loops need explicit timeout values so board-demo software cannot hang forever.
