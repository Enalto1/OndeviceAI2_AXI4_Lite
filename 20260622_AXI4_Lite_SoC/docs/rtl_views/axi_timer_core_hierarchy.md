# axi_timer_core RTL Hierarchy

## Scope

Prompt 8 implements the `axi_timer_core` RTL wrapper only. It does not create a Vivado simulation testbench, run simulation, create UVM, create MicroBlaze software, or create a Vivado block design.

## RTL File

```text
rtl_work/axi_peripherals/axi_timer_core/hdl/axi_timer_core.v
```

## Hierarchy

```text
axi_timer_core
  -> u_stopwatch_datapath : stopwatch_datapath
       -> tick_counter_st
       -> tick_gen_100hz_st
  -> u_watch_datapath : watch_datapath
       -> tick_counter_wt
       -> tick_gen_100hz_wt
  -> u_watch_fnd_adapter : watch_fnd_adapter
```

The reused modules are declared in unchanged reference files:

```text
axi_project_unique_sources/sources/stopwatch_datapath.v
axi_project_unique_sources/sources/watch_datapath.v
axi_project_unique_sources/sources/watch_fnd_adapter.v
```

## AXI Interface

The wrapper uses Vivado 2020.2-compatible AXI4-Lite template-style handshake logic:

- `C_S00_AXI_DATA_WIDTH = 32`
- `C_S00_AXI_ADDR_WIDTH = 6`
- `s00_axi_aclk`
- `s00_axi_aresetn`, active low
- Internal active-high reset: `rst = ~s00_axi_aresetn`

No external non-AXI ports are present in the first Timer wrapper.

## Register-To-Port Mapping

| Wrapper register field | Reused module port |
| --- | --- |
| `CONTROL[0] stopwatch_run` | `u_stopwatch_datapath.i_runstop` |
| `CONTROL[1] stopwatch_down` | `u_stopwatch_datapath.i_mode` |
| `COMMAND[0] stopwatch_clear` | one-clock `u_stopwatch_datapath.i_clear` pulse |
| `CONTROL[8] watch_set_mode` | `u_watch_datapath.i_set_mode` |
| `CONTROL[10:9] watch_time_sel` | `u_watch_datapath.i_time_sel` |
| `CONTROL[11] watch_digit_sel` | `u_watch_datapath.i_digit_sel` |
| `COMMAND[8] watch_edit_up` | one-clock `u_watch_datapath.i_edit_cmd = 2'b01` when set mode is active |
| `COMMAND[9] watch_edit_down` | one-clock `u_watch_datapath.i_edit_cmd = 2'b10` when set mode is active |

## Readback Mapping

| Register | Source |
| --- | --- |
| `CONTROL` | Stored meaningful control bits `[1:0]` and `[11:8]`; reserved bits read zero. |
| `COMMAND` | Always reads `32'h0000_0000`. |
| `STOPWATCH_VALUE` | `{8'h00, stopwatch_hour, stopwatch_min, stopwatch_sec, stopwatch_msec}` from `u_stopwatch_datapath`. |
| `WATCH_VALUE` | `{8'h00, watch_hour, watch_min, watch_sec, watch_msec}` from `u_watch_fnd_adapter`. |
| `WATCH_RAW_DIGITS` | Raw split digit outputs from `u_watch_datapath`. |
| `STATUS` | Mirrors meaningful `CONTROL` bits. |
| `VERSION` | Fixed `32'h0001_0000`. |
| Reserved offsets | `32'h0000_0000`. |

## COMMAND Pulse Mapping

`COMMAND` is write-only and has no stored state.

| Command bit | WSTRB lane | Internal effect |
| --- | --- | --- |
| `COMMAND[0]` | `WSTRB[0]` | One `s00_axi_aclk` cycle `stopwatch_clear_pulse`. |
| `COMMAND[8]` | `WSTRB[1]` | One `s00_axi_aclk` cycle `watch_edit_cmd = 2'b01` when `CONTROL[8] = 1`. |
| `COMMAND[9]` | `WSTRB[1]` | One `s00_axi_aclk` cycle `watch_edit_cmd = 2'b10` when `CONTROL[8] = 1`. |

If `COMMAND[8]` and `COMMAND[9]` are written as `1` in the same accepted write, edit-up has priority and `watch_edit_cmd = 2'b01`.

If `CONTROL[8] watch_set_mode` is `0`, watch edit command writes are ignored and `watch_edit_cmd` remains `2'b00`.

## WSTRB Behavior

`CONTROL`:

- `WSTRB[0]` updates `CONTROL[1:0]`.
- `WSTRB[1]` updates `CONTROL[11:8]`.
- `WSTRB[2]` and `WSTRB[3]` have no visible effect.

`COMMAND`:

- `WSTRB[0]` enables `COMMAND[0]`.
- `WSTRB[1]` enables `COMMAND[8]` and `COMMAND[9]`.
- `WSTRB[2]` and `WSTRB[3]` have no visible effect.

Read-only and reserved registers ignore writes.

## Reset Behavior

On reset:

- AXI template state resets.
- `control_reg[11:0]` resets to zero.
- `stopwatch_clear_pulse` resets to zero.
- `watch_edit_cmd` resets to `2'b00`.
- `u_stopwatch_datapath` and `u_watch_datapath` receive active-high `rst`.
- `COMMAND` reads zero.
- `STATUS` reflects reset control state.
- `VERSION` reads `32'h0001_0000`.

## Timer/FND Decoupling

`axi_timer_core` does not instantiate `fnd_controller` or `axi_fnd_core`, and it has no `fnd_com` or `fnd_data` outputs. MicroBlaze software will later read Timer values and write display values into `axi_fnd_core`.

## Reference RTL Status

The reference timer RTL files remain unchanged. No adapted Timer copy was created in Prompt 8.

## Verification Status

Timer Vivado simulation is still pending. The next verification step should create and run `sim/vivado/axi_timer_core` using Vivado 2020.2.