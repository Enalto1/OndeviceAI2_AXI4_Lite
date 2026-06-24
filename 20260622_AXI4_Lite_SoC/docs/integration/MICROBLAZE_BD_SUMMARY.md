# MicroBlaze Block Design Summary

## Overview

Prompt 21 created `microblaze_axi_soc_bd` inside the Vivado project `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.xpr`.

The design implements a MicroBlaze AXI4-Lite control system for Basys3 using the packaged local custom IP repository.

```text
clk_100mhz_i, reset_i
  -> Processor System Reset
  -> MicroBlaze + 128 KB local LMB BRAM
  -> SmartConnect
  -> AXI UART Lite at 0x4060_0000
  -> six custom AXI4-Lite peripherals at 0x44A0_0000 through 0x44A5_0000
```

## Key Decisions

- Project part: `xc7a35tcpg236-1`.
- Board part: unavailable; project uses part-only targeting.
- Interconnect: `smartconnect_0`.
- Local memory: LMB BRAM, 128 KB instruction/data range.
- UART: AXI UART Lite with external `uart_rxd_i` and `uart_txd_o` ports.
- Custom IP: all six packaged local IPs instantiated.
- XDC pin mapping: deferred.
- Software/Vitis: deferred.
- Bitstream: not generated.
- UVM: deferred.

## Validation

`validate_bd_design` passed in Vivado 2020.2. The exact address map matches `docs/specs/AXI_ADDRESS_MAP.md`.

