# MicroBlaze Integration Plan

## Scope

This plan prepares the future MicroBlaze AXI4-Lite block design. Prompt 19 does not create a Vivado block design, package IP, generate a bitstream, create a Vitis workspace, or write MicroBlaze software.

## Planned Block Design Components

| Component | Planned role |
| --- | --- |
| MicroBlaze | Main processor and AXI master |
| AXI Interconnect or SmartConnect | Connect MicroBlaze AXI master to AXI UART Lite and six custom AXI4-Lite slaves |
| Processor System Reset | Reset generation and synchronization |
| Clocking for Basys3 100 MHz | Shared system clock for MicroBlaze, interconnect, and peripherals unless timing closure later requires division |
| AXI UART Lite | PC console at `0x4060_0000` |
| `axi_gpio_core` | Custom AXI4-Lite slave at `0x44A0_0000` |
| `axi_fnd_core` | Custom AXI4-Lite slave at `0x44A1_0000` |
| `axi_timer_core` | Custom AXI4-Lite slave at `0x44A2_0000` |
| `axi_sensor_core` | Custom AXI4-Lite slave at `0x44A3_0000` |
| `axi_spi_core` | Custom AXI4-Lite slave at `0x44A4_0000` |
| `axi_i2c_core` | Custom AXI4-Lite slave at `0x44A5_0000` |

## Data And Control Flow

```text
PC terminal
  -> AXI UART Lite
  -> MicroBlaze software command parser
  -> AXI Interconnect or SmartConnect
  -> memory-mapped custom AXI4-Lite peripherals
  -> MicroBlaze software formats response
  -> AXI UART Lite
  -> PC terminal
```

Timer and Sensor remain decoupled from FND in hardware. Future MicroBlaze software should read Timer/Sensor registers and write formatted values into `axi_fnd_core` display registers.

## Integration Rules

- Each custom peripheral is packaged as an AXI4-Lite slave.
- MicroBlaze is the main AXI master.
- AXI UART Lite is the PC console and command transport.
- The UART command parser belongs in MicroBlaze software, not RTL.
- UVM remains separate and later; it is not part of the board datapath.
- The Vivado Address Editor assignment must match `docs/specs/AXI_ADDRESS_MAP.md`.

## Suggested Integration Order

1. Package or script local IP packaging for the six custom peripherals.
2. Create a new Vivado block design with MicroBlaze, reset, clocking, AXI UART Lite, interconnect, and packaged custom IP.
3. Assign and verify the documented address map.
4. Export external ports for board IO.
5. Add or verify Basys3 XDC constraints.
6. Generate bitstream.
7. Create MicroBlaze software command parser and smoke-test each peripheral through UART.
8. Record board-demo transcript and update report assets.

## Prompt 21 Implementation Result

The MicroBlaze block-design integration step is complete.

- Project: `vivado/basys3/microblaze_axi_soc/microblaze_axi_soc.xpr`
- Block design: `microblaze_axi_soc_bd`
- Interconnect: SmartConnect
- Validation: `validate_bd_design` passed
- Address map: matches `docs/specs/AXI_ADDRESS_MAP.md`
- External ports: created, exact XDC pin assignment deferred
- Bitstream/software/UVM: not started

Prompt 22 should prepare the Basys3 XDC mapping for the generated external port names.

