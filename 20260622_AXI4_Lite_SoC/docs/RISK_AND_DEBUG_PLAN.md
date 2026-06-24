# Risk And Debug Plan

This plan captures expected risks before any AXI wrapper implementation starts. The mitigation strategy is incremental: one peripheral, one wrapper, one simulation, one UVM environment, one board demo at a time.

## Technical Risk Table

| Risk area | Risk | Impact | Mitigation |
| --- | --- | --- | --- |
| Vivado 2020.2 compatibility | Later scripts or IP options may accidentally use newer Vivado features. | Project may fail to build on the required tool version. | Keep scripts plain Tcl, avoid newer IP options, and test with Vivado 2020.2 during each phase. |
| AXI4-Lite template modification | Changing handshake logic can break AXI read/write behavior. | MicroBlaze reads/writes may hang or return wrong data. | Preserve Xilinx template handshake logic; only modify register map, write strobes, read mux, pulse generation, and core connections. |
| Pulse vs level control | Start/clear/cmd bits may remain asserted instead of generating one-clock pulses. | Reused cores may repeat actions or lock in active states. | Define write-one-pulse bits in specs and verify pulses in simulation and WaveDrom. |
| Reset polarity | AXI template uses active-low `s00_axi_aresetn`; legacy RTL uses active-high `rst`. | Cores may be held in reset or fail to reset. | Convert wrapper reset with `wire rst = ~s00_axi_aresetn;` and document reset mapping. |
| Mixed Verilog/SystemVerilog | SPI and I2C cores are `.sv`, while AXI templates may be Verilog. | Synthesis/simulation compile order or language settings can fail. | Keep file extensions unchanged, compile SV as SystemVerilog, verify Vivado 2020.2 support before packaging SPI/I2C. |
| Reference top reuse confusion | Legacy `TOP.v` and `top_stopwatch_watch.v` are tempting to wrap directly. | New SoC could inherit old UART/ASCII control path and conflict with MicroBlaze control. | Use those files only as references; instantiate leaf cores in new AXI wrappers. |
| FND behavior drift | Rewriting display logic would break known working display behavior. | Board demo and report traceability suffer. | Reuse `fnd_controller.v` directly and drive it from AXI register values. |
| DHT11 timing | DHT11 single-wire protocol is timing-sensitive and has long transaction timing. | Sensor reads may fail on board despite simple simulation passing. | Preserve existing controller, add wrapper status carefully, validate with long-enough simulation and board debug prints. |
| SR04 echo timing | Echo pulse width depends on external sensor timing and physical environment. | Distance readback may be unstable or timeout-prone. | Add clear software-visible status in wrapper, simulate representative echo pulses, and test with known distances. |
| SPI CPOL/CPHA | Incorrect edge handling or software configuration can corrupt transfers. | Loopback or external SPI device bring-up fails. | Begin with `spi_master_byte` only, simulate all CPOL/CPHA modes, then test with a simple known slave/loopback. |
| I2C open-drain handling | SDA/SCL must be modeled as drive-low/release, not push-pull high. | Bus contention or no ACK on hardware. | Keep `scl_drive_low`/`sda_drive_low` semantics, implement top-level tri-state/open-drain constraints carefully, simulate ACK/NACK. |
| UVM complexity | Building full-system UVM too early would be large and fragile. | Verification effort stalls before peripheral confidence is built. | Follow standalone peripheral UVM environments first, starting with GPIO. |
| MicroBlaze software parsing | UART command parser in C can drift from register specs. | Terminal commands may write wrong offsets or stale bit definitions. | Maintain command tables from spec docs and update traceability matrix after each spec. |
| Address map growth | Multiple peripherals may collide or use inconsistent base addresses. | Software and block design integration become error-prone. | Create an AXI address map doc before Vivado block design integration. |
| Board constraints | Basys3 pin constraints for FND, DHT11, SR04, SPI, and I2C may conflict. | Bitstream may fail or hardware may not respond. | Maintain board-specific XDC notes and verify one peripheral at a time. |

## Debug Strategy

1. Start with `axi_gpio_core` because it has the lowest protocol and timing risk.
2. Verify AXI register read/write behavior in simple simulation before connecting reused leaf logic heavily.
3. For each wrapper, add a minimal smoke test that checks reset values, writes, reads, and pulse generation.
4. Use WaveDrom timing assets to document expected write/read and pulse behavior before UVM work.
5. Add UVM only after simple simulation passes, using the RAM split reference structure.
6. On board, use AXI UART Lite software commands to read registers and print observed status.
7. Use LEDs and FND as visible debug outputs only after basic AXI read/write is stable.
8. For sensor/SPI/I2C, first simulate protocol-level signals, then test with simple known hardware conditions.
9. If Vivado synthesis fails on a reused `.sv` file, document the exact error before deciding whether an adapted copy is needed.

## Peripheral-Specific Debug Notes

| Peripheral | First checks | Later checks |
| --- | --- | --- |
| GPIO | Reset LED register, switch readback, button debounce, optional edge status. | Board button bounce behavior and UART command mapping. |
| FND | Register-written values appear on `fnd_controller` inputs; scan outputs toggle. | Basys3 FND readability and mode selection. |
| Timer | Run/clear/mode controls generate correct internal levels/pulses; counters increment. | Watch edit mode, clear behavior, FND handoff. |
| Sensor | DHT11/SR04 start pulses are one-clock; result registers update only on valid/done. | Real sensor timing, timeout/error behavior. |
| SPI | Start pulse launches one byte; `busy` and `done` sequence is correct; RX data captured. | External device or loopback transfer across CPOL/CPHA settings. |
| I2C | Command ready/done/busy/nack status; SDA/SCL drive-low behavior. | ACK/NACK, repeated starts, read byte with master ACK/NACK. |

## Known Unclear Assumptions

- Final AXI address map is not defined in Step 0.
- Final register maps are not defined in Step 0.
- Basys3 XDC pin mapping is not audited in Step 0.
- Vivado 2020.2 synthesis of the SPI/I2C SystemVerilog cores still needs tool verification.
- Sensor timeout/error policy still needs specification.
- Optional Zybo Z7-20 board-to-board SPI/I2C usage is future work.
