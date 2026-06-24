# axi_i2c_core RTL Hierarchy

## Scope

Prompt 17 implements the first `axi_i2c_core` AXI4-Lite wrapper only. It does not create a Vivado simulation testbench, run Vivado, create UVM, create MicroBlaze software, or create a Vivado block design.

## Files

| File | Role |
| --- | --- |
| `rtl_work/axi_peripherals/axi_i2c_core/hdl/axi_i2c_core.v` | Project-owned AXI4-Lite I2C wrapper. |
| `axi_project_unique_sources/sources/i2c_master_core.sv` | Directly reused I2C master engine. |
| `axi_project_unique_sources/sources/i2c_slave_core.sv` | Optional/reference-only; not instantiated in the first wrapper. |

## Hierarchy

```text
axi_i2c_core
  -> u_i2c_master_core : i2c_master_core
```

No GPIO, FND, Timer, Sensor, SPI, UVM, MicroBlaze software, or block-design modules are instantiated by `axi_i2c_core`.

## Wrapper Parameters

| Parameter | Default | Use |
| --- | --- | --- |
| `C_S00_AXI_DATA_WIDTH` | `32` | AXI data width. |
| `C_S00_AXI_ADDR_WIDTH` | `6` | Local AXI address width. |
| `I2C_CLK_HZ` | `100_000_000` | Passed to `i2c_master_core.CLK_HZ`. |
| `I2C_BUS_HZ` | `100_000` | Passed to `i2c_master_core.I2C_HZ`. |

## Register-To-Port Mapping

| Register/field | Wrapper signal | Reused master port or readback |
| --- | --- | --- |
| `CONTROL[0] enable` | `control_reg[0]` | Gates accepted `COMMAND` writes; mirrored in `STATUS[8]`. |
| `CONTROL[1] read_ack` | `control_reg[1]` | Drives `i2c_master_core.read_ack`; mirrored in `STATUS[9]`. |
| `TXDATA[7:0]` | `txdata_reg[7:0]` | Drives `i2c_master_core.tx_byte`. |
| `COMMAND[3:0]` | accepted write only | Generates `i2c_cmd_valid_pulse` and selects `i2c_cmd_code`. |
| `RXDATA[7:0]` | `i2c_rx_byte[7:0]` | Reads `i2c_master_core.rx_byte`. |
| `STATUS[0]` | `i2c_busy` | Reads `i2c_master_core.busy`. |
| `STATUS[1]` | `i2c_cmd_ready` | Reads `i2c_master_core.cmd_ready`. |
| `STATUS[2]` | `done_sticky` | Set by `i2c_done`; cleared by reset or accepted command. |
| `STATUS[3]` | `nack_sticky` | Set by `i2c_done && i2c_nack`; cleared by reset or accepted command. |
| `STATUS[4]` | `i2c_nack` | Live NACK value from `i2c_master_core.nack`. |
| `BUS_STATUS[0]` | `scl_in` | Sampled SCL pad value. |
| `BUS_STATUS[1]` | `sda_in` | Sampled SDA pad value. |
| `BUS_STATUS[2]` | `scl_drive_low` | Master open-drain SCL low-drive request. |
| `BUS_STATUS[3]` | `sda_drive_low` | Master open-drain SDA low-drive request. |
| `VERSION` | constant | Reads `32'h0001_0000`. |

Reserved offsets read `32'h0000_0000` and ignore writes.

## Open-Drain SCL/SDA Path

The wrapper exposes real bidirectional open-drain-style I2C pins:

```verilog
assign i2c_scl_io = scl_drive_low ? 1'b0 : 1'bz;
assign i2c_sda_io = sda_drive_low ? 1'b0 : 1'bz;
assign scl_in = i2c_scl_io;
assign sda_in = i2c_sda_io;
```

`drive_low=1` pulls the bus low. `drive_low=0` releases the line. External hardware must provide pull-ups, and the future testbench should model them.

## COMMAND Priority And Pulse Policy

`COMMAND` reads as zero and has no stored state.

An accepted command requires:

- `WSTRB[0] = 1`
- `CONTROL.enable = 1`
- `i2c_cmd_ready = 1`
- at least one bit set in `WDATA[3:0]`

When accepted, `i2c_cmd_valid_pulse` is asserted for one `s00_axi_aclk` cycle and `i2c_cmd_code` is selected by priority:

1. `WDATA[0]` -> `I2C_CMD_START`
2. `WDATA[1]` -> `I2C_CMD_STOP`
3. `WDATA[2]` -> `I2C_CMD_WRITE_BYTE`
4. `WDATA[3]` -> `I2C_CMD_READ_BYTE`

Ignored commands do not pulse `i2c_cmd_valid_pulse`, do not change `i2c_cmd_code`, and do not clear sticky flags.

## Sticky Status Policy

- `done_sticky` resets to zero.
- `nack_sticky` resets to zero.
- Accepted commands clear both sticky bits.
- `i2c_done` sets `done_sticky`.
- `i2c_done && i2c_nack` sets `nack_sticky`.

If an accepted command and a done pulse occur in the same clock, the accepted command clear assignments have priority in the wrapper register process.

## WSTRB Summary

| Register | Implemented strobe behavior |
| --- | --- |
| `CONTROL` | `WSTRB[0]` updates `CONTROL[1:0]`; other byte lanes have no visible effect. |
| `TXDATA` | `WSTRB[0]` updates `TXDATA[7:0]`; other byte lanes have no visible effect. |
| `COMMAND` | `WSTRB[0]` can trigger command bits `[3:0]`; other byte lanes have no visible effect. |
| Read-only/reserved | Writes ignored. |

## Master-Only First Version

The first wrapper directly instantiates `i2c_master_core` as `u_i2c_master_core`. It does not instantiate `i2c_slave_core`. Slave mode, loopback support, or board-to-board test companion logic remain future options only.

## Reference RTL Status

The reference I2C files remain unchanged:

```text
axi_project_unique_sources/sources/i2c_master_core.sv
axi_project_unique_sources/sources/i2c_slave_core.sv
```

## Verification Status

I2C Vivado simulation is still pending. Future simulation should compile `i2c_master_core.sv` as SystemVerilog and exercise the directed checks in `docs/specs/axi_i2c_core_VERIFICATION_PLAN.md`.
