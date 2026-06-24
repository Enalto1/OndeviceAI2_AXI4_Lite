# axi_timer_core Specification

## Scope

`axi_timer_core` is the AXI4-Lite stopwatch/watch peripheral for the Basys3-first MicroBlaze SoC.

This Prompt 7 specification defines the register map, reset behavior, source reuse policy, software-visible behavior, and future verification expectations only. Prompt 7 does not implement RTL, create an AXI wrapper, create a Vivado simulation testbench, run simulation, create UVM, create MicroBlaze software, or create a Vivado block design.

## Address Assignment

| Item | Value |
| --- | --- |
| Peripheral | `axi_timer_core` |
| Base address | `0x44A2_0000` |
| High address | `0x44A2_FFFF` |
| Range | 64 KB |
| Local AXI address width | 6 bits |
| Local register offsets | `0x00` to `0x3C` |
| AXI data width | 32 bits |
| Vivado target assumption | Vivado 2020.2 |

## Future Wrapper Interface Assumptions

The future wrapper should follow the Vivado 2020.2 Xilinx AXI4-Lite slave template style already used for the implemented GPIO and FND wrappers.

| Signal or parameter | Requirement |
| --- | --- |
| AXI clock | `s00_axi_aclk` |
| AXI reset | `s00_axi_aresetn`, active low |
| Internal reset | `rst = ~s00_axi_aresetn`, active high |
| AXI response | `OKAY` for implemented and reserved accesses |
| Local register decode | 32-bit aligned offsets inside the 6-bit local window |

## External Non-AXI Ports

The first `axi_timer_core` version should not require external non-AXI board pins.

| Port | Direction | Width | Description |
| --- | --- | --- | --- |
| none | n/a | n/a | All control and observation happens through AXI4-Lite registers. |

Optional debug pins may be added later only if explicitly requested.

## Reference RTL Sources

The timer wrapper should use the reference RTL sources below without modifying them:

```text
axi_project_unique_sources/sources/stopwatch_datapath.v
axi_project_unique_sources/sources/watch_datapath.v
axi_project_unique_sources/sources/watch_fnd_adapter.v
```

Reference-only legacy control and integration files:

```text
axi_project_unique_sources/sources/top_control_unit.v
axi_project_unique_sources/sources/top_stopwatch_watch.v
```

The detailed inspection is captured in `docs/rtl_views/axi_timer_core_reuse_notes.md`.

## Timer And FND Decoupling Policy

The first `axi_timer_core` must remain decoupled from `axi_fnd_core`.

- `axi_timer_core` does not directly drive `fnd_com` or `fnd_data`.
- `axi_timer_core` does not instantiate `fnd_controller`.
- `axi_timer_core` does not instantiate `axi_fnd_core`.
- MicroBlaze software will later read timer values from `axi_timer_core` and write display values into `axi_fnd_core`.

This keeps each custom peripheral independently verifiable.

## Register Map Summary

| Offset | Absolute address | Register | Access | Reset | Description |
| --- | --- | --- | --- | --- | --- |
| `0x00` | `0x44A2_0000` | `CONTROL` | RW | `0x0000_0000` | Stopwatch run/down controls and watch edit target controls. |
| `0x04` | `0x44A2_0004` | `COMMAND` | WO | reads `0x0000_0000` | Write-one command pulses for stopwatch clear and watch edit. |
| `0x08` | `0x44A2_0008` | `STOPWATCH_VALUE` | RO | dynamic | Packed stopwatch msec/sec/min/hour. |
| `0x0C` | `0x44A2_000C` | `WATCH_VALUE` | RO | dynamic | Packed watch msec/sec/min/hour from `watch_fnd_adapter`. |
| `0x10` | `0x44A2_0010` | `WATCH_RAW_DIGITS` | RO | dynamic | Raw split watch digit fields. |
| `0x14` | `0x44A2_0014` | `STATUS` | RO | dynamic | Readback of meaningful control state. |
| `0x18` | `0x44A2_0018` | Reserved | Reserved | `0x0000_0000` | Reads zero, writes ignored. |
| `0x1C` | `0x44A2_001C` | `VERSION` | RO | `0x0001_0000` | Fixed peripheral version. |
| `0x20` to `0x3C` | `0x44A2_0020` to `0x44A2_003C` | Reserved | Reserved | `0x0000_0000` | Reads zero, writes ignored. |

## Register Details

