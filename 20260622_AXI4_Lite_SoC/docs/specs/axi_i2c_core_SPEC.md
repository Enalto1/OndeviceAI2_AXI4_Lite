# axi_i2c_core Specification

## Scope

`axi_i2c_core` is the planned AXI4-Lite I2C peripheral for the MicroBlaze SoC.

Prompt 16 defines the register map, source reuse policy, software-visible behavior, timing assumptions, open-drain port policy, and future verification expectations only. This step does not implement RTL, create an AXI wrapper, create a testbench, run Vivado simulation, create UVM, create MicroBlaze software, or create a Vivado block design.

The first version is a master-only low-level I2C command peripheral. MicroBlaze software issues explicit `START`, `STOP`, `WRITE_BYTE`, and `READ_BYTE` commands through AXI registers. The wrapper does not implement a high-level sensor protocol, does not hard-code device addresses, and does not run register sequences internally.

## Address Assignment

| Item | Value |
| --- | --- |
| Peripheral | `axi_i2c_core` |
| Base address | `0x44A5_0000` |
| High address | `0x44A5_FFFF` |
| Range | 64 KB |
| Local AXI address width | 6 bits |
| Local register offsets | `0x00` to `0x3C` |
| AXI data width | 32 bits |
| Vivado target assumption | Vivado 2020.2 |

## Future Wrapper Interface Assumptions

The future wrapper should follow the Vivado 2020.2 Xilinx AXI4-Lite slave template style already used by the earlier custom peripherals.

| Signal or parameter | Requirement |
| --- | --- |
| AXI clock | `s00_axi_aclk` |
| AXI reset | `s00_axi_aresetn`, active low |
| Internal reset | `rst = ~s00_axi_aresetn`, active high |
| AXI response | `OKAY` for implemented and reserved accesses |
| Local register decode | 32-bit aligned offsets inside the 6-bit local window |

## Future Wrapper Parameters

| Parameter | Default | Connection |
| --- | --- | --- |
| `I2C_CLK_HZ` | `100_000_000` | Passed to `i2c_master_core.CLK_HZ`. |
| `I2C_BUS_HZ` | `100_000` | Passed to `i2c_master_core.I2C_HZ`. |

The first wrapper does not include a runtime clock-divider register. I2C speed is a synthesis-time parameter decision in this version. A future Vivado simulation may override these parameters to accelerate command timing without modifying the reference RTL.

## Planned External Non-AXI Ports

The first wrapper should expose actual open-drain I2C pads:

```verilog
inout wire i2c_scl_io,
inout wire i2c_sda_io
```

Open-drain behavior:

- `i2c_master_core.scl_drive_low` and `i2c_master_core.sda_drive_low` request low bus drive.
- The wrapper drives a bus line low when its `drive_low` signal is `1`.
- The wrapper releases a bus line to high-Z when its `drive_low` signal is `0`.
- The master samples the actual pad values through `scl_in = i2c_scl_io` and `sda_in = i2c_sda_io`.
- External pull-ups are required on real hardware.
- The future testbench should model pull-up behavior.

Recommended future RTL intent:

```verilog
assign i2c_scl_io = scl_drive_low ? 1'b0 : 1'bz;
assign i2c_sda_io = sda_drive_low ? 1'b0 : 1'bz;

wire scl_in = i2c_scl_io;
wire sda_in = i2c_sda_io;
```

If a later Vivado packaging step prefers separate input/output/tri-state pins, that should be a later wrapper variant, not the first spec.

## Reference RTL Sources

The source inspection used these files:

```text
axi_project_unique_sources/sources/i2c_master_core.sv
axi_project_unique_sources/sources/i2c_slave_core.sv
```

`i2c_master_core.sv` is the direct reuse candidate for the first AXI wrapper. `i2c_slave_core.sv` is reusable RTL, but it remains optional/reference-only for the first master-only wrapper and should not be instantiated unless a later prompt explicitly asks for slave mode or loopback support.

Detailed source notes are captured in `docs/rtl_views/axi_i2c_core_reuse_notes.md`.

## Reused Master Command Encodings

The inspected `i2c_master_core.sv` defines these local command encodings:

