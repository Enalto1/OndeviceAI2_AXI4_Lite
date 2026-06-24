# axi_spi_core RTL Hierarchy

## Scope

Prompt 14 implements the first `axi_spi_core` RTL wrapper only. No SPI simulation files, UVM environment, MicroBlaze software, Vivado block design, I2C implementation, or unrelated peripheral changes were created in this step.

## Implemented Files

```text
rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v
docs/rtl_views/axi_spi_core_hierarchy.md
```

## Hierarchy

```text
axi_spi_core
  u_spi_master_byte : spi_master_byte
```

The first version is master-only. `spi_slave_byte` remains optional/reference-only for a later slave or loopback extension.

## External Ports

| Wrapper port | Direction | Connected reused-core port |
| --- | --- | --- |
| `spi_sclk_o` | output | `u_spi_master_byte.sclk` |
| `spi_mosi_o` | output | `u_spi_master_byte.mosi` |
| `spi_miso_i` | input | `u_spi_master_byte.miso` |
| `spi_ss_n_o` | output | `u_spi_master_byte.ss_n` |

## Register-To-Port Mapping

| Register/field | Wrapper signal | Reused-core connection or behavior |
| --- | --- | --- |
| `CONTROL[0] enable` | `control_reg[0]` | Gates accepted `COMMAND[0]` start writes. |
| `CONTROL[1] cpol` | `control_reg[1]` | Drives `u_spi_master_byte.cpol`. |
| `CONTROL[2] cpha` | `control_reg[2]` | Drives `u_spi_master_byte.cpha`. |
| `CLKDIV[15:0]` | `clkdiv_reg[15:0]` | Stored value; readback is not clamped. |
| `clk_div_to_master` | `clk_div_to_master[15:0]` | Drives `u_spi_master_byte.clk_div` after zero clamp. |
| `TXDATA[7:0]` | `txdata_reg[7:0]` | Drives `u_spi_master_byte.tx_data`. |
| `COMMAND[0] start` | `spi_start_pulse` | One-clock pulse to `u_spi_master_byte.start`. |
| `RXDATA[7:0]` | `spi_rx_data[7:0]` | Reads `u_spi_master_byte.rx_data`. |
| `STATUS[0] busy` | `spi_busy` | Reads `u_spi_master_byte.busy`. |
| `STATUS[1] done_sticky` | `done_sticky` | Sticky completion flag set by `spi_done`. |
| `STATUS[8] enable` | `control_reg[0]` | Control mirror. |
| `STATUS[9] cpol` | `control_reg[1]` | Control mirror. |
| `STATUS[10] cpha` | `control_reg[2]` | Control mirror. |
| `VERSION` | constant | Reads `32'h0001_0000`. |

## Start Pulse Policy

`COMMAND` has no stored state and reads as zero. A write to `COMMAND[0]` generates `spi_start_pulse` for one `s00_axi_aclk` cycle only when all of these are true:

- `WSTRB[0] = 1`
- `WDATA[0] = 1`
- `CONTROL[0] enable = 1`
- `spi_busy = 0`

If the SPI core is disabled or busy, the start write is ignored and `done_sticky` is not cleared.

## done_sticky Policy

- Reset clears `done_sticky`.
- A new accepted start command clears the previous `done_sticky`.
- A pulse on `spi_done` from `u_spi_master_byte` sets `done_sticky`.
- `STATUS[1]` exposes the sticky bit.

## CLKDIV Zero Clamp Policy

`CLKDIV` can store `16'h0000`, and software reads back the stored zero. The value sent to the reused master is clamped:

```verilog
assign clk_div_to_master = (clkdiv_reg == 16'h0000) ? 16'h0001 : clkdiv_reg;
```

This avoids passing an all-zero divider into `spi_master_byte` while preserving software visibility of the written register value.

## WSTRB Summary

| Register | WSTRB behavior |
| --- | --- |
| `CONTROL` | `WSTRB[0]` updates bits `[2:0]`; other strobes have no visible effect. |
| `CLKDIV` | `WSTRB[0]` updates bits `[7:0]`; `WSTRB[1]` updates bits `[15:8]`; upper strobes ignored. |
| `TXDATA` | `WSTRB[0]` updates bits `[7:0]`; other strobes ignored. |
| `COMMAND` | `WSTRB[0]` can trigger start from `WDATA[0]`; other strobes ignored. |
| RO/reserved registers | Writes ignored. |

## Readback Summary

| Offset | Register | Readback |
| --- | --- | --- |
| `0x00` | `CONTROL` | `{29'd0, control_reg[2:0]}` |
| `0x04` | `CLKDIV` | `{16'h0000, clkdiv_reg[15:0]}` |
| `0x08` | `TXDATA` | `{24'h000000, txdata_reg[7:0]}` |
| `0x0C` | `COMMAND` | `32'h0000_0000` |
| `0x10` | `RXDATA` | `{24'h000000, spi_rx_data[7:0]}` |
| `0x14` | `STATUS` | busy, done sticky, and control mirrors at bits `[10:8]` |
| `0x1C` | `VERSION` | `32'h0001_0000` |
| reserved | reserved | `32'h0000_0000` |

## Reference RTL Status

The wrapper directly instantiates `spi_master_byte` as `u_spi_master_byte`. The reference files below remain unchanged:

```text
axi_project_unique_sources/sources/spi_master_byte.sv
axi_project_unique_sources/sources/spi_slave_byte.sv
```

## Simulation Status

SPI simulation is still pending. Prompt 14 intentionally does not create `sim/vivado/axi_spi_core`, a testbench, Tcl script, result file, or logs.