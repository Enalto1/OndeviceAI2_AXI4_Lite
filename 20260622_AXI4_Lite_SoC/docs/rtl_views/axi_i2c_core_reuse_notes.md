# axi_i2c_core Reuse Notes

## Scope

Prompt 16 inspected the I2C reference RTL files and leaves them unchanged. This document records what should be reused directly and what should remain optional/reference-only for the first `axi_i2c_core` wrapper.

Reference directory:

```text
axi_project_unique_sources/sources
```

## Summary

| File | Reuse decision | First wrapper handling |
| --- | --- | --- |
| `i2c_master_core.sv` | Direct reuse candidate | Instantiate directly for the first master-only AXI wrapper. |
| `i2c_slave_core.sv` | Reusable optional/reference RTL | Keep optional/reference-only for later slave mode, board-to-board test support, or loopback-style verification if explicitly requested. |

## `i2c_master_core.sv`

### Module Declared

| Module | Purpose |
| --- | --- |
| `i2c_master_core` | Command-based byte-level I2C master with START, STOP, WRITE_BYTE, READ_BYTE commands, ready/done/busy/NACK/RX status, and open-drain drive-low outputs. |

### Parameters

| Parameter | Default | Notes |
| --- | --- | --- |
| `CLK_HZ` | `100_000_000` | Source clock frequency used to derive quarter-period timing. |
| `I2C_HZ` | `100_000` | Target I2C bus frequency. |

The file computes `RAW_QUARTER_PERIOD`, clamps `QUARTER_PERIOD` to at least one, and uses `$clog2` to derive `CNT_WIDTH` when the quarter period is greater than one.

### Top Ports

| Port | Direction | Width | Planned AXI wrapper connection |
| --- | --- | --- | --- |
| `clk` | input | 1 | `s00_axi_aclk` |
| `rst` | input | 1 | `~s00_axi_aresetn`, active high |
| `cmd_valid` | input | 1 | One-clock pulse from accepted `COMMAND` write. |
| `cmd` | input | 3 | Encoded command selected by `COMMAND` priority. |
| `tx_byte` | input | 8 | `TXDATA[7:0]`. |
| `read_ack` | input | 1 | `CONTROL[1]`; `1` drives ACK after read, `0` releases SDA for NACK. |
| `cmd_ready` | output | 1 | `STATUS[1]`; high when internal state is idle. |
| `done` | output | 1 | Sets `STATUS[2] done_sticky`. |
| `busy` | output | 1 | `STATUS[0]`; high when bus active or command state is not idle. |
| `nack` | output | 1 | `STATUS[4] nack_live`; captured into `STATUS[3] nack_sticky` on done. |
| `rx_byte` | output | 8 | `RXDATA[7:0]`. |
| `scl_drive_low` | output | 1 | Open-drain SCL low-drive request and `BUS_STATUS[2]`. |
| `sda_drive_low` | output | 1 | Open-drain SDA low-drive request and `BUS_STATUS[3]`. |
| `scl_in` | input | 1 | Sampled `i2c_scl_io` pad value and `BUS_STATUS[0]`. |
| `sda_in` | input | 1 | Sampled `i2c_sda_io` pad value and `BUS_STATUS[1]`. |

### Reset Polarity

The master uses active-high asynchronous reset:

```systemverilog
always_ff @(posedge clk or posedge rst)
```

On reset it returns to `S_IDLE`, clears counters and shift registers, clears `done` and `nack`, sets `rx_byte` to zero, clears `bus_active`, and releases SCL/SDA drive-low outputs.

### Command Encodings

The inspected localparams are:

| Command | Encoding |
| --- | --- |
| `CMD_START` | `3'd0` |
| `CMD_STOP` | `3'd1` |
| `CMD_WRITE_BYTE` | `3'd2` |
| `CMD_READ_BYTE` | `3'd3` |

### Output And Input Behavior

- `cmd_ready` is high only in `S_IDLE`.
- `done` is a pulse generated when START, STOP, WRITE_BYTE, or READ_BYTE command work completes.
- `busy` is high when the bus-active flag is set or the state machine is not idle.
- `nack` is updated during the write ACK phase from sampled `sda_in`.
- `rx_byte` holds the last completed read byte.
- `scl_drive_low` and `sda_drive_low` are active-high requests to pull the open-drain bus low.
- `scl_in` is sampled into an unused internal wire in this implementation; SCL stretching is not implemented.
- `sda_in` is sampled for write ACK/NACK and read-data bits.
- `read_ack` is captured for READ_BYTE and controls the ACK/NACK bit after the received byte.

### Helper Modules

No helper modules are declared or instantiated in `i2c_master_core.sv`.

### Reuse Conclusion

`i2c_master_core.sv` is reusable as-is and is the direct reuse candidate for the first `axi_i2c_core` wrapper. The wrapper should instantiate it directly, translate AXI `COMMAND` writes into one-clock `cmd_valid` pulses, expose its status/data outputs, and implement open-drain pad handling around its drive-low outputs.

## `i2c_slave_core.sv`

### Module Declared

| Module | Purpose |
| --- | --- |
| `i2c_slave_core` | Byte-level I2C slave engine with START/STOP detection, address match, RX byte valid, TX byte handshaking, master ACK capture, and open-drain SDA drive-low output. |

### Parameters

