# axi_i2c_core Verification Plan

## Scope

This is the future verification plan for `axi_i2c_core`. Prompt 16 does not create a testbench, run Vivado simulation, create UVM, create MicroBlaze software, create a Vivado block design, or implement RTL.

The first verification milestone should be a focused Vivado 2020.2/xsim behavioral simulation after the RTL wrapper exists.

## Verification Goals

- Confirm the AXI register map matches `docs/specs/axi_i2c_core_SPEC.md`.
- Confirm `COMMAND` writes generate one-clock `cmd_valid` pulses only when accepted.
- Confirm `i2c_master_core` is connected directly and correctly.
- Confirm `CONTROL`, `TXDATA`, `RXDATA`, `STATUS`, `BUS_STATUS`, and `VERSION` behavior.
- Confirm open-drain SCL/SDA pad behavior.
- Confirm read-only and reserved registers ignore writes.
- Confirm `i2c_slave_core.sv` is not required for the first master-only wrapper simulation unless a later prompt explicitly asks for it.
- Confirm I2C remains independent from GPIO, FND, Timer, Sensor, SPI, UVM, MicroBlaze software, and block-design files.

## Directed Vivado Simulation Checklist

| ID | Test | Expected result |
| --- | --- | --- |
| 1 | Reset behavior | `CONTROL=0`, `TXDATA=0`, `COMMAND` reads zero, sticky flags clear, bus drive-low outputs release, and `VERSION=32'h0001_0000`. |
| 2 | `CONTROL` write/read | `enable` and `read_ack` store and read back; reserved bits read zero. |
| 3 | `CONTROL` WSTRB behavior | Only `WSTRB[0]` affects `CONTROL[1:0]`. |
| 4 | `TXDATA` write/read | `TXDATA[7:0]` stores and reads back; reserved bits read zero. |
| 5 | `TXDATA` WSTRB behavior | Only `WSTRB[0]` affects `TXDATA[7:0]`. |
| 6 | `COMMAND` reads zero | Writes do not store state; reads always return zero. |
| 7 | `COMMAND` ignored when enable=0 | Command writes do not pulse `cmd_valid` and do not clear sticky flags. |
| 8 | `COMMAND` ignored when `cmd_ready=0` | Writes during an active command are ignored and do not corrupt the current operation. |
| 9 | `COMMAND` priority | Multi-bit writes select `START` before `STOP`, `WRITE_BYTE`, or `READ_BYTE`; `STOP` before byte commands; `WRITE_BYTE` before `READ_BYTE`. |
| 10 | `START` command pulse and bus activity | Accepted start generates one-cycle `cmd_valid` with `CMD_START` and produces expected SCL/SDA activity. |
| 11 | `STOP` command pulse and bus release | Accepted stop generates one-cycle `cmd_valid` with `CMD_STOP`, completes, and releases bus-active state. |
| 12 | `WRITE_BYTE` command with ACK | Byte transmit completes with `nack_live=0` and no new `nack_sticky`. |
| 13 | `WRITE_BYTE` command with NACK | Controlled SDA high during ACK phase sets `nack_live` and `nack_sticky` after done. |
| 14 | `READ_BYTE` with ACK | `CONTROL.read_ack=1` makes the master drive ACK after the byte. |
| 15 | `READ_BYTE` with NACK | `CONTROL.read_ack=0` makes the master release SDA for final NACK after the byte. |
| 16 | `RXDATA` readback | `RXDATA[7:0]` reflects the received byte. |
| 17 | `STATUS` sticky behavior | `done_sticky` sets on done, `nack_sticky` captures NACK on done, and both clear on a new accepted command. |
| 18 | `BUS_STATUS` readback | SCL/SDA pad values and drive-low states read back in the documented bit positions. |
| 19 | `VERSION` read and RO protection | `VERSION` reads fixed value and ignores writes. |
| 20 | Reserved offset behavior | Reserved offsets read zero and ignore writes. |
| 21 | WSTRB behavior | `CONTROL`, `TXDATA`, and `COMMAND` honor byte strobes exactly. |
| 22 | I2C open-drain behavior | Drive-low outputs pull the bus low; released outputs rely on modeled pull-ups. |
| 23 | I2C independence compile check | The simulation compiles no GPIO, FND, Timer, Sensor, SPI, UVM, MicroBlaze software, or block-design files. |

## Suggested Simulation Structure

Future files, not created in this phase:

```text
sim/vivado/axi_i2c_core/tb_axi_i2c_core.sv
sim/vivado/axi_i2c_core/run_axi_i2c_core_sim.tcl
```

The testbench should be directed and similar in style to the passing GPIO, FND, Timer, Sensor, and SPI Vivado simulations.

## Simulation Strategy

- Model pull-ups on `i2c_scl_io` and `i2c_sda_io`.
- Use controlled SDA behavior to simulate ACK, NACK, and read-data bits.
- Verify low-level command sequences rather than a high-level sensor protocol.
- Do not require `i2c_slave_core` in the first master-only wrapper simulation unless a later prompt explicitly broadens the scope.
- The testbench may override `I2C_CLK_HZ` and/or `I2C_BUS_HZ` to shorten command timing, but the reference RTL must remain unchanged.

## Expected Future Result File

Recommended future result file:

```text
sim/vivado/axi_i2c_core/axi_i2c_core_sim_result.txt
```

Recommended passing marker:

```text
[TB PASS] axi_i2c_core directed tests passed
```

## UVM Policy

UVM remains deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.
