# axi_timer_core Reuse Notes

## Scope

Prompt 7 inspected the timer-related reference RTL files and leaves them unchanged. This document records what should be reused directly and what should remain reference-only for the first `axi_timer_core` wrapper.

Reference directory:

```text
axi_project_unique_sources/sources
```

## Summary

| File | Reuse decision | First wrapper handling |
| --- | --- | --- |
| `stopwatch_datapath.v` | Direct reuse candidate | Instantiate directly if the default tick runtime is acceptable. |
| `watch_datapath.v` | Direct reuse candidate | Instantiate directly if the default tick runtime is acceptable. |
| `watch_fnd_adapter.v` | Direct reuse candidate | Instantiate directly to produce packed watch readback fields. |
| `top_control_unit.v` | Reference-only | Do not instantiate; AXI registers replace the button/switch FSM. |
| `top_stopwatch_watch.v` | Reference-only | Do not wrap; it mixes control, datapaths, muxing, debounce, and FND output. |

## `stopwatch_datapath.v`

### Modules Declared

| Module | Purpose |
| --- | --- |
| `stopwatch_datapath` | Stopwatch datapath top with msec/sec/min/hour counters. |
| `tick_counter_st` | Cascaded up/down counter stage. |
| `tick_gen_100hz_st` | Internal 100 Hz tick generator gated by run/clear. |

### Top Parameters

| Parameter | Default | Notes |
| --- | --- | --- |
| `MSEC_WIDTH` | `7` | Millisecond counter width. |
| `SEC_WIDTH` | `6` | Seconds counter width. |
| `MIN_WIDTH` | `6` | Minutes counter width. |
| `HOUR_WIDTH` | `5` | Hours counter width. |

Helper parameters:

- `tick_counter_st`: `TIMES = 100`, `BIT_WIDTH = 7`
- `tick_gen_100hz_st`: local `F_COUNT = 100_000_000 / 100`

### Top Ports

| Port | Direction | Width | Planned AXI wrapper connection |
| --- | --- | --- | --- |
| `clk` | input | 1 | `s00_axi_aclk` |
| `rst` | input | 1 | `~s00_axi_aresetn` |
| `i_runstop` | input | 1 | `CONTROL[0] stopwatch_run` |
| `i_clear` | input | 1 | One-clock pulse from `COMMAND[0]` |
| `i_mode` | input | 1 | `CONTROL[1] stopwatch_down` |
| `msec` | output | `MSEC_WIDTH`, default 7 | `STOPWATCH_VALUE[6:0]` |
| `sec` | output | `SEC_WIDTH`, default 6 | `STOPWATCH_VALUE[12:7]` |
| `min` | output | `MIN_WIDTH`, default 6 | `STOPWATCH_VALUE[18:13]` |
| `hour` | output | `HOUR_WIDTH`, default 5 | `STOPWATCH_VALUE[23:19]` |

### Reset, Widths, And `$clog2`

- Reset polarity is active high.
- Sequential blocks use `always @(posedge clk, posedge rst)`.
- Output widths are 7-bit msec, 6-bit sec, 6-bit min, and 5-bit hour by default.
- `$clog2` is used in `tick_gen_100hz_st` for the internal tick counter width.

### Reuse Conclusion

`stopwatch_datapath.v` is a direct reuse candidate. The first `axi_timer_core` wrapper should drive `i_runstop`, `i_clear`, and `i_mode` from AXI registers and expose `msec`, `sec`, `min`, and `hour` as read-only fields.

## `watch_datapath.v`

### Modules Declared

| Module | Purpose |
| --- | --- |
| `watch_datapath` | Watch/clock datapath with run mode and set/edit behavior. |
| `tick_counter_wt` | Counter stage with edit-up/edit-down behavior. |
| `tick_gen_100hz_wt` | Internal 100 Hz tick generator gated by run enable. |

### Top Parameters

| Parameter | Default | Notes |
| --- | --- | --- |
| `MSEC_MOD` | `100` | Msec rollover. |
| `MOD_6` | `6` | Tens digit rollover for sec/min. |
| `MOD_10` | `10` | Ones digit rollover for sec/min. |
| `HOUR_MOD` | `24` | Hour rollover. |
| `MSEC_WIDTH` | `$clog2(MSEC_MOD)` | Default 7. |
| `SEC1_WIDTH` | `$clog2(MOD_10)` | Default 4. |
| `SEC10_WIDTH` | `$clog2(MOD_6)` | Default 3. |
| `MIN1_WIDTH` | `$clog2(MOD_10)` | Default 4. |
| `MIN10_WIDTH` | `$clog2(MOD_6)` | Default 3. |
| `HOUR_WIDTH` | `$clog2(HOUR_MOD)` | Default 5. |