### CONTROL - Offset `0x00`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[0]` | `stopwatch_run` | RW | `0` | Drives `stopwatch_datapath.i_runstop`. |
| `[1]` | `stopwatch_down` | RW | `0` | Drives `stopwatch_datapath.i_mode`; `0` counts up, `1` counts down. |
| `[7:2]` | reserved | RO | `0` | Reads as zero. Writes have no effect. |
| `[8]` | `watch_set_mode` | RW | `0` | Drives `watch_datapath.i_set_mode`; `0` run mode, `1` set/edit mode. |
| `[10:9]` | `watch_time_sel` | RW | `2'b00` | `00` hour, `01` minute, `10` second, `11` reserved/no-op target. |
| `[11]` | `watch_digit_sel` | RW | `0` | `0` tens digit, `1` ones digit for minute/second editing; ignored for hour editing. |
| `[31:12]` | reserved | RO | `0` | Reads as zero. Writes have no effect. |

`CONTROL` should store only meaningful bits `[11:8]` and `[1:0]`. Reserved bits always read as zero.

### COMMAND - Offset `0x04`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[0]` | `stopwatch_clear` | WO | n/a | Write `1` creates a one-clock pulse to `stopwatch_datapath.i_clear`. |
| `[7:1]` | reserved | WO | n/a | Writes have no effect. |
| `[8]` | `watch_edit_up` | WO | n/a | Write `1` requests a one-clock watch edit-up pulse. |
| `[9]` | `watch_edit_down` | WO | n/a | Write `1` requests a one-clock watch edit-down pulse. |
| `[31:10]` | reserved | WO | n/a | Writes have no effect. |

`COMMAND` has no stored state and always reads as zero.

Command pulse requirements:

- `stopwatch_clear` creates a one-clock `i_clear` pulse.
- `watch_edit_up` creates a one-clock `i_edit_cmd = 2'b01` pulse when `watch_set_mode = 1`.
- `watch_edit_down` creates a one-clock `i_edit_cmd = 2'b10` pulse when `watch_set_mode = 1`.
- Edit pulses are ignored when `watch_set_mode = 0`.
- If `watch_edit_up` and `watch_edit_down` are written as `1` in the same command, `watch_edit_up` has priority.
- Writes of zero have no effect.

### STOPWATCH_VALUE - Offset `0x08`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[6:0]` | `stopwatch_msec` | RO | `stopwatch_datapath.msec`. |
| `[12:7]` | `stopwatch_sec` | RO | `stopwatch_datapath.sec`. |
| `[18:13]` | `stopwatch_min` | RO | `stopwatch_datapath.min`. |
| `[23:19]` | `stopwatch_hour` | RO | `stopwatch_datapath.hour`. |
| `[31:24]` | reserved | RO | Reads as zero. |

Writes to `STOPWATCH_VALUE` have no effect.

### WATCH_VALUE - Offset `0x0C`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[6:0]` | `watch_msec` | RO | Packed watch msec from `watch_fnd_adapter.msec`. |
| `[12:7]` | `watch_sec` | RO | Packed watch seconds from `watch_fnd_adapter.sec`. |
| `[18:13]` | `watch_min` | RO | Packed watch minutes from `watch_fnd_adapter.min`. |
| `[23:19]` | `watch_hour` | RO | Packed watch hour from `watch_fnd_adapter.hour`. |
| `[31:24]` | reserved | RO | Reads as zero. |

Writes to `WATCH_VALUE` have no effect.

### WATCH_RAW_DIGITS - Offset `0x10`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[6:0]` | `watch_msec_raw` | RO | Raw `watch_datapath.msec`. |
| `[10:7]` | `watch_sec_d1` | RO | Raw ones digit from `watch_datapath.sec_d1`. |
| `[13:11]` | `watch_sec_d10` | RO | Raw tens digit from `watch_datapath.sec_d10`. |
| `[17:14]` | `watch_min_d1` | RO | Raw ones digit from `watch_datapath.min_d1`. |
| `[20:18]` | `watch_min_d10` | RO | Raw tens digit from `watch_datapath.min_d10`. |
| `[25:21]` | `watch_hour_raw` | RO | Raw hour from `watch_datapath.hour`. |
| `[31:26]` | reserved | RO | Reads as zero. |

Writes to `WATCH_RAW_DIGITS` have no effect.

### STATUS - Offset `0x14`

