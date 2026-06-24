# axi_timer_core Verification Plan

## Scope

This is the future verification plan for `axi_timer_core`. Prompt 7 does not create a testbench, run Vivado simulation, create UVM, create MicroBlaze software, or implement RTL.

The first verification milestone should be a focused Vivado 2020.2/xsim behavioral simulation after the RTL wrapper exists.

## Verification Goals

- Confirm the AXI register map matches `docs/specs/axi_timer_core_SPEC.md`.
- Confirm command registers generate one-clock pulses.
- Confirm read-only and reserved registers ignore writes.
- Confirm `stopwatch_datapath`, `watch_datapath`, and `watch_fnd_adapter` are connected correctly.
- Confirm Timer remains decoupled from FND outputs and FND RTL.

## Directed Vivado Simulation Checklist

| ID | Test | Expected result |
| --- | --- | --- |
| 1 | Reset behavior | `CONTROL`, timer values, raw digits, and status reset to zero; `VERSION` reads `32'h0001_0000`. |
| 2 | `CONTROL` write/read | Meaningful bits `[1:0]` and `[11:8]` store and read back; reserved bits read zero. |
| 3 | `COMMAND` read-zero behavior | Writes do not store state; reads always return zero. |
| 4 | Stopwatch run/stop control | `CONTROL[0]` enables and disables stopwatch ticking through `i_runstop`. |
| 5 | Stopwatch clear pulse | `COMMAND[0]` creates one clock of `i_clear` and clears stopwatch counters. |
| 6 | Stopwatch up-count tick behavior | With run enabled and down disabled, `STOPWATCH_VALUE` advances after 100 Hz ticks. |
| 7 | Stopwatch down-count behavior if practical | With down enabled, counter wrap/decrement behavior follows reused datapath behavior. |
| 8 | Watch set mode control | `CONTROL[8]` drives watch run/edit mode and stops normal watch ticking in set mode. |
| 9 | Watch target selection | `CONTROL[10:9]` and `CONTROL[11]` select hour/min/sec tens or ones edit targets. |
| 10 | Watch edit up | `COMMAND[8]` produces one edit-up pulse when set mode is active. |
| 11 | Watch edit down | `COMMAND[9]` produces one edit-down pulse when set mode is active. |
| 12 | `WATCH_VALUE` adapter output | Packed hour/min/sec/msec values match `watch_fnd_adapter` conversion. |
| 13 | `WATCH_RAW_DIGITS` readback | Raw split digit fields match `watch_datapath` outputs. |
| 14 | `STATUS` readback | Status mirrors meaningful `CONTROL` state. |
| 15 | `VERSION` read | Reads fixed `32'h0001_0000`; writes have no effect. |
| 16 | Reserved offset read/write behavior | Reserved offsets read zero and ignore writes. |
| 17 | Read-only write protection | Writes to `STOPWATCH_VALUE`, `WATCH_VALUE`, `WATCH_RAW_DIGITS`, `STATUS`, and `VERSION` do not alter values. |
| 18 | WSTRB partial write behavior | `CONTROL` and `COMMAND` honor byte strobes exactly as specified. |
| 19 | Edit pulses ignored when `watch_set_mode = 0` | Watch edit commands do not change watch counters in run mode. |
| 20 | Timer remains decoupled from FND | Simulation does not require FND outputs or instantiate FND RTL in the Timer wrapper. |

## Tick Runtime Strategy

The reused stopwatch and watch datapaths contain default 100 Hz tick generators:

```text
F_COUNT = 100_000_000 / 100
```

At 100 MHz, one tick requires about 1,000,000 cycles. The future simulation should choose one of these documented strategies:

1. Run only a small number of full tick intervals.
2. If runtime is unreasonable, create clearly named adapted copies under `rtl_work/legacy_adapted/` that expose a simulation tick parameter.
3. Keep original reference RTL files unchanged.

## Suggested Testbench Structure

Future files, not created in Prompt 7:

```text
sim/vivado/axi_timer_core/tb_axi_timer_core.sv
sim/vivado/axi_timer_core/run_axi_timer_core_sim.tcl
```

The testbench should be directed, lightweight, and similar in style to the passing GPIO and FND Vivado simulations. It should include AXI write/read tasks, explicit checks, a result file, and a final pass marker.

## Expected Future Result File

Recommended future result file:

```text
sim/vivado/axi_timer_core/axi_timer_core_sim_result.txt
```

Recommended passing marker:

```text
[TB PASS] axi_timer_core directed tests passed
```

## UVM Policy

UVM remains deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.