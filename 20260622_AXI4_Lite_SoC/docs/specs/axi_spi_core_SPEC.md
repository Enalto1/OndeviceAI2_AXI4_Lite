# axi_spi_core Specification

## Scope

`axi_spi_core` is the planned AXI4-Lite SPI byte-transfer peripheral for the MicroBlaze SoC.

This unattended Phase D specification defines the register map, source reuse policy, software-visible behavior, and future verification expectations only. It does not implement RTL, create a simulation, run Vivado, create UVM, create MicroBlaze software, or create a Vivado block design.

## Address Assignment

| Item | Value |
| --- | --- |
| Peripheral | `axi_spi_core` |
| Base address | `0x44A4_0000` |
| High address | `0x44A4_FFFF` |
| Range | 64 KB |
| Local AXI address width | 6 bits |
| Local register offsets | `0x00` to `0x3C` |
| AXI data width | 32 bits |
| Vivado target assumption | Vivado 2020.2 |

## Future Wrapper Interface Assumptions

The future wrapper should follow the Vivado 2020.2 Xilinx AXI4-Lite slave template style already used by GPIO, FND, Timer, and Sensor.

| Signal or parameter | Requirement |
| --- | --- |
| AXI clock | `s00_axi_aclk` |
| AXI reset | `s00_axi_aresetn`, active low |
| Internal reset | `rst = ~s00_axi_aresetn`, active high |
| AXI response | `OKAY` for implemented and reserved accesses |
| Local register decode | 32-bit aligned offsets inside the 6-bit local window |

## Planned External Non-AXI Ports

The first SPI wrapper should expose one master channel.

| Port | Direction | Width | Description |
| --- | --- | --- | --- |
| `spi_sclk_o` | output | 1 | SPI serial clock from the reused master. |
| `spi_mosi_o` | output | 1 | SPI master-out/slave-in data. |
| `spi_miso_i` | input | 1 | SPI master-in/slave-out data. |
| `spi_ss_n_o` | output | 1 | Active-low slave select from the reused master. |

Optional loopback or slave-support ports may be added later only if the RTL phase explicitly chooses to expose `spi_slave_byte`.

## Reference RTL Sources

The source inspection used these files:

```text
axi_project_unique_sources/sources/spi_master_byte.sv
axi_project_unique_sources/sources/spi_slave_byte.sv
```

`spi_master_byte.sv` is the direct reuse candidate for the first AXI wrapper. `spi_slave_byte.sv` is useful as optional slave-mode support or a verification companion, but it should not be required for the first master-only wrapper.

Detailed source notes are captured in `docs/rtl_views/axi_spi_core_reuse_notes.md`.

## Register Map Summary

| Offset | Absolute address | Register | Access | Reset | Description |
| --- | --- | --- | --- | --- | --- |
| `0x00` | `0x44A4_0000` | `CONTROL` | RW | `0x0000_0000` | Enable and SPI mode bits. |
| `0x04` | `0x44A4_0004` | `CLKDIV` | RW | `0x0000_0001` | Clock divider value passed to `spi_master_byte.clk_div`. |
| `0x08` | `0x44A4_0008` | `TXDATA` | RW | `0x0000_0000` | Byte to transmit on the next command. |
| `0x0C` | `0x44A4_000C` | `COMMAND` | WO | reads `0x0000_0000` | Write-one start pulse. |
| `0x10` | `0x44A4_0010` | `RXDATA` | RO | dynamic | Last received byte. |
| `0x14` | `0x44A4_0014` | `STATUS` | RO | dynamic | Busy/done state and control mirrors. |
| `0x18` | `0x44A4_0018` | Reserved | Reserved | `0x0000_0000` | Reads zero, writes ignored. |
| `0x1C` | `0x44A4_001C` | `VERSION` | RO | `0x0001_0000` | Fixed peripheral version. |
| `0x20` to `0x3C` | `0x44A4_0020` to `0x44A4_003C` | Reserved | Reserved | `0x0000_0000` | Reads zero, writes ignored. |

## Register Details

### CONTROL - Offset `0x00`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[0]` | `enable` | RW | `0` | Allows `COMMAND[0]` to launch a transfer. |
| `[1]` | `cpol` | RW | `0` | Latched by `spi_master_byte` at transfer start. |
| `[2]` | `cpha` | RW | `0` | Latched by `spi_master_byte` at transfer start. |
| `[31:3]` | reserved | RO | `0` | Reads as zero. Writes have no effect. |