Helper parameters:

- `tick_counter_wt`: `TIMES = 100`, `BIT_WIDTH = 7`
- `tick_gen_100hz_wt`: local `F_COUNT = 100_000_000 / 100`

### Top Ports

| Port | Direction | Width | Planned AXI wrapper connection |
| --- | --- | --- | --- |
| `clk` | input | 1 | `s00_axi_aclk` |
| `rst` | input | 1 | `~s00_axi_aresetn` |
| `i_set_mode` | input | 1 | `CONTROL[8] watch_set_mode` |
| `i_digit_sel` | input | 1 | `CONTROL[11] watch_digit_sel` |
| `i_time_sel` | input | 2 | `CONTROL[10:9] watch_time_sel` |
| `i_edit_cmd` | input | 2 | One-clock gated command from `COMMAND[8]` or `COMMAND[9]` |
| `msec` | output | `MSEC_WIDTH`, default 7 | `WATCH_RAW_DIGITS[6:0]` and adapter input |
| `sec_d1` | output | `SEC1_WIDTH`, default 4 | `WATCH_RAW_DIGITS[10:7]` and adapter input |
| `sec_d10` | output | `SEC10_WIDTH`, default 3 | `WATCH_RAW_DIGITS[13:11]` and adapter input |
| `min_d1` | output | `MIN1_WIDTH`, default 4 | `WATCH_RAW_DIGITS[17:14]` and adapter input |
| `min_d10` | output | `MIN10_WIDTH`, default 3 | `WATCH_RAW_DIGITS[20:18]` and adapter input |
| `hour` | output | `HOUR_WIDTH`, default 5 | `WATCH_RAW_DIGITS[25:21]` and adapter input |

### Reset, Widths, And `$clog2`

- Reset polarity is active high.
- Sequential blocks use `always @(posedge clk or posedge rst)` or `always @(posedge clk, posedge rst)`.
- `$clog2` is used in width parameters and in `tick_gen_100hz_wt`.
- Default output widths are 7-bit msec, 4-bit ones digits, 3-bit tens digits, and 5-bit hour.

### Reuse Conclusion

`watch_datapath.v` is a direct reuse candidate. The first wrapper should drive set mode, target selection, and gated one-clock edit commands from AXI registers. Edit pulses should be blocked by the wrapper unless `watch_set_mode = 1`.

## `watch_fnd_adapter.v`

### Modules Declared

| Module | Purpose |
| --- | --- |
| `watch_fnd_adapter` | Converts split watch digit fields into packed hour/min/sec/msec fields. |

### Parameters

No parameters.

### Ports

| Port | Direction | Width | Planned AXI wrapper connection |
| --- | --- | --- | --- |
| `i_hour` | input | 5 | `watch_datapath.hour` |
| `i_min_d10` | input | 3 | `watch_datapath.min_d10` |
| `i_min_d1` | input | 4 | `watch_datapath.min_d1` |
| `i_sec_d10` | input | 3 | `watch_datapath.sec_d10` |
| `i_sec_d1` | input | 4 | `watch_datapath.sec_d1` |
| `i_msec` | input | 7 | `watch_datapath.msec` |
| `hour` | output | 5 | `WATCH_VALUE[23:19]` |
| `min` | output | 6 | `WATCH_VALUE[18:13]` |
| `sec` | output | 6 | `WATCH_VALUE[12:7]` |
| `msec` | output | 7 | `WATCH_VALUE[6:0]` |

### Reset, Widths, And `$clog2`

- Combinational adapter; no clock or reset.
- Does not use `$clog2`.
- Converts tens/ones digits by multiplying tens digit by 10 and adding ones digit.

### Reuse Conclusion

`watch_fnd_adapter.v` is reusable as-is and should be directly instantiated by the Timer wrapper for packed watch readback. It does not imply a direct connection to `axi_fnd_core`; it simply reuses the legacy conversion logic.

## `top_control_unit.v`

### Modules Declared

| Module | Purpose |
| --- | --- |
| `top_control_unit` | Legacy switch/button FSM that generates stopwatch/watch control signals and LED indicators. |

### Parameters

No parameters.

### Ports