| Parameter | Default | Notes |
| --- | --- | --- |
| `SLAVE_ADDR` | `7'h42` | 7-bit slave address used for address-match detection. |

The slave file does not use `$clog2`.

### Top Ports

| Port | Direction | Width | Notes |
| --- | --- | --- | --- |
| `clk` | input | 1 | Local system clock. |
| `rst` | input | 1 | Active-high asynchronous reset. |
| `scl_in` | input | 1 | Sampled I2C SCL. |
| `sda_in` | input | 1 | Sampled I2C SDA. |
| `sda_drive_low` | output | 1 | Open-drain SDA low-drive request. |
| `addr_ack` | input | 1 | Controls ACK/NACK after matched address. |
| `addr_seen_pulse` | output | 1 | Pulses when an address byte is received. |
| `addr_match` | output | 1 | Indicates received address matched `SLAVE_ADDR`. |
| `addr_read` | output | 1 | Captures address R/W bit. |
| `rx_byte` | output | 8 | Last received data byte. |
| `rx_byte_valid` | output | 1 | One-clock pulse for a completed RX data byte. |
| `rx_ack` | input | 1 | Controls ACK/NACK after received data byte. |
| `tx_byte` | input | 8 | Byte presented during transmit mode. |
| `tx_byte_done` | output | 1 | Pulses when a TX byte has been shifted. |
| `tx_master_ack` | output | 1 | Captures whether the external master ACKed the TX byte. |
| `start_pulse` | output | 1 | Pulses on detected START. |
| `stop_pulse` | output | 1 | Pulses on detected STOP. |
| `busy` | output | 1 | High when slave state is not idle. |

### Reset Polarity

The slave uses active-high asynchronous reset:

```systemverilog
always_ff @(posedge clk or posedge rst)
```

On reset it returns to `S_IDLE`, initializes synchronized SCL/SDA state high, clears RX/TX/event registers, and releases `sda_drive_low`.

### Output And Input Behavior

- SCL and SDA are synchronized through meta/sync/previous registers.
- START is detected when SDA falls while synchronized SCL is high and the core is not driving SDA.
- STOP is detected when SDA rises while synchronized SCL is high and the core is not driving SDA.
- Address reception captures the R/W bit and compares `[7:1]` against `SLAVE_ADDR`.
- `addr_seen_pulse`, `rx_byte_valid`, `tx_byte_done`, `start_pulse`, and `stop_pulse` are one-clock event pulses.
- `sda_drive_low` is asserted to ACK address/data or to transmit zero bits.
- `tx_master_ack` captures the external master's ACK after a transmitted byte.

### Helper Modules

No helper modules are declared or instantiated in `i2c_slave_core.sv`.

### Reuse Conclusion

`i2c_slave_core.sv` is reusable RTL, but it should remain optional/reference-only for the first `axi_i2c_core`. It may be useful later for slave mode, board-to-board test support, or as a verification companion if a later prompt explicitly requests it. The first wrapper should not instantiate it.

## First Wrapper Decision

The first `axi_i2c_core` should be master-only:

```text
AXI COMMAND/TXDATA/CONTROL registers
  -> i2c_master_core.cmd_valid/cmd/tx_byte/read_ack
  -> i2c_master_core busy/done/nack/rx_byte/drive_low outputs
  -> AXI STATUS/RXDATA/BUS_STATUS registers and open-drain pads
```

No GPIO, FND, Timer, Sensor, SPI, UVM, MicroBlaze software, or block-design files belong in the first I2C wrapper.

## Open Items For RTL Phase

- Confirm the future wrapper parameter names `I2C_CLK_HZ` and `I2C_BUS_HZ`.
- Confirm whether simulation should override timing parameters to accelerate directed tests.
- Confirm final physical pull-up assumptions for Basys3 wiring or PMOD usage.
- Confirm whether a later slave/loopback feature is needed after the first master-only simulation passes.
## Prompt 17 Implementation Decision

Prompt 17 implemented the first master-only AXI4-Lite wrapper here:

```text
rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v
```

Implementation facts:

- Instance name: `u_i2c_master_core`.
- Directly instantiates `i2c_master_core`.
- Passes wrapper parameters `I2C_CLK_HZ` and `I2C_BUS_HZ` into `CLK_HZ` and `I2C_HZ`.
- Implements open-drain `i2c_scl_io` and `i2c_sda_io` with drive-low-or-high-Z assignments.
- Uses `CONTROL[0]` to gate command acceptance and `CONTROL[1]` for read ACK/NACK behavior.
- Uses `TXDATA[7:0]` as the master transmit byte.
- Converts accepted `COMMAND[3:0]` writes into one-clock `i2c_cmd_valid_pulse` events.
- Command priority is START, STOP, WRITE_BYTE, READ_BYTE.
- Implements `done_sticky` and `nack_sticky`.
- Does not instantiate `i2c_slave_core`.
- Does not instantiate GPIO, FND, Timer, Sensor, SPI, UVM, MicroBlaze software, or block-design constructs.
- Keeps the first wrapper master-only.

Reference I2C RTL remains unchanged:

```text
axi_project_unique_sources/sources/i2c_master_core.sv
axi_project_unique_sources/sources/i2c_slave_core.sv
```

I2C simulation remains pending and should compile `i2c_master_core.sv` as SystemVerilog in a future Vivado 2020.2 simulation Tcl.