### CLKDIV - Offset `0x04`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[15:0]` | `clk_div` | RW | `1` | Divider value connected to `spi_master_byte.clk_div`. |
| `[31:16]` | reserved | RO | `0` | Reads as zero. Writes have no effect. |

The RTL phase may clamp an all-zero divider to one if simulation shows a zero divider is too fast for intended board use. That policy must be documented if implemented.

### TXDATA - Offset `0x08`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[7:0]` | `tx_data` | RW | `0x00` | Byte sampled by the master when `COMMAND[0]` starts a transfer. |
| `[31:8]` | reserved | RO | `0` | Reads as zero. Writes have no effect. |

### COMMAND - Offset `0x0C`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[0]` | `start` | WO | n/a | Write `1` creates a one-clock start pulse when `CONTROL[0]=1` and the master is not busy. |
| `[31:1]` | reserved | WO | n/a | Writes have no effect. |

`COMMAND` has no stored state and always reads as zero.

### RXDATA - Offset `0x10`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[7:0]` | `rx_data` | RO | Last byte received from `spi_master_byte.rx_data`. |
| `[31:8]` | reserved | RO | Reads as zero. |

Writes to `RXDATA` have no effect.

### STATUS - Offset `0x14`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[0]` | `busy` | RO | Mirrors `spi_master_byte.busy`. |
| `[1]` | `done_sticky` | RO | Set when a transfer completes; cleared by a new accepted start command or reset. |
| `[2]` | reserved/error | RO | Reserved zero for the first master-only wrapper unless an error condition is added later. |
| `[7:3]` | reserved | RO | Reads as zero. |
| `[8]` | `enable` | RO | Mirrors `CONTROL[0]`. |
| `[9]` | `cpol` | RO | Mirrors `CONTROL[1]`. |
| `[10]` | `cpha` | RO | Mirrors `CONTROL[2]`. |
| `[31:11]` | reserved | RO | Reads as zero. |

Writes to `STATUS` have no effect.

### VERSION - Offset `0x1C`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[31:0]` | `version` | RO | `0x0001_0000` | Fixed first-version identifier. |

Writes to `VERSION` have no effect.

## WSTRB Policy

Writable registers must respect AXI `WSTRB`.

- `CONTROL`: `WSTRB[0]` updates bits `[2:0]`; other strobes have no visible effect.
- `CLKDIV`: `WSTRB[0]` updates bits `[7:0]`; `WSTRB[1]` updates bits `[15:8]`; `WSTRB[2]` and `WSTRB[3]` have no visible effect.
- `TXDATA`: `WSTRB[0]` updates bits `[7:0]`; `WSTRB[1]` through `WSTRB[3]` have no visible effect.
- `COMMAND`: `WSTRB[0]` can trigger `start`; other strobes have no visible effect.
- Read-only and reserved registers ignore writes.

## Reset And Behavioral Requirements

On reset:

- `CONTROL` meaningful bits reset to zero.
- `CLKDIV` resets to `16'h0001`.
- `TXDATA` resets to zero.
- `COMMAND` reads zero.
- `RXDATA` reads the reset output of the reused master.
- `STATUS.busy` reads zero.
- `STATUS.done_sticky` reads zero.
- `VERSION` reads `32'h0001_0000`.
- `spi_ss_n_o` is inactive high and `spi_sclk_o` parks at CPOL.

Transfer behavior:

- A `COMMAND[0]` write launches one byte only when `CONTROL.enable=1` and the master is idle.
- `CONTROL.cpol`, `CONTROL.cpha`, `CLKDIV`, and `TXDATA[7:0]` are sampled by `spi_master_byte` at start.
- `STATUS.busy` follows the reused master.
- `STATUS.done_sticky` sets when `spi_master_byte.done` pulses.
- A new accepted start clears the previous done sticky before the new transfer completes.
- The first wrapper is master-only and does not instantiate unrelated peripherals.

## Decoupling Policy

`axi_spi_core` is independent from GPIO, FND, Timer, Sensor, and I2C. It must not instantiate UVM files, MicroBlaze software, or Vivado block-design constructs.

## Implementation Boundary

This phase is specification-only. The planned RTL path remains:

```text
rtl_work/axi_peripherals/axi_spi_core/hdl/axi_spi_core.v
```

That file was intentionally not created in this unattended run.