| Port | Direction | Width | Notes |
| --- | --- | --- | --- |
| `clk` | input | 1 | Legacy clock. |
| `rst` | input | 1 | Active-high reset. |
| `btnR`, `btnL`, `btnU`, `btnD` | input | 1 each | Legacy debounced button pulses. |
| `sw` | input | `[2:1]` | Legacy mode switches. |
| `o_mode` | output | 1 | Stopwatch up/down mode toggle in old behavior. |
| `o_clear` | output reg | 1 | Stopwatch clear pulse/state output. |
| `o_runstop` | output reg | 1 | Stopwatch run/stop level. |
| `o_set_mode` | output reg | 1 | Watch set/run mode. |
| `o_timesel` | output reg | 2 | Watch edit target group. |
| `o_digitsel` | output reg | 1 | Watch digit select. |
| `o_edit` | output reg | 2 | Watch edit command. |
| `led` | output | 7 | Legacy UI status LEDs. |

### Reset, Widths, And `$clog2`

- Reset polarity is active high.
- Sequential block uses `always @(posedge clk or posedge rst)`.
- No `$clog2` use.
- Declares no helper modules in the same file.

### Reuse Conclusion

`top_control_unit.v` is reference-only for the first `axi_timer_core`. It documents the old button/switch FSM behavior, but AXI registers should replace that FSM. Do not directly instantiate it in the first wrapper.

## `top_stopwatch_watch.v`

### Modules Declared

| Module | Purpose |
| --- | --- |
| `top_stopwatch_watch` | Legacy integrated stopwatch/watch/FND top. |

### Parameters

| Parameter | Default |
| --- | --- |
| `MSEC_WIDTH` | `7` |
| `SEC_WIDTH` | `6` |
| `MIN_WIDTH` | `6` |
| `HOUR_WIDTH` | `5` |

### Ports

| Port | Direction | Width | Notes |
| --- | --- | --- | --- |
| `clk` | input | 1 | Legacy clock. |
| `rst` | input | 1 | Active-high reset distributed to child modules. |
| `btnR`, `btnL`, `btnU`, `btuD` | input | 1 each | Legacy board buttons; `btuD` spelling is preserved from source. |
| `sw` | input | 3 | Legacy display/mode/set switches. |
| `fnd_com` | output | 4 | Legacy FND output. |
| `fnd_data` | output | 8 | Legacy FND output. |
| `led` | output | 8 | Legacy status LEDs. |

### Instantiated Legacy Blocks

This file instantiates:

- `button_debounce`
- `top_control_unit`
- `stopwatch_datapath`
- `watch_datapath`
- `watch_fnd_adapter`
- `mux_2x1_nbit`
- `fnd_controller`

It declares no helper modules in the same file and does not use `$clog2`.

### Reuse Conclusion

`top_stopwatch_watch.v` is reference-only. It should not be wrapped directly because it combines button debounce, a control FSM, stopwatch/watch datapaths, muxing, LEDs, and direct FND output. The new design should keep Timer independent from FND. MicroBlaze software will later read Timer registers and write display values to `axi_fnd_core`.

## Simulation Runtime Risk

`stopwatch_datapath.v` and `watch_datapath.v` use internal 100 Hz generators with `F_COUNT = 100_000_000 / 100`. At 100 MHz, each timer tick takes about 1,000,000 cycles.

For first RTL implementation, prefer direct reuse as-is. During future simulation, if runtime becomes unreasonable, create clearly named adapted copies under `rtl_work/legacy_adapted/` that expose a tick-count parameter. The original reference files must remain unchanged.
## Prompt 8 Implementation Decision

Prompt 8 implemented the AXI4-Lite Timer wrapper at:

```text
rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v
```

Implementation facts:

- The wrapper instantiates `stopwatch_datapath` as `u_stopwatch_datapath`.
- The wrapper instantiates `watch_datapath` as `u_watch_datapath`.
- The wrapper instantiates `watch_fnd_adapter` as `u_watch_fnd_adapter`.
- `clk` is driven by `s00_axi_aclk`.
- `rst` is driven by `~s00_axi_aresetn`.
- `CONTROL[0]` drives stopwatch run/stop.
- `CONTROL[1]` drives stopwatch up/down mode.
- `COMMAND[0]` generates a one-clock stopwatch clear pulse.
- `CONTROL[8]`, `CONTROL[10:9]`, and `CONTROL[11]` drive watch set mode and target selection.
- `COMMAND[8]` and `COMMAND[9]` generate one-clock watch edit commands only when `CONTROL[8] = 1`.
- Edit-up has priority over edit-down when both command bits are written together.
- `watch_fnd_adapter` converts raw split watch digits into packed `WATCH_VALUE` readback fields.
- No adapted Timer copy was created.
- The reference timer RTL remains unchanged.
- `top_control_unit`, `top_stopwatch_watch`, `fnd_controller`, and `axi_fnd_core` are not instantiated by the Timer wrapper.

Timer Vivado simulation remains pending for the next step.