| Bits | Name | Access | Description |
| --- | --- | --- | --- |
| `[0]` | `stopwatch_run` | RO | Mirrors `CONTROL[0]`. |
| `[1]` | `stopwatch_down` | RO | Mirrors `CONTROL[1]`. |
| `[7:2]` | reserved | RO | Reads as zero. |
| `[8]` | `watch_set_mode` | RO | Mirrors `CONTROL[8]`. |
| `[10:9]` | `watch_time_sel` | RO | Mirrors `CONTROL[10:9]`. |
| `[11]` | `watch_digit_sel` | RO | Mirrors `CONTROL[11]`. |
| `[31:12]` | reserved | RO | Reads as zero. |

Writes to `STATUS` have no effect.

### VERSION - Offset `0x1C`

| Bits | Name | Access | Reset | Description |
| --- | --- | --- | --- | --- |
| `[31:0]` | `version` | RO | `0x0001_0000` | Fixed first-version identifier. |

Writes to `VERSION` have no effect.

## WSTRB Policy

Writable registers must respect AXI `WSTRB`.

`CONTROL`:

- `WSTRB[0]` can update bits `[7:0]`, but only bits `[1:0]` are meaningful.
- `WSTRB[1]` can update bits `[15:8]`, but only bits `[11:8]` are meaningful.
- `WSTRB[2]` and `WSTRB[3]` have no visible effect.
- Reserved bits always read as zero.

`COMMAND`:

- `WSTRB[0]` can trigger bit `[0] stopwatch_clear`.
- `WSTRB[1]` can trigger bits `[8] watch_edit_up` and `[9] watch_edit_down`.
- `WSTRB[2]` and `WSTRB[3]` have no visible effect.
- `COMMAND` reads as zero.
- Command bits generate one-clock internal pulses only.

Read-only and reserved registers ignore writes.

## Reset And Behavioral Requirements

On reset:

- `CONTROL` meaningful bits reset to zero.
- `COMMAND` has no stored state and reads zero.
- `stopwatch_datapath` resets to zero.
- `watch_datapath` resets to zero.
- `STOPWATCH_VALUE` reads zero.
- `WATCH_VALUE` reads zero.
- `WATCH_RAW_DIGITS` reads zero.
- `STATUS` reflects the reset control state.
- `VERSION` reads `32'h0001_0000`.

Stopwatch behavior:

- `stopwatch_run` drives `stopwatch_datapath.i_runstop`.
- `stopwatch_down` drives `stopwatch_datapath.i_mode`.
- `stopwatch_clear` creates a one-clock `stopwatch_datapath.i_clear` pulse.
- Stopwatch counting uses the reused internal 100 Hz tick generator.
- No wrapper range checking is needed because the reused counters define ranges.

Watch behavior:

- `watch_set_mode` drives `watch_datapath.i_set_mode`.
- `watch_time_sel` drives `watch_datapath.i_time_sel`.
- `watch_digit_sel` drives `watch_datapath.i_digit_sel`.
- Watch edit command pulses drive `watch_datapath.i_edit_cmd` as `2'b01` for up, `2'b10` for down, and `2'b00` otherwise.
- Edit pulses are gated so they only reach `watch_datapath` when `watch_set_mode = 1`.
- `watch_fnd_adapter` converts split watch digits into the packed `WATCH_VALUE` fields.

## Simulation Runtime Note

`stopwatch_datapath.v` and `watch_datapath.v` include internal 100 Hz tick generators with default:

```verilog
F_COUNT = 100_000_000 / 100
```

At a 100 MHz simulation clock, one timer tick requires about 1,000,000 clock cycles.

For the first RTL implementation, prefer reusing the reference datapaths as-is. For the later Vivado simulation step, choose and document one of these strategies:

1. Run a small number of real tick intervals and accept longer runtime.
2. If runtime becomes unreasonable, create clearly named adapted copies under `rtl_work/legacy_adapted/` that expose a tick-count parameter.
3. Do not modify the original reference RTL files.

The decision must not be hidden in the simulation or wrapper.

## Future RTL Notes

- Instantiate `stopwatch_datapath`, `watch_datapath`, and `watch_fnd_adapter` directly if the default tick runtime is acceptable for the first implementation.
- Do not instantiate `top_control_unit` in the first wrapper; AXI registers replace its button/switch FSM.
- Do not instantiate `top_stopwatch_watch`; it mixes debounce, control FSM, datapaths, muxing, and FND output.
- Keep all FND display control in `axi_fnd_core`.
- Keep UVM deferred until all custom AXI4-Lite peripherals are implemented and basic Vivado simulations pass.