# axi_spi_core Verification Plan

## Scope

This is the future verification plan for `axi_spi_core`. Unattended Phase D does not create a testbench, run Vivado simulation, create UVM, create MicroBlaze software, or implement RTL.

The first verification milestone should be a focused Vivado 2020.2/xsim behavioral simulation after the RTL wrapper exists.

## Verification Goals

- Confirm the AXI register map matches `docs/specs/axi_spi_core_SPEC.md`.
- Confirm command registers generate one-clock start pulses.
- Confirm `spi_master_byte` is connected correctly.
- Confirm CPOL, CPHA, clock divider, TX data, RX data, busy, and done behavior.
- Confirm read-only and reserved registers ignore writes.
- Confirm SPI remains independent from GPIO, FND, Timer, Sensor, I2C, UVM, MicroBlaze software, and block design files.

## Directed Vivado Simulation Checklist

| ID | Test | Expected result |
| --- | --- | --- |
| 1 | Reset behavior | `CONTROL=0`, `CLKDIV=1`, `TXDATA=0`, `STATUS.busy=0`, `STATUS.done_sticky=0`, `VERSION=32'h0001_0000`. |
| 2 | `CONTROL` write/read | Meaningful bits `[2:0]` store and read back; reserved bits read zero. |
| 3 | `CLKDIV` write/read | Bits `[15:0]` store and read back with reserved bits zero. |
| 4 | `TXDATA` write/read | Bits `[7:0]` store and read back with reserved bits zero. |
| 5 | `COMMAND` reads zero | Writes do not store state; reads always return zero. |
| 6 | Start pulse gated by enable | `COMMAND[0]` launches only when `CONTROL[0]=1`. |
| 7 | Start ignored while busy | A second command during an active transfer does not corrupt the current transfer. |
| 8 | SPI mode 0 transfer | `ss_n`, `sclk`, `mosi`, `miso`, `busy`, `done`, and `rx_data` match the reused master for CPOL=0/CPHA=0. |
| 9 | CPOL behavior | Idle SCLK follows selected CPOL. |
| 10 | CPHA behavior if practical | Mode 1/2/3 edge timing follows `spi_master_byte`. |
| 11 | RXDATA readback | Last received byte is visible in `RXDATA[7:0]`. |
| 12 | STATUS readback | Busy, done sticky, and control mirrors read as specified. |
| 13 | Done sticky clear policy | New accepted start clears the previous done sticky. |
| 14 | VERSION read and RO protection | `VERSION` reads fixed value and ignores writes. |
| 15 | Reserved offsets | Reserved offsets read zero and ignore writes. |
| 16 | WSTRB behavior | `CONTROL`, `CLKDIV`, `TXDATA`, and `COMMAND` honor byte strobes exactly. |
| 17 | SPI independence compile check | The simulation compiles no GPIO, FND, Timer, Sensor, I2C, UVM, MicroBlaze software, or block-design files. |

## Suggested Simulation Structure

Future files, not created in this phase:

```text
sim/vivado/axi_spi_core/tb_axi_spi_core.sv
sim/vivado/axi_spi_core/run_axi_spi_core_sim.tcl
```

The testbench should be directed and similar in style to the passing GPIO, FND, Timer, and Sensor simulations. A simple MISO stimulus or optional `spi_slave_byte` verification companion can be used, but the first AXI wrapper should remain master-focused unless a later prompt explicitly broadens the scope.

## Expected Future Result File

Recommended future result file:

```text
sim/vivado/axi_spi_core/axi_spi_core_sim_result.txt
```

Recommended passing marker:

```text
[TB PASS] axi_spi_core directed tests passed
```

## UVM Policy

UVM remains deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.