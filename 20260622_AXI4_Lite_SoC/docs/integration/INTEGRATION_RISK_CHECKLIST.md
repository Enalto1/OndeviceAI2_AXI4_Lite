# Integration Risk Checklist

| Risk | Why it matters | Mitigation |
| --- | --- | --- |
| Mixed Verilog/SystemVerilog packaging | SPI and I2C depend on `.sv` master cores while wrappers are `.v`. | Set file type explicitly during IP packaging and verify packaged elaboration. |
| DHT11 inout port | Single-wire bus requires correct top-level tri-state behavior. | Verify generated top-level port and XDC after block design creation. |
| I2C inout/open-drain ports | SCL/SDA require pull-ups and correct high-Z behavior. | Plan external pull-ups and verify bus idle level on board. |
| SPI PMOD pin planning | Wrong SCLK/MOSI/MISO/SS assignment can silently break transfers. | Create a PMOD-specific XDC review before bitstream generation. |
| AXI address drift | Vivado Address Editor may auto-assign different ranges. | Match `docs/specs/AXI_ADDRESS_MAP.md` and verify generated BSP constants. |
| Reset polarity mismatch | MicroBlaze reset blocks and custom wrappers must agree on active-low reset. | Check `s00_axi_aresetn` connections during block design validation. |
| MicroBlaze software polling timeouts | Busy peripherals or missing sensors can hang software. | Use bounded polling loops and return clear UART errors. |
| DHT11 timing limitations | DHT11 protocol timing is slow and board/environment dependent. | Treat current sim as sanity coverage; add board test and later deeper verification. |
| FND software update responsibility | FND does not pull Timer/Sensor values in hardware. | Software must explicitly bridge Timer/Sensor readings to FND registers. |
| Build-time integration ordering | Packaging, block design, XDC, bitstream, BSP, and software depend on each other. | Follow the staged integration order in `MICROBLAZE_INTEGRATION_PLAN.md`. |
| Generated Vivado work clutter | Focused simulations create `vivado_work` directories. | Keep generated simulation work under `sim/vivado/*/vivado_work` and do not treat it as source IP. |

## Pre-Bitstream Gate

Before bitstream generation, confirm:

- All six local IP packages elaborate.
- Address Editor matches the final address map.
- External ports are named consistently with the XDC.
- Inout ports are correctly represented at the top level.
- AXI UART Lite is present and accessible to MicroBlaze software.
- The full focused-simulation regression still passes.
