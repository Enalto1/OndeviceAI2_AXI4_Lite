# axi_spi_core Reuse Notes

## Scope

Unattended Phase D inspected the SPI reference RTL files and leaves them unchanged. This document records what should be reused directly and what should remain optional/reference-only for the first `axi_spi_core` wrapper.

Reference directory:

```text
axi_project_unique_sources/sources
```

## Summary

| File | Reuse decision | First wrapper handling |
| --- | --- | --- |
| `spi_master_byte.sv` | Direct reuse candidate | Instantiate directly for the first master-only AXI wrapper. |
| `spi_slave_byte.sv` | Optional reuse/reference | Use later for slave mode or simulation loopback support if explicitly requested. |

## `spi_master_byte.sv`

### Module Declared

| Module | Purpose |
| --- | --- |
| `spi_master_byte` | Parameterized 8-bit SPI master primitive with CPOL/CPHA, clock divider, byte TX/RX, busy/done, and SPI pins. |

### Parameters

| Parameter | Default | Notes |
| --- | --- | --- |
| `CLK_DIV_WIDTH` | `16` | Width of the `clk_div` input and internal divider registers. |

### Top Ports

| Port | Direction | Width | Planned AXI wrapper connection |
| --- | --- | --- | --- |
| `clk` | input | 1 | `s00_axi_aclk` |
| `rst` | input | 1 | `~s00_axi_aresetn` |
| `start` | input | 1 | One-clock pulse from `COMMAND[0]` when enabled and idle. |
| `clk_div` | input | `CLK_DIV_WIDTH` | `CLKDIV[15:0]` for default width. |
| `cpol` | input | 1 | `CONTROL[1]`. |
| `cpha` | input | 1 | `CONTROL[2]`. |
| `tx_data` | input | 8 | `TXDATA[7:0]`. |
| `miso` | input | 1 | `spi_miso_i`. |
| `rx_data` | output | 8 | `RXDATA[7:0]`. |
| `busy` | output | 1 | `STATUS[0]`. |
| `done` | output | 1 | Sets `STATUS[1] done_sticky`. |
| `sclk` | output | 1 | `spi_sclk_o`. |
| `mosi` | output | 1 | `spi_mosi_o`. |
| `ss_n` | output | 1 | `spi_ss_n_o`. |

### Behavior Observed

- One `start` pulse transfers exactly one byte.
- CPOL, CPHA, clock divider, and TX byte are latched at transfer start.
- `busy` is high during transfer.
- `done` pulses when the byte transfer completes.
- Idle bus drives `ss_n=1`, `mosi=1`, and parks `sclk` at CPOL.
- The implementation is SystemVerilog and should be compiled as SystemVerilog in Vivado 2020.2.

### Reuse Conclusion

`spi_master_byte.sv` is a direct reuse candidate. The first wrapper should add AXI registers around it and avoid modifying the reference file.

## `spi_slave_byte.sv`

### Module Declared

| Module | Purpose |
| --- | --- |
| `spi_slave_byte` | Synchronous 8-bit SPI slave byte engine with input synchronizers, CPOL/CPHA, TX load, RX valid, byte done, busy, and MISO output enable. |

### Top Ports

| Port | Direction | Width | Notes |
| --- | --- | --- | --- |
| `clk` | input | 1 | Local system clock. |
| `rst` | input | 1 | Active-high reset. |
| `cpol` | input | 1 | SPI mode bit. |
| `cpha` | input | 1 | SPI mode bit. |
| `tx_data` | input | 8 | Slave response byte. |
| `tx_load` | input | 1 | Load response byte. |
| `rx_data` | output | 8 | Received byte from external master. |
| `rx_data_valid` | output | 1 | One-clock valid pulse. |
| `byte_done` | output | 1 | One-clock byte-done pulse. |
| `busy` | output | 1 | Active while selected. |
| `spi_sclk` | input | 1 | External SPI clock input. |
| `spi_mosi` | input | 1 | External MOSI input. |
| `spi_ss_n` | input | 1 | External active-low chip select input. |
| `miso_o` | output | 1 | Slave MISO data. |
| `miso_oe` | output | 1 | MISO output enable. |

### Behavior Observed

- Synchronizes asynchronous SPI SCLK, MOSI, and SS_n into `clk`.
- Supports CPOL/CPHA edge selection.
- Pulses `rx_data_valid` and `byte_done` when the eighth bit is sampled.
- Gates `miso_oe` with raw `spi_ss_n` so the output driver is disabled when chip select is high.

### Reuse Conclusion

`spi_slave_byte.sv` should remain optional for the first `axi_spi_core`. It may be useful later for a slave-mode extension or for a loopback-style simulation companion, but a master-only AXI wrapper can proceed without instantiating it.

## Open Items For RTL Phase

- Decide whether `CLKDIV=0` is allowed as the fastest setting or clamped to one.
- Decide whether `done_sticky` is cleared by read, by new start, or by an explicit command. This spec currently chooses reset or new accepted start.
- Decide whether optional slave or loopback support belongs in the first RTL wrapper or a later revision.
- Confirm Vivado 2020.2 SystemVerilog compile options in the SPI simulation Tcl.
## Prompt 14 Implementation Decision

Prompt 14 implemented the first master-only AXI4-Lite wrapper here:

```text
rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v
```

Implementation facts:

- Instance name: `u_spi_master_byte`.
- Directly instantiates `spi_master_byte` with `.CLK_DIV_WIDTH(16)`.
- Does not instantiate `spi_slave_byte`.
- Does not instantiate GPIO, FND, Timer, Sensor, I2C, UVM, MicroBlaze software, or block-design constructs.
- Keeps `spi_slave_byte.sv` optional/reference-only for future slave or loopback support.
- Preserves the first wrapper as master-only.

CLKDIV zero policy:

- `CLKDIV` may store `16'h0000`.
- `CLKDIV` readback returns the stored value.
- `clk_div_to_master` clamps zero to `16'h0001` before driving `spi_master_byte.clk_div`.

Reference SPI RTL remains unchanged:

```text
axi_project_unique_sources/sources/spi_master_byte.sv
axi_project_unique_sources/sources/spi_slave_byte.sv
```

SPI simulation remains pending and should compile `spi_master_byte.sv` as SystemVerilog in the future Vivado 2020.2 simulation Tcl.