| Command | Encoding |
| --- | --- |
| `CMD_START` | `3'd0` |
| `CMD_STOP` | `3'd1` |
| `CMD_WRITE_BYTE` | `3'd2` |
| `CMD_READ_BYTE` | `3'd3` |

The AXI wrapper should translate accepted writes to the `COMMAND` register into one-clock `cmd_valid` pulses with one of these command values.

## Register Map Summary

| Offset | Absolute address | Register | Access | Reset | Description |
| --- | --- | --- | --- | --- | --- |
| `0x00` | `0x44A5_0000` | `CONTROL` | RW | `0x0000_0000` | Enable and read ACK policy. |
| `0x04` | `0x44A5_0004` | `TXDATA` | RW | `0x0000_0000` | Byte passed to `i2c_master_core.tx_byte`. |
| `0x08` | `0x44A5_0008` | `COMMAND` | WO | reads `0x0000_0000` | Low-level I2C command request. |
| `0x0C` | `0x44A5_000C` | `RXDATA` | RO | dynamic | Last byte from `i2c_master_core.rx_byte`. |
| `0x10` | `0x44A5_0010` | `STATUS` | RO | dynamic | Busy, ready, done, NACK, and control mirrors. |
| `0x14` | `0x44A5_0014` | `BUS_STATUS` | RO | dynamic | SCL/SDA sampled and drive-low state. |
| `0x18` | `0x44A5_0018` | Reserved | Reserved | `0x0000_0000` | Reads zero, writes ignored. |
| `0x1C` | `0x44A5_001C` | `VERSION` | RO | `0x0001_0000` | Fixed peripheral version. |
| `0x20` to `0x3C` | `0x44A5_0020` to `0x44A5_003C` | Reserved | Reserved | `0x0000_0000` | Reads zero, writes ignored. |

## Register Details

### CONTROL - Offset `0x00`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[0]` | `enable` | RW | `0` | Allows accepted writes to `COMMAND`. When clear, command writes are ignored. |
| `[1]` | `read_ack` | RW | `0` | Used only for `READ_BYTE`; `1` drives ACK after the byte, `0` drives NACK after the byte. |
| `[31:2]` | reserved | RO | `0` | Reads as zero. Writes have no effect. |

### TXDATA - Offset `0x04`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[7:0]` | `tx_byte` | RW | `0x00` | Byte used by the next accepted `WRITE_BYTE` command. |
| `[31:8]` | reserved | RO | `0` | Reads as zero. Writes have no effect. |

### COMMAND - Offset `0x08`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[0]` | `start` | WO | Write `1` requests `CMD_START`. |
| `[1]` | `stop` | WO | Write `1` requests `CMD_STOP`. |
| `[2]` | `write_byte` | WO | Write `1` requests `CMD_WRITE_BYTE`. |
| `[3]` | `read_byte` | WO | Write `1` requests `CMD_READ_BYTE`. |
| `[31:4]` | reserved | WO | Writes have no effect. |

`COMMAND` has no stored state and always reads as zero.

Command acceptance rules:

- A command is accepted only when `CONTROL.enable=1` and `i2c_master_core.cmd_ready=1`.
- If `enable=0`, all command writes are ignored.
- If `cmd_ready=0`, all command writes are ignored.
- If multiple command bits are written as `1` in the same accepted write, priority is deterministic: `START` > `STOP` > `WRITE_BYTE` > `READ_BYTE`.
- An accepted command creates a one-clock `cmd_valid` pulse.
- An accepted command clears previous `done_sticky` and `nack_sticky`.

### RXDATA - Offset `0x0C`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[7:0]` | `rx_byte` | RO | Last received byte from `i2c_master_core.rx_byte`. |
| `[31:8]` | reserved | RO | Reads as zero. |

Writes to `RXDATA` have no effect.

