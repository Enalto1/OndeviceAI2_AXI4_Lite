# axi_fnd_core Verification Plan

## Scope

This document defines the future verification plan for `axi_fnd_core`. Prompt 4 does not create a testbench, UVM environment, RTL, MicroBlaze software, or Vivado block design.

The first executable verification step should be a focused Vivado 2020.2 behavioral simulation after the RTL wrapper is implemented.

## Verification Goals

The future simulation should prove that:

1. AXI4-Lite register reads and writes match the spec.
2. `fnd_controller.v` is instantiated and driven by wrapper registers.
3. `display_enable` blanks or passes through the final FND outputs.
4. Software-updated timer and sensor values reach the reused controller inputs.
5. The dynamic scan output can be observed over multiple digit-select intervals.
6. Reserved bits, reserved offsets, read-only writes, and WSTRB behavior are correct.

## Directed Vivado Simulation Tests

| Test | Purpose | Expected result |
| --- | --- | --- |
| 1. Reset behavior | Apply reset and read all visible registers. | `CONTROL`, `TIMER_VALUE`, `SENSOR_VALUE` read zero; `VERSION` reads `0x0001_0000`; outputs are blank. |
| 2. CONTROL enable/disable behavior | Toggle `display_enable`. | Disabled outputs are `fnd_com_o=4'b1111`, `fnd_data_o=8'hFF`; enabled outputs follow controller activity. |
| 3. CONTROL mode selection | Write each `main_mode` value. | Controller receives the expected mode input and output pattern changes according to display source. |
| 4. TIMER_VALUE write/read | Write representative msec/sec/min/hour values. | Readback matches meaningful fields; reserved upper bits read zero. |
| 5. SENSOR_VALUE write/read | Write representative distance/humidity/temperature values. | Readback matches meaningful fields; reserved upper bits read zero. |
| 6. FND_OUTPUT readback | Read while disabled and enabled. | Readback reflects final gated output pins, not raw internal controller outputs. |
| 7. Display blanking when disabled | Disable display while controller inputs are nonzero. | Final outputs remain blank. |
| 8. Display active output when enabled | Enable display and run scan long enough to see active digit selects. | `fnd_com_o` toggles through active-low digit enables and `fnd_data_o` is not permanently blank for displayable data. |
| 9. Timer msec/sec display mode | `main_mode=00`, `display_sel=0`. | Representative msec/sec digits appear over scan intervals. |
| 10. Timer min/hour display mode | `main_mode=00` or `01`, `display_sel=1`. | Representative min/hour digits appear over scan intervals. |
| 11. Distance display mode | `main_mode=10`. | Distance digits and `U` marker appear over scan intervals. |
| 12. DHT humidity display mode | `main_mode=11`, `display_sel=0`. | Humidity digits and `H` marker appear over scan intervals. |
| 13. DHT temperature display mode | `main_mode=11`, `display_sel=1`. | Temperature digits and `C` marker appear over scan intervals. |
| 14. WSTRB partial write behavior | Write partial byte lanes to writable registers. | Only strobed byte lanes update; reserved bits remain zero. |
| 15. VERSION read | Read version before and after writes to RO offsets. | Always `0x0001_0000`. |
| 16. Reserved offset behavior | Read/write `0x10`, `0x14`, `0x18`, and `0x20` to `0x3C`. | Reads return zero; writes have no effect. |
| 17. Read-only write protection | Attempt writes to `FND_OUTPUT` and `VERSION`. | Writes have no effect. |

## Scan Timing Guidance

`fnd_controller` scans digits through its internal `clk_div_1khz` and `counter_8` helpers. A future testbench should:

- Run long enough to observe multiple `fnd_com_o` digit selects.
- Check that `fnd_com_o` toggles through active-low enables such as `1110`, `1101`, `1011`, and `0111`.
- Check representative `fnd_data_o` values rather than every scan cycle.
- Keep Vivado xsim runtime reasonable.
- Consider parameter overrides in simulation only if the RTL wrapper spec explicitly allows them later; default behavior should still be covered or justified.

## Expected Observability

The wrapper should expose enough behavior through public outputs and `FND_OUTPUT` readback to verify without reaching into private internal signals. If hierarchical checks are used in a future testbench, keep them secondary to public-interface checks.

## WSTRB Checks

Future simulation should verify at least:

- Byte 0 updates `CONTROL` bits `[3:0]`; upper byte strobes do not create visible reserved bits.
- `TIMER_VALUE` low, middle, and high meaningful bytes can be updated independently.
- `SENSOR_VALUE` partial writes preserve unstrobed fields.
- Reserved bits `[31:24]` of `TIMER_VALUE` and `[31:25]` of `SENSOR_VALUE` read as zero after all writes.

## UVM Status

UVM remains deferred. It should start only after all custom AXI4-Lite peripherals are implemented and each has passed basic Vivado simulation.