### STATUS - Offset `0x10`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[0]` | `busy` | RO | Mirrors `i2c_master_core.busy`. |
| `[1]` | `cmd_ready` | RO | Mirrors `i2c_master_core.cmd_ready`. |
| `[2]` | `done_sticky` | RO | Set when `i2c_master_core.done` pulses; cleared by reset or a new accepted command. |
| `[3]` | `nack_sticky` | RO | Set when `i2c_master_core.done` pulses while `i2c_master_core.nack=1`; cleared by reset or a new accepted command. |
| `[4]` | `nack_live` | RO | Mirrors `i2c_master_core.nack`. |
| `[7:5]` | reserved | RO | Reads as zero. |
| `[8]` | `enable` | RO | Mirrors `CONTROL[0]`. |
| `[9]` | `read_ack` | RO | Mirrors `CONTROL[1]`. |
| `[31:10]` | reserved | RO | Reads as zero. |

Writes to `STATUS` have no effect.

### BUS_STATUS - Offset `0x14`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[0]` | `scl_in` | RO | Sampled SCL pad value. |
| `[1]` | `sda_in` | RO | Sampled SDA pad value. |
| `[2]` | `scl_drive_low` | RO | Wrapper/master requests SCL low drive. |
| `[3]` | `sda_drive_low` | RO | Wrapper/master requests SDA low drive. |
| `[31:4]` | reserved | RO | Reads as zero. |

Writes to `BUS_STATUS` have no effect.

### VERSION - Offset `0x1C`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[31:0]` | `version` | RO | `0x0001_0000` | Fixed first-version identifier. |

Writes to `VERSION` have no effect.

## WSTRB Policy

Writable registers must respect AXI `WSTRB`.

- `CONTROL`: `WSTRB[0]` updates bits `[1:0]`; `WSTRB[1]`, `WSTRB[2]`, and `WSTRB[3]` have no visible effect.
- `TXDATA`: `WSTRB[0]` updates bits `[7:0]`; `WSTRB[1]`, `WSTRB[2]`, and `WSTRB[3]` have no visible effect.
- `COMMAND`: `WSTRB[0]` enables command bits `[3:0]`; other strobes have no visible command effect.
- `COMMAND` reads zero, and command bits generate one-clock internal pulses only.
- Read-only and reserved registers ignore writes.
- Reserved bits always read as zero.

## Reset And Behavioral Requirements

On reset:

- `CONTROL` meaningful bits reset to zero.
- `TXDATA` resets to zero.
- `COMMAND` has no stored state and reads zero.
- `RXDATA` reflects the reset value of `i2c_master_core.rx_byte`.
- `STATUS.busy` reads zero.
- `STATUS.done_sticky` reads zero.
- `STATUS.nack_sticky` reads zero.
- `VERSION` reads `32'h0001_0000`.
- I2C drive-low outputs should release the bus.
- `i2c_scl_io` and `i2c_sda_io` are high-Z from the wrapper when the corresponding drive-low signal is zero.

Command behavior:

- Accepted `COMMAND` writes generate `cmd_valid` for one `s00_axi_aclk` cycle only.
- Accepted commands select exactly one `i2c_master_core` command code.
- Command priority when multiple command bits are set is `START` > `STOP` > `WRITE_BYTE` > `READ_BYTE`.
- Accepted commands clear `done_sticky` and `nack_sticky`.
- `i2c_master_core.done` sets `done_sticky`.
- `i2c_master_core.nack` captured with `done` sets `nack_sticky`.
- `CONTROL.read_ack` controls ACK/NACK behavior for `READ_BYTE`.

## Low-Level Command Sequence Examples

I2C write transaction:

```text
START
WRITE_BYTE address+w
WRITE_BYTE data
STOP
```

I2C read transaction:

```text
START
WRITE_BYTE address+r
READ_BYTE with read_ack=0 for final NACK
STOP
```

Repeated-start register read concept:

```text
START
WRITE_BYTE address+w
WRITE_BYTE register
START
WRITE_BYTE address+r
READ_BYTE
STOP
```

The first version does not include a high-level transaction engine. Software owns the command sequence and timeout policy.

## Decoupling Policy

`axi_i2c_core` is independent from GPIO, FND, Timer, Sensor, and SPI. It must not instantiate UVM files, MicroBlaze software, or Vivado block-design constructs.

## Implementation Boundary

This phase is specification-only. The planned RTL path remains:

```text
rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v
```

That file is intentionally not created in Prompt 16.
